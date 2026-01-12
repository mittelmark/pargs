##-*- makefile -*-############################################################
#
# Copyright (C) 2026 MicroEmacs User.
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

main=fib
## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

cpp:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --cpp=1 --outdir out $(main).py
	g++ -std=c++17 out/$(main).cpp -o out/$(main)-cpp
	./out/$(main)-cpp

vlang:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --vlang=1 --outdir out $(main).py	
	v run out/$(main).v
	v out/$(main).v
	mv out/$(main) out/$(main)-v
	./out/$(main)-v

go:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --go=1 --outdir out $(main).py	
	go run out/$(main).go
	go build out/$(main).go 
	mv $(main) out/$(main)-go
	./out/$(main)-go
	
nim:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --nim=1 --outdir out $(main).py
	#nim compile out/run.nim 
	nim compile out/$(main).nim
	cp ./out/$(main) ./out/$(main)-nim 
	./out/$(main)

rust:
	# cargo new fibprj
	# Cargo.toml:
	# [dependencies]
	# anyhow = "1.0"
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --rust=1 --outdir out $(main).py
	cp out/fib.rs fibprj/src/main.rs
	cd fibprj/ && cargo run
	#./fibprj/target/debug/fibprj
python:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --python=1 --outdir out $(main).py
	python3 out/fib.py
julia:
	PYTHONPATH=`pwd`/../../py2many python3 -m py2many --julia=1 --outdir out $(main).py 
	julia out/fib.jl
