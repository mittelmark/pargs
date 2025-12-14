# pargs

Simple command line argument parser implemented in Python, R and Tcl.

These implementations provide easy to use easy parsing of command line options
for terminal  applications in the programming  languages Python, R and Tcl. These
package/  modules can be seen as small version of the full fledged command line
parsers like argparse or docopt. 


- [pargs.tcl - Manual](http://htmlpreview.github.io/?https://github.com/mittelmark/pargs/blob/master/tcl/pargs.html)
- [pargs.py - Manual](http://htmlpreview.github.io/?https://github.com/mittelmark/pargs/blob/master/python/pargs.html)
- [pargs.R - Manual](http://htmlpreview.github.io/?https://github.com/mittelmark/pargs/blob/master/R/pargs.html)

## Installation

There just single files which you need to add to add to your application.

- [pargs.py](python/pargs.py) - place this file beside your application files
and use `import pargs` in your import section.
- [pargs.R](R/pargs.R)   -   place   this   file   into   a   folder   like
`~/R/source/pargs.R` and source it within your application
-  [pargs.tcl](tcl/pargs.tcl) - place this file beside of your application and
use `source [file join [file dirname [info script]] pargs.tcl]` in your application 

## Comparison

| package  | Help Page | Code |  Number of arguments |
|:--------:|:----------|:-----|:--------------------:|
| argparse | automatic | manual | > 3               |
| sys.argv | manual    | manual | <= 3              | 
| docopt   | manual    | automatic | > 3            |
| pargs    | manual    | manual   | > 1            |



## Changes


- 2025-12-13: first public version
- 2025-12-14: R version

## Author and Copyright


@ 2025 - Detlef  Groth,  University  of  Potsdam,  Germany  -
  dgroth(at)uni(minus)potsdam(dot)de

## License


```
BSD 3-Clause License

Copyright (c) 2025, Detlef Groth, University of Potsdam, Germany

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```




