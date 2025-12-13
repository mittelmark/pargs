#!/usr/bin/env python3
"""pargs.py - Command line parsing for DBP lectures.
Detlef Groth, University of Potsdam, Germany
2025-12-13

## NAME

__pargs.py__ - This module provides a simple class to allow command line argument parsing
for Python applications. Supporting the following features:

`include pargs.toc`

## DESCRIPTION

The pargs module supports parsing the following types of command line options.

- long and short options
- boolean flags
- key value options with defaults if argument was not given
- check for wrong option names
- positional argument parsing with defaults
- usage function line based on provided help page
- help function based on  provided help page

The order fo parsing should be the following:

- parser creation with doc, argv  and version as arguments
- usage check - optional if you need
- help check
- subcommand check (subcommand) - optional if you use that
- flag check (parse) - usually for version check
- option check for key value (parse) - optional if you need
- wrong option check (check)  - mandatory to check for invalid ones
- positionals check (positional) - optional if you need that

## EXAMPLE

```
#!/usr/bin/env python3
'''Usage: app.py (-h | --help) 
        [ -V, --version, -v,--verbose -i INT -f FLOAT]
         <INFILE> [<OUTFILE>]
         
Options:
    -h, --help               display this help message
    -V, --version            display the application version
    -v, --verbose            set verbose to true
    -i INT, --int INT        give an integer [default: 10]
    -f FLOAT, --float FLOAT  give a float value [default: 10.5] 
    
Arguments:
    <INFILE>           mandatory input filea
    <OUTFILE>          optional output file [default: '-']
'''
## using Module documentation __doc__ for help
__version__ = "0.0.1"
import sys
import pargs
def main(argv)
    ## just some demo code
    parser = pargs.Pargs(__doc__,argv,__version__)
    if (len(argv)==1): 
        print(pargs.usage()); sys.exit()
    if pargs.parse("bool","-h","--help",False): 
        print(pargs.help()); sys.exit()
    if pargs.parse("bool","-V","--version",False): 
        print(pargs.version()); sys.exit()
    c = pargs.subcommand(["check","run","round"])
    if c == None: sys.exit()
    v = pargs.parse("bool","-v","--verbose",False)
    x = pargs.parse("int","-i","--int",10)
    if x == None: sys.exit()
    f = pargs.parse("float","-f","--flt",10.2)
    if f == None: sys.exit()
    # check for wrong options    
    if not pargs.check(): sys.exit()
    infile,outfile=pargs.position(2)
    if infile == "-": 
        pargs.error("Missing <INFILE> argument!")
        print(pargs.usage()); exit()
    print("c: %s " % (c))           
    print("v: %s " % (v))            
    print("x: %i - f: %.3f" % (x,f))
    print("infile: '%s' - outfile: '%s'" % (infile,outfile))

if __name__ == "__main__":
    main(sys.argv)

```

## Class Documentation

"""
# Command line parsing
# Steps:
# 
# - look for number of arguments, if necessary call usage
# - look for help flags - call help if necessary
# - declare and extract values of valid flags
# - declare and extract values of options with key val or key=val syntax
# - check for invalid flags, looping over all remaining arguments
# - flags --flag (True)
# - options --opt=val --opt val
# - positionals - usually after options
# 
# _Parsing steps:_
# 
# 1) usage
# 2) help
# 3) subcommands
# 4) flags
# 5) options with values
# 6) remaining options?
# 7) positionals

import sys
import re
class Pargs:
    """Pargs - Poor students argument parser."""    
    def __init__(self,doc,argv,version="0.0.0",color=True):
        """
        Initialize parser with default help page and state color support for error messages.
        
        Arguments:
            doc     - the help page
            argv    - the argument vector
            version - the application version [default: "0.0.0"]
            color - should error message use color [default: True]
        """
        if type(doc) != type(""):
            raise Exception("TypeError: Variable doc should be of type string! Wrong order of doc,argv?")
        if type(argv) != type([]):
            raise Exception("TypeError: Variable argv should be of type list! Wrong argument order of doc,argv?")
        self.doc = doc
        self.color = color
        i = 0
        l=len(argv)
        while i < l-1:
            ## check for 'key=val' syntax
            i=i+1
            if re.search("=",argv[i]):
                val=re.sub(".+=","",argv[i])
                key=re.sub("=.+","",argv[i])
                argv.insert(i+1,val)
                argv[i]=key
                l=l+1
        self.argv = argv
        self._version=version
        if color:
            self.RED = "\033[31m"
            self.DEF = "\033[0m"
        else:
            self.RED = ""
            self.DEF = ""
        #' 
        #' ## Methods
        #'
    def error(self,msg):
        """
        Colored error message.
        
        Arguments:
            msg - the message to display
        """
        print("%s%s%s" % (self.RED,msg,self.DEF))

    def subcommand(self, names):
        """
        Check first argument for a valid subcommand.
        
        Arguments:
            names   - list of valid subcommands to search against
            exit_on_error   - should the application being finished in case of errors [default: True]
        
        Returns: subcommand name if valid or empty string.
        """
        if self.argv[1] in names:
            return(self.argv.pop(1))
        else:
            self.error("Error: Wrong subcommand '%s'!" % (self.argv[1]))
            self.error("Valid subcommands are '%s'!" % ("','".join(names)))
            print(self.usage())
            return(None)
    def parse(self,type, ashort, along,default=None):
        """
        Initialize options with possible defaults.
        
        Arguments:
            type    - data type of that option, either 'bool', 'int', 'float' or 'string'
                      the boolean type is handeled as a flag and expects no value
            ashort  - short option name like '-v'
            along   - long option name like '--verbose'
            default - default value if the option is not given [default: None]
        """
        idx = -1
        if ashort in self.argv:
            idx = self.argv.index(ashort)
        elif along in self.argv:
            idx = self.argv.index(along)
        if idx > -1 and type == "bool":
            self.argv.pop(idx)
            return True    
        elif type == "bool":
            return False
        elif idx > -1 and type in ["int","float"]:
            if len(self.argv)<idx and None == "default":
                self.error("Error: missing argument for %s,%s!" % (ashort,along))
                print(self.usage())
                return None
            elif len(self.argv) == idx:
                self.error("Error: missing argument for %s,%s!" % (ashort,along))
                print(self.usage())
                return(None)
            elif len(self.argv)>idx+1:
                if type == "int":
                    if re.match("[0-9]+$",self.argv[idx+1]):
                        val=int(self.argv.pop(idx+1))
                        self.argv.pop(idx)
                        return(val)
                    else:
                         self.error("Error: wrong argument for %s,%s! Not an integer!" % (ashort,along))
                         print(self.usage())
                         return(None)
                elif type == "float":
                    if re.match("[\\.0-9]+$",self.argv[idx+1]):
                        val=float(self.argv.pop(idx+1))
                        self.argv.pop(idx)
                        return(val)
                    else:
                         self.error("Error: wrong argument for %s,%s! Not a float!" % (ashort,along))
                         print(self.usage())
                         return(None)
            else:
                self.error("Error: Missing argument for argument %s,%s!"  % (ashort,along))
                print(self.usage())
                return(None)
                
        elif idx > -1 and type == "string":
            if len(self.argv)<idx+1 and None == default:
                self.error("Error: missing argument for %s,%s!" % (ashort,along))
                print(self.usage())
                return(None)
            elif len(self.argv)<idx+1:
                return(default)
            else:
                return(self.argv[idx+1])
        else:
            return(default)
    
    def check(self):
        """
        Check for any not supported option present in argv.
        Should be used only after the parse method. Returns True 
        if the checkwas succesfull, and False if not.
        
        """
        
        rhy = re.compile("--?\\w")
        l = list(filter(rhy.match,self.argv))
        if len(l)>0:
            for i in l:
                self.error("Error: Wrong argument: '%s'!" % i)
                print(self.usage())
            return(False)
        else:
            return(True)
            
    def position(self,max=1,default="-"):
        """
        Check for positional arguments.
        Should be called after parse and check methods,
        so usually last.

        Arguments:
            max     - maximal number of arguments  [default:  1 ]
            default - value if argument is missing [default: '-']
        """
        res = []
        for i in range(1,max+1):
            if len(self.argv)>i:
                res.append(self.argv[i])
            else:
                res.append(default)
        return(res)
    def help(self,exit_on=True):
        """
        Display full help page.
        
        Arguments:
            exit_on   - should the application being finished afterwards [default: True]            
        """
        return(self.doc.format(self.argv[0]))
        
    def usage(self):
        """
        Display docu text until the first empty line within that text.
        """
        n = 0
        res = ""
        for line in self.doc.split("\n"):
            n = n + 1
            if n > 1 and re.match("\\s*$",line):
                break
            else:
                res = res + line + "\n"
        return(res.format(self.argv[0]))
    def version(self):
        """
        Display application version.
        """
        return(self._version)

### Just some sample documentation
DOC=R"""Usage: app.py (check | round | run) [ -v --verbose ] [ -V --version ]
    (-h | --help | -i INT | -f FLOAT) <INFILE> [<OUTFILE>]

Commands:
    run            run some code
    check          check soem given code
    round          round some number
Options:
    -V, --version      return the version 
    -v, --verbose      turn verbose on [default: False]
    -i, --int INT      Some integer [default: 10]
    -f, --float FLOAT  Some float   [default: 10.2]
Arguments:
    <INFILE>       input file with some numbers
    <OUTFILE>      output file [default: '-']
"""
import sys
__version__ = "0.0.5"

def main(argv):
    from pargs import Pargs
    pargs=Pargs(DOC,argv,version=__version__)
    if (len(argv)==1): 
        print(pargs.usage()); sys.exit()
    if pargs.parse("bool","-h","--help",False): 
        print(pargs.help()); sys.exit()
    if pargs.parse("bool","-V","--version",False): 
        print(pargs.version()); sys.exit()
    c = pargs.subcommand(["check","run","round"])
    if c == None: sys.exit()
    v = pargs.parse("bool","-v","--verbose",False)
    x = pargs.parse("int","-i","--int",10)
    if x == None: sys.exit()
    f = pargs.parse("float","-f","--flt",10.2)
    if f == None: sys.exit()
    # check for wrong options    
    if not pargs.check(): sys.exit()
    infile,outfile=pargs.position(2)
    if infile == "-": 
        pargs.error("Missing <INFILE> argument!")
        print(pargs.usage()); exit()
    print("c: %s " % (c))           
    print("v: %s " % (v))            
    print("x: %i - f: %.3f" % (x,f))
    print("infile: '%s' - outfile: '%s'" % (infile,outfile))
  
if __name__ == "__main__":           
    main(sys.argv)
#' 
#' ## TODO        
#'   
#' - subcommands (done)
#' - --opt=val syntax (done)
#' - type=function for type checking  returning True/False
#' - str(type(t)) == "<class 'function'>"
#'
#' ## SEE ALSO
#'
#' Here set of links which are implementing other command line parsers:
#'
#' - [optparse](https://docs.python.org/3/library/optparse.html)
#' - [argparse](https://docs.python.org/3/library/argparse.html)
#' - [docopt](https://github.com/docopt/docopt)
#' 

#' ## CHANGES
#'
#' - 2025-12-13: Version 0.0.5 initial checkin into Gituup, removing exits from class
#' - 2025-12-12: Version 0.0.4 initial use in lecture
#' 
#' ## AUTHOR
#'
#' The **pargs** package was written by Detlef Groth, University of Potdam, Germany.
#'
#' ## LICENSE AND COPYRIGHT
#'
#' pargs command line argument parser for Tcl/Tk version 0.0.1
#'
#' Copyright (c) 2025  Detlef Groth, E-mail: <dgroth(at)uni(minus)potsdam(dot)de>
#' 
#' BSD License type:
#'
#' Sun Microsystems, Inc. The following terms apply to all files a ssociated
#' with the software unless explicitly disclaimed in individual files. 
#' 
#' The authors hereby grant permission to use, copy, modify, distribute, and
#' license this software and its documentation for any purpose, provided that
#' existing copyright notices are retained in all copies and that this notice
#' is included verbatim in any distributions. No written agreement, license,
#' or royalty fee is required for any of the authorized uses. Modifications to
#' this software may be copyrighted by their authors and need not follow the
#' licensing terms described here, provided that the new terms are clearly
#' indicated on the first page of each file where they apply. 
#'
#' In no event shall the authors or distributors be liable to any party for
#' direct, indirect, special, incidental, or consequential damages arising out
#' of the use of this software, its documentation, or any derivatives thereof,
#' even if the authors have been advised of the possibility of such damage. 
#'
#' The authors and distributors specifically disclaim any warranties,
#' including, but not limited to, the implied warranties of merchantability,
#' fitness for a particular purpose, and non-infringement. This software is
#' provided on an "as is" basis, and the authors and distributors have no
#' obligation to provide maintenance, support, updates, enhancements, or
#' modifications. 
#'
#' RESTRICTED RIGHTS: Use, duplication or disclosure by the government is
#' subject to the restrictions as set forth in subparagraph (c) (1) (ii) of
#' the Rights in Technical Data and Computer Software Clause as DFARS
#' 252.227-7013 and FAR 52.227-19. 
#'
