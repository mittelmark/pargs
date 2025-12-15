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
	python3 docu.py pargs.py > pargs.Rmd
	tmdoc pargs.Rmd - --toc true  | mndoc - pargs.html --css tmdoc.css
test:
	python3 pargs.py | grep -q Usage: && echo OK || echo Fail
	python3 pargs.py -h | grep -q Arguments: && echo OK || echo Fail
	python3 pargs.py -i 12 | grep -q "Valid subcommands are" && echo OK || echo Fail
	python3 pargs.py dummy -i 12 | grep -q "Wrong subcommand 'dummy'" && echo OK || echo Fail
	python3 pargs.py run -i 15 test.txt | grep -q "x: 15" && echo OK || echo Fail
	python3 pargs.py run -i 15 test.txt | grep -q "script: pargs.py" && echo OK || echo Fail
	python3 pargs.py run -i=25 test.txt | grep -q "x: 25" && echo OK || echo Fail
	python3 pargs.py run -i | grep -q "Error: Missing argument" && echo OK || echo Fail
	python3 pargs.py run -i 12 | grep -q "Missing <INFILE> argument" && echo OK || echo Fail
	python3 pargs.py run -i 12 test.txt | grep -q "infile: 'test.txt' - outfile: '-'" && echo OK || echo Fail
	python3 pargs.py run -f 33.5 test.txt | grep -q "f: 33.500" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 test.txt | grep -q "f: 34.500" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 test.txt | grep -q "v: False" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v test.txt | grep -q "v: True" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v 0 test.txt | grep -q "v: False" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v=0 test.txt | grep -q "v: False" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v 1 test.txt | grep -q "v: True" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v=True test.txt | grep -q "v: True" && echo OK || echo Fail
	python3 pargs.py run -f=34.5 -v=True test.txt | grep -q "infile: 'test.txt'" && echo OK || echo Fail
	python3 pargs.py run test.txt | grep -q "s: Hi" && echo OK || echo Fail
	python3 pargs.py run -s Test1 test.txt | grep -q "s: Test1" && echo OK || echo Fail
	python3 pargs.py run -s=Test2 test.txt | grep -q "s: Test2" && echo OK || echo Fail
	python3 pargs.py run test.txt -s | grep -q "Error:" && echo OK || echo Fail
	python3 pargs.py run -i 12 test.txt out.txt | grep -q "infile: 'test.txt' - outfile: 'out.txt'" && echo OK || echo Fail

test-all:
	@make test | grep -v python3 | grep -v make | uniq -c
