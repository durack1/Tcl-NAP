# text_io.tcl --
#
# ASCII text input/output procedures.
#
# Copyright (c) 2003, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: text_io.tcl,v 1.1 2003/10/31 00:54:51 dav480 Exp $


# put_text_surfer --
#
# Write file in format used by "Surfer", which is a package developed by Golden Software.
#
# Usage
#   put_text_surfer <nap_expr> ?<filename>? ?<format>?
#	<nap_expr> is NAP expression to be evaluated in caller name-space.
#	<filename> is name of output file. If none then writes to standard output.
#	<format> is C format specification of each output element (Default: "%g").

proc put_text_surfer {
    nap_expr
    {filename ""}
    {format "%g"}
} {
    nap "z = [uplevel "nap \"$nap_expr\""]"
    if {$filename eq ""} {
	set f stdout
    } else {
	set f [open $filename w]
    }
    nap "x = coordinate_variable(z,1)"
    nap "y = coordinate_variable(z,0)"
    if {[[nap "x(0) < x(-1)"]]} {
	set j ""
    } else {
	set j "-"
    }
    if {[[nap "y(0) < y(-1)"]]} {
	set i ""
    } else {
	set i "-"
    }
    if {"$i$j" ne ""} {
	nap "z = z($i,$j)"
    }
    puts $f DSAA
    puts $f [[nap "(shape(z))(-)"]]
    puts $f [[nap "range(x)"] value -format $format]
    puts $f [[nap "range(y)"] value -format $format]
    puts $f [[nap "range(z)"] value -format $format]
    puts $f [$z value -format $format]
    if {$filename ne ""} {
	close $f
    }
    return
}
