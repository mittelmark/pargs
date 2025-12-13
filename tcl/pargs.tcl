#!/usr/bin/env tclsh
##############################################################################
#
# Copyright (C) 2025 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################
package provide pargs 0.0.1
package require Tcl 8.6-

oo::class create Pargs {
    variable options
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
    method configure {args} {
        my variable options
        if {[llength $args] == 0} {
            return [array get options]
        } else {
            array set options $args
        }
    }
    method error {msg} {
        my variable options
        if {$options(-color)} {
            puts "\033\[31m$msg\033\[0m"
        } else {
            puts $msg
        }
    }
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
    method help {} {
        my variable options
        puts [string trim $options(-doc)]
        if {$options(-exit)} {
            exit
        }
    }
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
    
