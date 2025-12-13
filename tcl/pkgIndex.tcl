if {![package vsatisfies [package require Tcl] 8.6-]} {return}
package ifneeded pargs 0.0.1 [list source [file join $dir pargs.tcl]]
