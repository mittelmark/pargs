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
	python3 docu.py pargs.py > pargs.md
	python3 docu.py pargs.py > pargs.md
test:
	python3 pargs.py | grep -q Usage: && echo OK || echo Fail
	python3 pargs.py -h | grep -q Arguments: && echo OK || echo Fail
	python3 pargs.py -i 12 | grep -q "Valid subcommands are" && echo OK || echo Fail
	python3 pargs.py dummy -i 12 | grep -q "Wrong subcommand 'dummy'" && echo OK || echo Fail
	python3 pargs.py run -i 12 | grep -q "Missing <INFILE> argument" && echo OK || echo Fail
	python3 pargs.py run -i 12 test.txt | grep -q "infile: 'test.txt' - outfile: '-'" && echo OK || echo Fail

