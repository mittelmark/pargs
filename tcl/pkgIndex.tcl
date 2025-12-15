if {![package vsatisfies [package require Tcl] 8.6-]} {return}
package ifneeded pargs 0.0.2 [list source [file join $dir pargs.tcl]]
