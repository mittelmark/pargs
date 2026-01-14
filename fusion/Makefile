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

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

py-run:
	fut -o py/pargs.py pargs.fu
	python3 py/run-pargs.py

c-run:
	fut -o c/pargs.c pargs.fu
	gcc c/pargs.c c/run-pargs.c -o bin/pargs-c
	./bin/pargs-c

cpp-run:
	fut -o cpp/pargs.cpp pargs.fu
	g++ cpp/pargs.cpp cpp/run-pargs.cpp -o bin/pargs-cpp
	./bin/pargs-cpp

cs-run:
	fut -o cs/pargs.cs pargs.fu
	mcs cs/pargs.cs cs/run-pargs.cs -out:bin/pargs-cs
	mono bin/pargs-cs 	 

d-run:
	fut -o d/pargs.d pargs.fu
	echo "module pargs;" > temp
	cat d/pargs.d >> temp
	mv temp d/pargs.d
	dmd -of=bin/pargs-d d/run-pargs.d d/pargs.d
	./bin/pargs-d

java-run:
	fut -o java/pargs.java pargs.fu
	javac java/RunPargs.java java/Pargs.java
	java -cp java RunPargs
js-run:
	fut -o js/pargs.js pargs.fu
	node js/run-pargs.js
ts-run:
	fut -o ts/pargs.ts pargs.fu
	tsc ts/pargs.ts
	node ts/run-pargs.js
swift-run:
	fut -o swift/pargs.swift pargs.fu
	cp swift/pargs.swift swift/Sources/swift/pargs.swift
	cp swift/run-pargs.swift swift/Sources/swift/swift.swift	
	cd swift && swift build
	cd swift && swift run
	./swift/.build/x86_64-unknown-linux-gnu/debug/swift
