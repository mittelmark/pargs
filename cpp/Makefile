##-*- makefile -*-############################################################
#
# Copyright (C) 2025 Detlef Groth, University of Potsdam
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
test-cpp:
	g++ test.cpp -o test
	./test | grep -q Usage: && echo OK || echo Fail
	./test -h | grep -q Arguments: && echo OK || echo Fail
	./test -i 12 | grep -q "Valid subcommands are" && echo OK || echo Fail
	./test dummy -i 12 | grep -q "Wrong subcommand 'dummy'" && echo OK || echo Fail
	./test run -i 15 test.txt | grep -q "int: 15" && echo OK || echo Fail
	./test run -i 15 test.txt | grep -q "appname: ./test" && echo OK || echo Fail
	./test run -i=25 test.txt | grep -q "int: 25" && echo OK || echo Fail
	./test run -i | grep -q "Error: Missing argument" && echo OK || echo Fail
	./test run -i 12 | grep -q "Missing <INFILE> argument" && echo OK || echo Fail
	./test run -i 12 test.txt | grep -q "infile: 'test.txt' outfile: '-'" && echo OK || echo Fail
	./test run -f 33.5 test.txt | grep -q "float: 33.5" && echo OK || echo Fail
	./test run -f=34.5 test.txt | grep -q "float: 34.5" && echo OK || echo Fail
	./test run -f=34.5 test.txt | grep -q "verbose: 0" && echo OK || echo Fail
	./test run -f=34.5 -v test.txt | grep -q "verbose: 1" && echo OK || echo Fail
	./test run -f=34.5 -v 0 test.txt | grep -q "verbose: 0" && echo OK || echo Fail
	./test run -f=34.5 -v=0 test.txt | grep -q "verbose: 0" && echo OK || echo Fail
	./test run -f=34.5 -v 1 test.txt | grep -q "verbose: 1" && echo OK || echo Fail
	./test run -f=34.5 -v=True test.txt | grep -q "verbose: 1" && echo OK || echo Fail
	./test run -f=34.5 -v=True test.txt | grep -q "infile: 'test.txt'" && echo OK || echo Fail
	./test run test.txt | grep -q "subcommand: run" && echo OK || echo Fail
	./test run -s Test1 test.txt | grep -q "str: Test1" && echo OK || echo Fail
	./test run -s=Test2 test.txt | grep -q "str: Test2" && echo OK || echo Fail
	./test run test.txt -s | grep -q "Error:" && echo OK || echo Fail
	./test run -i 12 test.txt out.txt | grep -q "infile: 'test.txt' outfile: 'out.txt'" && echo OK || echo Fail

test-all:
	@make test | grep -v python3 | grep -v make | uniq -c
