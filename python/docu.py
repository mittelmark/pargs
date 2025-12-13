#!/usr/bin/env python3
# -*- coding: ISO-8859-15 -*-
"""Modulename

Usage: {0} ?-h,-?,--help?

Arguments:
"""
__author__ = "first last"
__version__ = "0.1"
import sys, os, re

def help(argv):
    print(__doc__.format(argv[1]))
    
def usage(argv):
    print(f"Usage: {argv[0]} args")
    
def main(argv):
    if (len(argv)) == 1:
        usage(argv)
        
    elif "-h" in argv or "--help" in argv:
        help(argv)
        exit()
    if len(argv) == 1:
        usage(argv)
        exit()
    filename = argv[1]
    if not os.path.exists(filename):
        print("Error: File '%s' does not exists!")
        sys.exit(1)
    
    file = open(filename,'r')
    i = 0
    module = False
    yaml = 0
    clss = False
    func = False
    funcdoc = False
    for line in file:
        i = i + 1
        if (i < 6) and re.match('^"""([^\\s].+)',line):
            yaml=1
            print("---\ntitle: ",re.sub('""" *','',line),end="")
            module = True
        elif (i < 5 and yaml == 1):
            yaml = yaml +1
            print("author: %s" % line,end="")
        elif (i < 5 and yaml == 2 and re.match(".*20.+",line)):
            yaml = yaml + 1
            print("date: %s---\n" % line,end="")
        elif module and re.match('^"""',line):
            module = False
        elif module:                    
            print(line,end="")
        elif re.match("^class.+",line):
            clss = True
            print("\n**class %s**\n" % re.sub("^class +([^:\\s\\n]+).*\\n","\\1",line))
        elif clss and re.match(' +""".+"""',line):
            print("%s" % re.sub(' +"""(.+)"""',"\\1",line))
        elif clss and re.match('^     ?def',line):
            print("\n**def %s**" % re.sub("^ +def +([^:\\n]+).*\\n","\\1",line))
            func = True
        elif func and re.match(' {7,9}"""',line):
            funcdoc = True
            func = False
            print("")
        elif func and re.match(' {7,9}"""(.+)"""',line):
            print("\n%s\n" % re.sub(' +"""(.+)"""',"\\1",line))
            func = False
        elif funcdoc:
            if re.match(" +Arguments:",line):
                print("> _Arguments:_\n\n>",end="")
            elif re.match(" {9,12}[a-z]+",line):
                print(" - _%s_: %s" % (re.sub("^\\s+([^\\s]+) +- .+\\n","\\1",line),  re.sub(".+ - (.+)\\n","\\1",line)))
            elif re.match("\\s{9,13}[a-zA-Z0-9]+\\s+-\\+.+",line):
                print(" - _%s_: %s" % (re.sub(".+ ([\\s]+) .+","\\1",line),  re.sub(".+ - (.+)","\\1",line)))
            elif funcdoc and re.match(' +""".*',line):
                funcdoc = False
                func = False
            elif funcdoc:
                print(re.sub(" {7,9}","",line),end="")
        elif re.match("\\s*#' ?",line):
            print(re.sub(".*#' ?","",line),end="")
    file.close()
    
if __name__ == "__main__":
    main(sys.argv)
    

