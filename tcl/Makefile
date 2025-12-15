##-*- makefile -*-############################################################
#
# Copyright (C) 2025 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################

CURRENT_MAKEFILE := $(lastword $(MAKEFILE_LIST))

## argument delegation
ARGS=

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

docu:   ## create HTML doc
	mndoc pargs.tcl pargs.Rmd
	tmdoc pargs.Rmd - --toc true  | mndoc - pargs.html --css tmdoc.css

test:   ## test pargs package
	tclsh pargs.test
test-app:
	tclsh pargs.tcl | grep -q Usage: && echo OK || echo Fail
	tclsh pargs.tcl -h | grep -q Arguments: && echo OK || echo Fail
	tclsh pargs.tcl -i 12 | grep -q "known subcommands are" && echo OK || echo Fail
	tclsh pargs.tcl dummy -i 12 | grep -q "Unkown subcommand 'dummy'" && echo OK || echo Fail
	tclsh pargs.tcl run -i 15 test.txt | grep -q "i is 15" && echo OK || echo Fail
	tclsh pargs.tcl run -i 15 test.txt | grep -q "script: pargs.tcl" && echo OK || echo Fail	
	tclsh pargs.tcl run -i=25 test.txt | grep -q "i is 25" && echo OK || echo Fail
	tclsh pargs.tcl run -i | grep -q "Error: Missing value for option" && echo OK || echo Fail		
	tclsh pargs.tcl run -i 12 | grep -q "Missing <INFILE> argument" && echo OK || echo Fail
	tclsh pargs.tcl run -i 12 test.txt | grep -q "infile: test.txt - outfile: -" && echo OK || echo Fail
	tclsh pargs.tcl run -f 33.5 test.txt | grep -q "f is 33.5" && echo OK || echo Fail
	tclsh pargs.tcl run -f=34.5 test.txt | grep -q "f is 34.5" && echo OK || echo Fail
	tclsh pargs.tcl run  test.txt | grep -q "s is Hi" && echo OK || echo Fail
	tclsh pargs.tcl run -s Test1 test.txt | grep -q "s is Test1" && echo OK || echo Fail
	tclsh pargs.tcl run -s=Test2 test.txt | grep -q "s is Test2" && echo OK || echo Fail
	tclsh pargs.tcl run test.txt -s | grep -q "Error:" && echo OK || echo Fail
	tclsh pargs.tcl run -i 12 test.txt out.txt | grep -q "infile: test.txt - outfile: out.txt" && echo OK || echo Fail

test-all:
	@make test-app 2>/dev/null | grep -v tclsh | grep -v make | uniq -c
