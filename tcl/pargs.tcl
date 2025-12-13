#!/usr/bin/env tclsh
#' ---
#' title: pargs 0.0.1
#' author: Detlef Groth, University of Potsdam, Germany
#' date: 2025-12-13
#' css: mndoc.css
#' style: |
#'    @import url('https://fonts.bunny.net/css?family=Andika&display=swap'); 
#'    @import url('https://fonts.bunny.net/css?family=Ubuntu+Mono&display=swap');
#'    body { font-family: Andika, sans-serif ; }
#'    pre, code { font-family: "Ubuntu Mono", monospaced ; }
#' ---
#' 
#' ## NAME
#'
#' **pargs**  - Tcl package for simple command line parsing.
#'
#' ## SYNOPSIS
#'
#' ```
#' package require Tcl 8.6-
#' package require pargs
#' set pargs [Pargs new -doc DOC-VARr -argv ARGV-VAR -version VERSION-VAR -color true]
#' $pargs usage
#' $pargs help
#' $pargs version
#' $pargs parse type -short --long default
#' $pargs check-options
#' $pargs positional
#' $pargs error
#' ```
#'
#' ## DESCRIPTION
#'
#' **pargs** - can be seen as a simple replacement of other command line parsers.
#' The user still has to declare an help page usually with raw text where the usage line
#' is written on top and thereafter, separated by an empty line follows the explanation
#' of options and arguments. Usally first should be a check of the correct number of arguments,
#' a check for the presence of options, after all supported options are checked,
#' the presence of unsupported options should be done and thereafter the parsing of positional command line options. See the following code.
#' for an example:
#' 
#' ## EXAMPLE
#' 
#' ```
#' set DOC {
#'    Usage: pargs.tcl (-h|--help|-V,--version)
#'              <INFILE> [OUTFILE]
#'              
#'    Options:
#'        -h,--help       display this help page
#'        -V,--version    display the application version
#'        -i,--int        some integer, default: 10
        
#'    Positional Arguments:
#'         INFILE          input file to be parsed
#'         [OUTFILE]       outfile [default: '-']
#'}
#'
#'
#'if {[info exists argv0] && $argv0 eq [info script]} {
#'    set pargs [Pargs new -doc $DOC -argv $argv -version [package present pargs] -color true]
#'    if {[llength $argv] == 0} {
#'        $pargs usage
#'    }
#'    if {[$pargs parse bool -h --help false]} {
#'        $pargs help
#'    }
#'    if {[$pargs parse bool -V --version false]} {
#'        $pargs version; exit
#'    }
#'    
#'    set i [$pargs parse int -i --int 12]
#'    $pargs check-options
#'    set infile [$pargs positional]
#'    if {$infile eq "-"} {
#'        $pargs error "Error: Missing <INFILE> argument!"
#'        $pargs usage
#'    }
#'    set outfile [$pargs positional]
#'    puts "Hi! -i is $i"
#'    puts "infile: $infile - outfile: $outfile"
#'}
#'```
#' 
#' ## API
#'
#' ![](https://kroki.io/plantuml/svg/eNptkFFuwzAIht9zCqtPXpZcoFKlHmFXoA51rGITgd2pmnb3uZtrtdJ44_-AHzhqBskl0uAIVM0HiFfzNZga72YcecuBk46j2RsQgdsv-aPzwq7KmiUk_6zXGdcKKGh-lq8oWof92-KYWCo5MRNCav4JP-19obeWuxXdZW472a5yOgdfBF9qUYTFRvUPYUXaes8GomjzbcNJV5Y8ESc_LXiGQrkXsYa7FZBt5LCbdw-q5eQ4RkiLTRCxGxcFj92oHV3z7-GIaamv_gGF0mlY)
#'
#' ### class Pargs
#' 
##############################################################################
package provide pargs 0.0.1
package require Tcl 8.6-

oo::class create Pargs {
    variable options
    #'
    #' **Pargs new args** 
    #'
    #' > The constructor method. The following arguments are supported:
    #' 
    #' > - _-doc DOC_ - the text string containing the documentation, usage line(s)
    #'   first, remaining help page after an empty line
    #'   - _-argv ARGV_ - the list of arguments, usually the global list _$argv_
    #'   - _-version VERSION_ - the version string for the application, [default: 0.0.0]
    #'   - _-color_ - should error messages being displayed with ANSI red [default: true]
    #'
    #' > Returns: Pargs object
    constructor {args} {
        # default options
        my variable options
        set options(-doc) ""
        set options(-argv) [list]
        set options(-version) "0.0.0"
        set options(-color) true ; # colored error message
        set options(-exit) true  ; # on error
        my configure {*}$args
        set nargs [list]
        foreach arg $options(-argv) {
            if {[regexp {(.+)=(.+)} $arg -> b a]} {
                lappend nargs $b
                lappend nargs $a
            } else {
                lappend nargs $arg
            }
        }
        set options(-argv) $nargs
    }
    #'
    #' _cmd_  **configure** _args_
    #'
    #' > The configure method for the arguments shown in the constructor.
    #' Should be an even number of arguments. If no arguments are given returns
    #' the options array, keys and values.
    method configure {args} {
        my variable options
        if {[llength $args] == 0} {
            return [array get options]
        } else {
            array set options $args
        }
    }
    #'
    #' _cmd_  **error** _msg_
    #'
    #' > Displays the given message in the terminal, in case option -color is
    #' set to true, errors are shown in red foreground color.
    method error {msg} {
        my variable options
        if {$options(-color)} {
            puts "\033\[31m$msg\033\[0m"
        } else {
            puts $msg
        }
    }
    #'
    #' _cmd_  **subcommand** _names_
    #'
    #' > Looks if the first argument is one of the subcommands given in names.
    #' If this is the case returns the command name.
    method subcommand {names} {
        my variable options 
        set cmd [lindex $options(-argv) 0]
        if {[lindex $options(-argv) 0] in $names} {
            set options(-argv) [lrange $options(-argv) 1 end]
            return $cmd
        } else {
            my error "Error: Unkown subcommand, known subcommands are: '[join $names ',']!"
            if {$options(-exit)} {
                exit
            }
            return ""
        }
    }
    #'
    #' _cmd_ ** parse** _type ashort along default_
    #'
    #' > Parses the list of command line options for the presence of either
    #' the given short or long option, if that option is absent the given default 
    #' will be used instead.
    #'
    #' >  Example:
    #' 
    #' > ```
    #' set h [$pargs parse bool -h --help false]
    #' if {$h} { $pargs help }
    #' > ```
    method parse {type ashort along {default ""}} {
        set idx [lsearch -exact $options(-argv) $ashort]
        if {$idx < 0} {
            set idx [lsearch -exact $options(-argv) $along]
        }
        if {$idx >= 0} {
            if {$type in [list bool boolean]} {
                if {$default eq ""} {
                    set options(-argv) [lreplace $options(-argv) $idx $idx]
                    return true
                } elseif {[string is boolean $default]} {
                    set options(-argv) [lreplace $options(-argv) $idx $idx]
                    return true
                } else {
                    my error "Error: Given default for '$ashort' or '$along' is not boolean!"
                    if {$options(-exit)} {
                        exit
                    }
                } 
            } elseif {$type in [list int float string]} {
                if {[llength $options(-argv)] < $idx} {
                    my error "Error: Mising value for option '$ashort' or '$along'!"
                    if {$options(-exit)} {
                        exit
                    }
                } else {
                    set val [lindex $options(-argv) [expr {$idx+1}]]
                    set options(-argv) [lreplace $options(-argv) $idx $idx]
                    set options(-argv) [lreplace $options(-argv) $idx $idx]
                    if {$type eq "init"} {
                        if {[regexp {^[0-9]+$} $val]} {
                            return $val
                        } else {
                            my error "Error: given value for option '$ashort' or '$along' is not an integer!"
                            if {$options(-exit)} {
                                exit
                            }
                        }
                    } elseif {$type eq "float"} {
                        if {[regexp {^[\\.0-9]+$} $val]} {
                            return $val
                        } else {
                            my error "Error: given value for option '$ashort' or '$along' is not a float!"
                            if {$options(-exit)} {
                                exit
                            }
                        }
                    } else {
                        return $val
                    }
                }
            }
        } else {
            return $default
        }
    }
    #'
    #' _cmd_ **check-options**
    #'
    #' > After parsing all flags and options checks for the presence of
    #' options which were not extracted yet., if the exists shows an 
    #' error message and exits the application.
    #'
    method check-options {} {
        my variable options
        set e false
        foreach arg $options(-argv) {
            if {[regexp {^--?\w} $arg]} {
                my error "Error: Wrong option '$arg'!"
                set e true
            }
        }
        if {$e && $options(-exit)} {
            exit
        }
    }
    #'
    #' _cmd_ **positional** _default "-"_
    #'
    #' > Parses the list of command line options for the presence of positional
    #' arguments. Should be done only after all options and flags where parsed.
    #'
    #' >  Example:
    #' 
    #' > ```
    #' set h [$pargs parse bool -h --help false]
    #' if {$h} { $pargs help }
    #' set infile [$pargs positional]
    #' if {$infile eq "-"} {
    #'  $pargs error "Error: Infile not provided!"
    #'  $pargs usage
    #' }
    #' > ```
    method positional {{default "-"}} {
        my variable options
        if {[llength $options(-argv)] > 0} {
            set val [lindex $options(-argv) 0]
            set options(-argv) [lrange $options(-argv) 1 end]
            return $val
        } else {
            return $default
        }
    }
    #'
    #' _cmd_ **usage**
    #'
    #' > Shows the usage line(s) and exits the application if options(-exit) was
    #' set to true.
    #'
    method usage {} {
        my variable options
        set x 0
        foreach line [split [string trim $options(-doc)] "\n"] {
            if {[incr x] > 2 && [regexp {^\s*$} $line]} {
                break
            } else {
                puts $line
            }
        }
        if {$options(-exit)} {
            exit
        }
    }
    #'
    #' _cmd_ **help**
    #'
    #' > Shows the help lines and exits the application if options(-exit) was
    #' set to true.
    #'
    method help {} {
        my variable options
        puts [string trim $options(-doc)]
        if {$options(-exit)} {
            exit
        }
    }
    #'
    #' _cmd_ **version**
    #'
    #' > Returns the version string of the application.
    #'
    #' > Example:
    #'
    #' > ```
    #' puts [$pargs version]
    #' > ```
    method version {} {
        my variable options
        return $options(-version)
    }
}

set DOC {
    Usage: pargs.tcl (-h|--help|-V,--version)
              <INFILE> [OUTFILE]
              
    Options:
        -h,--help       display this help page
        -V,--version    display the application version
        -i,--int        some integer, default: 10
        
    Positional Arguments:
         INFILE          input file to be parsed
         [OUTFILE]       outfile [default: '-']
}


if {[info exists argv0] && $argv0 eq [info script]} {
    set pargs [Pargs new -doc $DOC -argv $argv -version [package present pargs] -color true]
    if {[llength $argv] == 0} {
        $pargs usage
    }
    if {[$pargs parse bool -h --help false]} {
        $pargs help
    }
    if {[$pargs parse bool -V --version false]} {
        $pargs version; exit
    }
    
    set i [$pargs parse int -i --int 12]
    $pargs check-options
    set infile [$pargs positional]
    if {$infile eq "-"} {
        $pargs error "Error: Missing <INFILE> argument!"
        $pargs usage
    }
    set outfile [$pargs positional]
    puts "Hi! -i is $i"
    puts "infile: $infile - outfile: $outfile"
}
    

#' ## SEE ALSO
#'
#'
#' ## CHANGES
#'
#' - 2025-12-13: Version 0.0.1 initial setup
#' 
#' ## AUTHOR
#'
#' The **pargs** package was written by Detlef Groth, University of Potdam, Germany.
#'
#' ## LICENSE AND COPYRIGHT
#'
#' pargs command line argument parser for Tcl/Tk version 0.0.1
#'
#' Copyright (c) 2025  Detlef Groth, E-mail: <dgroth(at)uni(minus)potsdam(dot)de>
#' 
#' BSD License type:
#'
#' Sun Microsystems, Inc. The following terms apply to all files a ssociated
#' with the software unless explicitly disclaimed in individual files. 
#' 
#' The authors hereby grant permission to use, copy, modify, distribute, and
#' license this software and its documentation for any purpose, provided that
#' existing copyright notices are retained in all copies and that this notice
#' is included verbatim in any distributions. No written agreement, license,
#' or royalty fee is required for any of the authorized uses. Modifications to
#' this software may be copyrighted by their authors and need not follow the
#' licensing terms described here, provided that the new terms are clearly
#' indicated on the first page of each file where they apply. 
#'
#' In no event shall the authors or distributors be liable to any party for
#' direct, indirect, special, incidental, or consequential damages arising out
#' of the use of this software, its documentation, or any derivatives thereof,
#' even if the authors have been advised of the possibility of such damage. 
#'
#' The authors and distributors specifically disclaim any warranties,
#' including, but not limited to, the implied warranties of merchantability,
#' fitness for a particular purpose, and non-infringement. This software is
#' provided on an "as is" basis, and the authors and distributors have no
#' obligation to provide maintenance, support, updates, enhancements, or
#' modifications. 
#'
#' RESTRICTED RIGHTS: Use, duplication or disclosure by the government is
#' subject to the restrictions as set forth in subparagraph (c) (1) (ii) of
#' the Rights in Technical Data and Computer Software Clause as DFARS
#' 252.227-7013 and FAR 52.227-19. 
#'
