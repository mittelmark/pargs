#!/usr/bin/env Rscript
#' ---
#' title: pargs.R - Command line parsing for DBP lectures.
#' author: Detlef Groth, University of Potsdam, Germany
#' date: 2025-12-13
#' ---
#' 
#' ## NAME
#' 
#' __pargs.R__ - This module provides a simple environment class to allow command line argument parsing
#' for R applications.
#' 
#' `include pargs.toc`
#' 
#' ## DESCRIPTION
#' 
#' The pargs module supports parsing the following types of command line options.
#' 
#' - long and short options
#' - boolean flags
#' - key value options with defaults if argument was not given
#' - check for int and float types in option values
#' - check for wrong option names
#' - check for valid subcommands
#' - positional argument parsing with defaults
#' - usage function line based on provided help page
#' - help function based on provided help page
#' 
#' The order of parsing should be the following:
#' 
#' - parser creation with doc, argv and version as arguments
#' - usage check - optional if you need
#' - help option presence check
#' - subcommand check (subcommand) - optional if you use that
#' - flag check (parse) - usually for version check and other flags
#' - option check for key value paurse (parse) - optional if you need
#' - wrong option check (check)  - mandatory to check for invalid ones
#' - positionals check (positional) - optional if you need that
#' 
#' ## EXAMPLE
#' 
#' ```
#' #!/usr/bin/env Rscript
#' DOC="Usage: APP (-h | --help)
#'         [ -V, --version, -v,--verbose -i INT -f FLOAT]
#'          <INFILE> [<OUTFILE>]
#'          
#' Options:
#'     -h, --help               display this help message
#'     -V, --version            display the application version
#'     -v, --verbose            set verbose to true
#'     -i INT, --int INT        give an integer [default: 10]
#'     -f FLOAT, --float FLOAT  give a float value [default: 10.5] 
#'     
#' Arguments:
#'     <INFILE>           mandatory input filea
#'     <OUTFILE>          optional output file [default: '-']
#' "
#' ## using Module documentation __doc__ for help
#' VERSION = "0.0.1"
#' main = function (argv) {
#'     ## just some demo code
#'     DOC=gsub("APP",argv[1],DOC)
#'     parser = pargs$new(DOC,argv,VERSION)
#'     if (length(argv)==1) { 
#'         cat(pargs$usage()); q(status=0)
#'     } else if (pargs$parse("bool","-h","--help",FALSE)) {
#'         cat(pargs$help()); q()
#'     } else if (pargs$parse("bool","-V","--version",FALSE)) {
#'         cat(pargs$version()); q()
#'     }
#'     c = pargs$subcommand(c("check","run","round"))
#'     if (is.null(c)) q()
#'     v = pargs$parse("bool","-v","--verbose",FALSE)
#'     x = pargs$parse("int","-i","--int",10)
#'     if (is.null(x)) q()
#'     f = pargs$parse("float","-f","--float",10.2)
#'     if (is.null(f)) q()
#'     # check for wrong options    
#'     if (!pargs$check()) q()
#'     infile=pargs$position()
#'     if (infile == "-") { 
#'         pargs$error("Missing <INFILE> argument!")
#'         cat(pargs$usage())
#'         q()
#'     }
#'     outfile=pargs$position()
#'     cat(sprintf("c: %s\n",c))
#'     cat(sprintf("v: %s\n",v))
#'     cat(sprintf("x: %i - f: %.3f\n", x,f))
#'     cat(sprintf("infile: '%s' - outfile: '%s'\n",infile,outfile))
#' }
#' if (sys.nframe() == 0L && !interactive()) {
#'     binname <- gsub("--file=","", grep("--file", commandArgs(), value=TRUE)[1])
#'     main(c(binname, commandArgs(trailingOnly=TRUE)))
#' }
#' ```
#' 
#' ## Class Documentation
#' 
#
# Command line parsing
# Steps:
# 
# - look for number of arguments, if necessary call usage
# - look for help flags - call help if necessary
# - check for a subcommand if necessary
# - declare and extract values of valid flags
# - declare and extract values of options with key val or key=val syntax
# - check for invalid flags, looping over all remaining arguments
# - flags --flag (TRUE)
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
# 7) positional(s)

#' __pargs__ - Poor students argument parser. 
#'
#' ### Constructor
#'
#'**pargs$new(doc,argv,version="0.0.0",color=TRUE)**
#'
pargs = new.env()

pargs$new <- function (doc,argv,version="0.0.0",color=TRUE) {
    #' Initialize parser with default help page and state color support for error messages.
    #'
    #' > Arguments:
    #' 
    #' > - _doc_    - the help page
    #'  - _argv_    - the argument vector
    #'  - _version_ - the application version [default: "0.0.0"]
    #'  - _color_   - should error message use color [default: TRUE]
    self = pargs
    self$doc = doc
    self$color = color
    self$script = argv[1]
    i = 1
    l=length(argv)
    while (i < l) {
        ## check for 'key=val' syntax
        i=i+1
        if (grepl("=",argv[i])) {
            val=gsub(".+=","",argv[i])
            key=gsub("=.+","",argv[i])
            argv[i]=key
            if (l>i) {
                argv=c(argv[1:i],val,argv[i+1:length(argv)])
            } else {
                argv=c(argv[1:i],val)
            }
            l=l+1
        }
    }
    if (length(argv)>1) {
        self$argv = argv[2:length(argv)]
    } else {
        self$argv = c()
    }
    self$version=version
    if (color) {
        self$RED = "\033[31m"
        self$DEF = "\033[0m"
    } else {
        self$RED = ""
        self$DEF = ""
    }
}

#' 
#' ### Methods
#'
#'
#' **pargs$check()**
#'
#' Check for any not supported option present in argv.
#' Should be used only after the parse method. Returns TRUE
#' if the checkwas succesfull, and False if not.
#'
#' > Arguments: None
#' 
#' > Returns: FALSE if there was an error, and TRUE if there was no error.

pargs$check <- function () {
    self=pargs
    rhy = "--?\\w"
    l = which(grepl("^--?\\w",self$argv))
    e = FALSE
    if (length(l)>0) {
        for (i in l) {
            self$error(sprintf("Error: Wrong argument: '%s'!", i))
            e = TRUE
        }
    }
    if (e) {
        cat(self$usage())
        return(FALSE)
    } else {
        return(TRUE)
    }
}
#'
#' **pargs$error(msg)**
#'
#' Colored error message.
#'
#' > Arguments:
#'
#' > - _msg_ - the message to display
pargs$error <- function (msg) {
    self = pargs
    cat(sprintf("%s%s%s\n",self$RED,msg,self$DEF))
}

#'
#' **pargs$help()**
#'
#' Display full help page.
#'
#' > Arguments: None
#'
#' > Returns: the help page as a string

pargs$help <- function () {
    self = pargs
    return(self$doc)
}

pargs$pop <- function (index) {
    self=pargs
    val=self$argv[index]
    if (index == 1) {
        if (length(self$argv) > index) {
            self$argv=self$argv[2:length(self$argv)]
        } else {
            self$argv=list()
        }
    } else {
        if (length(self$argv) > index) {
            self$argv=c(self$argv[1:(index-1)],self$argv[(index+1):length(self$argv)])
        } else {
            self$argv=self$argv[1:(index-1)]
        }
    }
    return(val)
}

#'
#' **pargs$parse(self,type, ashort, along,default=NULL)**
#'
#' Initialize option with possible default.
#'
#' > Arguments:
#'
#' > - _type_ - data type of that option, either 'bool', 'int', 'float' or 'string'
#'     the boolean type is handeled as a flag and expects no value
#'   - _ashort_  - short option name like '-v'
#'   - _along_   - long option name like '--verbose'
#'   - _default_ - default value if the option is not given [default: NULL]
#' 
#' > Returns: the parsed value or if not given on the command line the default value

pargs$parse <- function (type, ashort, along,default=NULL) {
    self = pargs
    idx = which(self$argv == ashort)
    if (length(idx)==0) {
        idx=which(self$argv == along)
    }
    if (length(idx)>0) {
        idx=idx[1]
    } else {
        idx=-1
    }
    if (idx>0) {
        if (type == "bool") {
            self$pop(idx)
            return(TRUE)
        } else if (type %in% c("int","float")) {
            if (length(self$argv)+1 < idx) {
                self$error(sprintf("Error: missing argument for %s,%s!",ashort,along))
                cat(self$usage())
                return(NULL)
            }
            if (type == "int") {
                if (grepl("^[0-9]+$",self$argv[idx+1])) {
                    val=as.integer(self$pop(idx+1))
                    self$pop(idx)
                    return(val)
                } else {
                    self$error(sprintf("Error: Wrong argument for %s,%s! Not an integer!", ashort,along))
                    cat(self$usage())
                    return(NULL)
                }
            } else if (type == "float") {
                if (grepl("^[\\.0-9]+$",self$argv[idx+1])) {
                    val=as.numeric(self$pop(idx+1))
                    self$pop(idx)
                    return(val)
                } else {
                    self$error(sprintf("Error: Wrong argument for %s,%s! Not a float!", ashort,along))
                    cat(self$usage())
                    return(NULL)
                }
            }
        } else if (idx > 0 & type == "string") {
            if (length(self$argv)<idx+1) {
                self$error(sprintf("Error: Missing argument for %s,%s!", ashort,along))
                cat(self$usage())
                return(NULL)
            } else {
                val=self$pop(idx+1)
                self$pop(idx)
                return(val)
            }
        } else {
            self$error(sprintf("Error: Wrong type '%s'! Valid types are bool, int, float and string!"),type)
            cat(self$usage())
        }
    } else {
        return(default)
    }
}
#'
#' **pargs$position(default="-")**
#'
#' Check for positional arguments.
#' Should be called after parse and check methods,
#' so usually last.
#'
#' > Arguments: 
#'
#' > - default: value if argument is missing [default: '-']
#' 
#' > Returns: the value given on the command line or the default if there is no positional given

pargs$position <- function (default="-") {
    self=pargs
    if (length(self$argv) > 0) {
        val=pargs$pop(1)
        return(val)
    } else {
        return(default)
    }
}
#'
#' **pargs$subcommand(names)**
#'
#' Check first argument for a valid subcommand.
#'
#' > Arguments:
#'
#' > - names - list of valid subcommands to search against
#' 
#' > Returns: subcommand name if valid or NULL if is invalid.

pargs$subcommand <- function (names) {
    self=pargs
    if (self$argv[1] %in% names) {
        return(self$pop(1))
    } else {
        self$error(sprintf("Error: Wrong subcommand '%s'!", self$argv[1]))
        self$error(sprintf("Valid subcommands are '%s'!", paste(names,collapse="','")))
        cat(self$usage())
        return(NULL)
    }
}
#'
#' **pargs$usage()**
#'
#' Display docu text until the first empty line within that text.
#'
#' > Arguments: None
#'
#' > Returns: the usage lines

pargs$usage <- function () {
    self = pargs
    n = 0
    res = ""
    for (line in strsplit(self$doc,"\n")[[1]]) {
        n = n + 1
        if (n > 1 & grepl("^\\s*$",line)) {
            break
        } else {
            res = paste(res,line,"\n",sep="")
        }
    }
    return(res)
}
#'
#' **pargs$version()**
#'
#' Display application version.
#'
#' > Arguments: None
#'
#' > Returns: the version string

pargs$version <- function() {
    self = pargs
    return (self$version)
}
### Just some sample documentation
DOC="Usage: APP (-h | --help)
        [ -V, --version, -v,--verbose -i INT -f FLOAT]
         <INFILE> [<OUTFILE>]
         
Options:
    -h, --help                 display this help message
    -V, --version              display the application version
    -v, --verbose              set verbose to true
    -i INT, --int INT          give an integer [default: 10]
    -f FLOAT, --float FLOAT    give a float value [default: 10.5]
    -s STRING, --string STRING give a float value [default: Hello]
    
Arguments:
    <INFILE>           mandatory input filea
    <OUTFILE>          optional output file [default: '-']
"
## using Module documentation __doc__ for help
VERSION = "0.0.1"
main = function (argv) {
    ## just some demo code
    DOC=gsub("APP",argv[1],DOC)
    parser = pargs$new(DOC,argv,VERSION)
    if (length(argv)==1) { 
        cat(pargs$usage()); q(status=0)
    } else if (pargs$parse("bool","-h","--help",FALSE)) {
        cat(pargs$help()); q()
    } else if (pargs$parse("bool","-V","--version",FALSE)) {
        cat(pargs$version()); q()
    }
    c = pargs$subcommand(c("check","run","round"))
    if (is.null(c)) q()
    v = pargs$parse("bool","-v","--verbose",FALSE)
    x = pargs$parse("int","-i","--int",10)
    if (is.null(x)) q()
    f = pargs$parse("float","-f","--float",10.2)
    if (is.null(f)) q()
    s = pargs$parse("string","-s","--string","Hello")
    if (is.null(s)) q()
    # check for wrong options    
    if (!pargs$check()) q()
    infile=pargs$position()
    if (infile == "-") { 
        pargs$error("Missing <INFILE> argument!")
        cat(pargs$usage())
        q()
    }
    outfile=pargs$position()
    cat(sprintf("c: %s\n",c))
    cat(sprintf("v: %s\n",v))
    cat(sprintf("x: %i - f: %.3f\n", x,f))
    cat(sprintf("s: %s\n", s))
    cat(sprintf("infile: '%s' - outfile: '%s'\n",infile,outfile))
}
if (sys.nframe() == 0L && !interactive()) {
    binname <- gsub("--file=","", grep("--file", commandArgs(), value=TRUE)[1])
    main(c(binname, commandArgs(trailingOnly=TRUE)))
}
#' 
#' ## TODO        
#'   
#' - type=function for type checking  returning TRUE/FALSE
#' - type=regexp for string checking type=function(x) grepl("^gene_on.*obo")
#'
#' ## SEE ALSO
#'
#' Here set of links which are implementing other command line parsers:
#'
#'
#' - [pargs.py](http://htmlpreview.github.io/?https://github.com/mittelmark/pargs/blob/master/python/pargs.html)
#' - [pargs.tcl](http://htmlpreview.github.io/?https://github.com/mittelmark/pargs/blob/master/tcl/pargs.html)
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
