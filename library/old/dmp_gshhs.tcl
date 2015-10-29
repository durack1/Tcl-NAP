# gshhs.tcl --
# 
# Copyright (c) 2006, CSIRO Australia
# Author: Harvey Davies, CSIRO Marine and Atmospheric Research
# $Id: gshhs.tcl,v 1.8 2006/11/22 05:55:53 dav480 Exp $

# dmp_gshhs --
#
# Dump gshhs data file
#
# nrecords_max is max. no. records to dump
#
# npoints_max is max. no. points (in each record) to print.
# If too many points then print 1st & last (npoints_max+1)/2 points

proc dmp_gshhs {
    {nrecords_max -1}
    {npoints_max -1}
    {out_file_name ""}
    {gshhs_file_name gshhs_c.b}
    {data_dir "''"}
} {
    set proc_name dmp_gshhs
    set data_dir [[nap "$data_dir"]]
    if {$data_dir eq ""} {
	if {[info exists ::env(GSHHS_DATA_DIR)]} {
	    set data_dir $::env(GSHHS_DATA_DIR)
	} else {
	    set lib_dir [file dirname $::tcl_library]
	    set data_dir [lindex [lsort [glob [file join $lib_dir nap*.* data gshhs]]] end]
	}
    }
    set path [file join $data_dir $gshhs_file_name]
    if {![file readable $path]} {
	error "$proc_name: cannot read file $gshhs_file_name in directory $data_dir"
    }
    set fs [file size $path]
    set f [open $path]
    switch $::tcl_platform(byteOrder) {
	littleEndian {set method swap}
	bigEndian    {set method binary}
	default      {error "$proc_name: Illegal byteOrder"}
    }
    if {$out_file_name eq ""} {
	set fout stdout
    } else {
	set fout [open $out_file_name w]
    }
    nap "v1 = {1}"
    nap "i0 = 0 .. (npoints_max-1)/2"
    nap "i1 = -(npoints_max+1)/2  .. -1"
    for {set nrecords 0} {[tell $f] < $fs  &&  $nrecords != $nrecords_max} {incr nrecords} {
	set id    [[nap_get $method $f i32 $v1]]
	set n     [[nap_get $method $f i32 $v1]]
	set level [[nap_get $method $f i32 $v1]]
	set west  [[nap "[nap_get $method $f i32 $v1] / 1e6"] -f %.6f]
	set east  [[nap "[nap_get $method $f i32 $v1] / 1e6"] -f %.6f]
	set south [[nap "[nap_get $method $f i32 $v1] / 1e6"] -f %.6f]
	set north [[nap "[nap_get $method $f i32 $v1] / 1e6"] -f %.6f]
	set area  [[nap "[nap_get $method $f i32 $v1] / 1e1"] -f %.1f]
	seek $f 8 current; # version greenwich source
	nap "xy =  [nap "[nap_get $method $f i32 "n // 2"] / 1e6"]"
	puts $fout ""
	puts $fout "record $id, $n points, level=$level, area=$area km^2"
	puts $fout "west=$west east=$east south=$south north=$north"
	if {$npoints_max < 0  ||  $n <= $npoints_max} {
	    puts $fout "[[nap "xy"] v -f %.6f]"
	} else {
	    puts $fout "start:"
	    puts $fout "[[nap "xy(i0,)"] v -f %.6f]"
	    puts $fout "end:"
	    puts $fout "[[nap "xy(i1,)"] v -f %.6f]"
	}
    }
    close $f
    if {$fout ne "stdout"} {
	close $fout
    }
}
