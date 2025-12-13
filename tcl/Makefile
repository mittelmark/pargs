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
