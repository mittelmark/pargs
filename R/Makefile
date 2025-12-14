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
docu:   ## extract documentation
	mndoc pargs.R pargs.Rmd
	tmdoc pargs.Rmd - --toc true  | mndoc - pargs.html --css tmdoc.css
test:
	Rscript pargs.R | grep -q Usage: && echo OK || echo Fail
	Rscript pargs.R -h | grep -q Arguments: && echo OK || echo Fail
	Rscript pargs.R -i 12 | grep -q "Valid subcommands are" && echo OK || echo Fail 2>/dev/null
	Rscript pargs.R dummy -i 12 | grep -q "Wrong subcommand 'dummy'" && echo OK || echo Fail
	Rscript pargs.R run -i 15 test.txt | grep -q "x: 15" && echo OK || echo Fail
	Rscript pargs.R run -i | grep -q "Error: Wrong argument" && echo OK || echo Fail
	Rscript pargs.R run -s | grep -q "Error: Missing argument" && echo OK || echo Fail
	Rscript pargs.R run -i=25 test.txt | grep -q "x: 25" && echo OK || echo Fail
	Rscript pargs.R run -i 12 | grep -q "Missing <INFILE> argument" && echo OK || echo Fail
	Rscript pargs.R run -i 12 test.txt | grep -q "infile: 'test.txt' - outfile: '-'" && echo OK || echo Fail
	Rscript pargs.R run -f 33.5 test.txt | grep -q "f: 33.500" && echo OK || echo Fail
	Rscript pargs.R run -f=33.5 test.txt | grep -q "f: 33.500" && echo OK || echo Fail
	Rscript pargs.R run -s Test1 test.txt | grep -q "s: Test1" && echo OK || echo Fail
	Rscript pargs.R run -s=Test2 test.txt | grep -q "s: Test2" && echo OK || echo Fail
	Rscript pargs.R run test.txt | grep -q "s: Hello" && echo OK || echo Fail	
	Rscript pargs.R run -i 12 test.txt out.txt | grep -q "infile: 'test.txt' - outfile: 'out.txt'" && echo OK || echo Fail

test-all:
	@make test 2>/dev/null | grep -v Rscript | grep -v make | uniq -c
