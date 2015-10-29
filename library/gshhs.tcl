# gshhs.tcl --
# 
# Copyright (c) 2006, CSIRO Australia
# Author: Harvey Davies, CSIRO Marine and Atmospheric Research
# $Id: gshhs.tcl,v 1.6 2006/09/15 06:46:50 dav480 Exp $

namespace eval ::NAP {

    # get_gshhs --
    #
    # Read GSHHS shoreline data
    #
    # GSHHS = 'Global Self-consistent Hierarchical High-resolution Shorelines'
    # http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    #
    # resolution: required accuracy (km). This determines which file is used.
    #
    # min_area: Exclude polygons whose area (square km) < min_area (default: 0)
    #
    # max_level: Exclude polygons whose level > max_level (default: 4)
    #     level = 1: land
    #     level = 2: lake
    #     level = 3: island in lake
    #     level = 4: pond in island in lake
    #
    # min_longitude: left boundary of region (default: -180)
    #
    # max_longitude: right boundary of region (default: "min_longitude + 360.0")
    #
    # min_latitude: bottom boundary of region (default: -90)
    #
    # max_latitude: top boundary of region (default: 90)
    #
    # data_dir: directory containing GSHHS files with various resolutions. The default is
    #     $::tcl_library/../nap*.*/data/gshhs unless environment variable GSHHS_DATA_DIR is
    #     defined to overide this.

    proc get_gshhs {
	{resolution 1}
	{min_area 0}
	{max_level 4}
	{min_longitude -180}
	{max_longitude "min_longitude + 360.0"}
	{min_latitude -90}
	{max_latitude  90}
	{data_dir "''"}
    } {
	set proc_name read_gshhs
	nap "xmin = f64(min_longitude)"
	nap "xmax = f64(max_longitude)"
	nap "ymin = f64(min_latitude)"
	nap "ymax = f64(max_latitude)"
	set min_area  [[nap "10.0 * min_area"]]
	set max_level [[nap "max_level"]]
	set resolution [[nap "resolution"]]
	set data_dir [[nap "$data_dir"]]
	if {$data_dir eq ""} {
	    if {[info exists ::env(GSHHS_DATA_DIR)]} {
		set data_dir $::env(GSHHS_DATA_DIR)
	    } else {
		set lib_dir [file dirname $::tcl_library]
		set data_dir [lindex [lsort [glob [file join $lib_dir nap*.* data gshhs]]] end]
	    }
	}
	set old_dir [pwd]
	cd $data_dir 
	set files [glob -nocomplain gshhs_?.b]
	if {$files eq ""} {
	    error "$proc_name: no files matching gshhs_?.b in directory $data_dir"
	}
	set tol(gshhs_f.b)  0
	set tol(gshhs_h.b)  0.2
	set tol(gshhs_i.b)  1
	set tol(gshhs_l.b)  5
	set tol(gshhs_c.b) 25
	set chosen_file gshhs_f.b
	foreach file $files {
	    if {$tol($file) <= $resolution  &&  $tol($file) > $tol($chosen_file)} {
		set chosen_file $file
	    }
	}
	if {![file readable $chosen_file]} {
	    error "$proc_name: cannot read file $chosen_file in directory $data_dir"
	}
	set fs [file size $chosen_file]
	set f [open $chosen_file]
	cd $old_dir 
	nap "xmid = 0.5 * (xmin + xmax)"
	nap "xorigin = xmid - 180.0"
	switch $::tcl_platform(byteOrder) {
	    littleEndian {set method swap}
	    bigEndian    {set method binary}
	    default      {error "$proc_name: Illegal byteOrder"}
	}
	nap "b = emptyBoxedVector = (,){}"
	nap "v1 = {1}"
	nap "mil = 1e-6"
	nap "d360 = 360.0"
	nap "d180 = 180.0"
	while {[tell $f] < $fs} {
	    seek $f 4 current; # id
	    nap "n     =  [nap_get $method $f i32 $v1]"
	    set level    [[nap_get $method $f i32 $v1]]
	    nap "west  = ([nap_get $method $f i32 $v1] * mil - xorigin) % d360 + xorigin"
	    nap "east  = ([nap_get $method $f i32 $v1] * mil - xorigin) % d360 + xorigin"
	    nap "south =  [nap_get $method $f i32 $v1] * mil"
	    nap "north =  [nap_get $method $f i32 $v1] * mil"
	    set area     [[nap_get $method $f i32 $v1]]
	    seek $f 8 current; # version greenwich source
	    nap "xy =     [nap_get $method $f i32 "n // 2"]"
	    set overlap [[nap "east  >= xmin  &&  west  <= xmax
			   &&  north >= ymin  &&  south <= ymax"]]
	    if {$overlap  &&  $level <= $max_level  &&  $area >= $min_area} {
		nap "xy = xy * mil"
		nap "x = (xy(,0) - xorigin) % d360 + xorigin"
		nap "y = xy(,1)"
		nap "xregion = (x > xmax) - (x < xmin)"
		nap "yregion = (y > ymax) - (y < ymin)"
		nap "inside = ! xregion &&  ! yregion"
		nap "i = 0 .. nels(x)-1 ... 1"
		nap "keep = inside(i-1) || inside(i) || inside(i+1)"
		nap "x       = keep # x"
		nap "y       = keep # y"
		nap "xregion = keep # xregion"
		nap "yregion = keep # yregion"
		nap "inside  = keep # inside"
		nap "i = 0 .. nels(x)-2 ... 1"
		nap "clip = inside(i) && !inside(i+1)  ||  !inside(i) && inside(i+1)"
		nap "wrap = !clip  &&  abs(x(i+1) - x(i)) > d180"
		nap "cow = clip || wrap"
		set ncow [[nap "sum cow"]]
		nap "icow = cow # i"
		nap "i0 = 0"
		for {set j 0} {$j < $ncow} {incr j} {
		    nap "icow0 = icow(j)"
		    nap "icow1 = icow0 + 1"
		    nap "x0 = x(icow0)"
		    nap "x1 = x(icow1)"
		    nap "y0 = y(icow0)"
		    nap "y1 = y(icow1)"
		    nap "x10 = x1 - x0"
		    nap "y10 = y1 - y0"
		    nap "xy1 = xy2 = {}"
		    nap "i = i0 .. icow0 ... 1"
		    if {[[nap "wrap(icow0)"]]} {
			if {[[nap "x0 < xmid"]]} {
			    nap "x1new = x1 - d360"
			    nap "x2 = xmin"
			    nap "x3 = xmax"
			} else {
			    nap "x1new = x1 + d360"
			    nap "x2 = xmax"
			    nap "x3 = xmin"
			}
			if {[[nap "x0 == x1new"]]} {
			    nap "xy1 = x(i) /// y(i)"
			} else {
			    nap "y2 = y0 + (x2 - x0) * y10 / (x1new - x0)"
			    nap "xy1 = (x(i) // x2) /// (y(i) // y2)"
			    nap "xy2 = (x3 // x1) /// (y2 // y1)"
			}
		    } else {
			if {[[nap "inside(icow0)"]]} {
			    nap "p = 1.0"
			    switch -- [[nap "xregion(icow1)"]] {
				-1      {nap "p = p <<< (xmin - x0) / x10"}
				 1      {nap "p = p <<< (xmax - x0) / x10"}
			    }
			    switch -- [[nap "yregion(icow1)"]] {
				-1      {nap "p = p <<< (ymin - y0) / y10"}
				 1      {nap "p = p <<< (ymax - y0) / y10"}
			    }
			    nap "x2 = x0 + p * x10"
			    nap "y2 = y0 + p * y10"
			    nap "xy1 = (x(i) // x2) /// (y(i) // y2)"
			} elseif {[[nap "inside(icow1)"]]} {
			    nap "p = 0.0"
			    switch -- [[nap "xregion(icow0)"]] {
				-1      {nap "p = p >>> (xmin - x0) / x10"}
				 1      {nap "p = p >>> (xmax - x0) / x10"}
			    }
			    switch -- [[nap "yregion(icow0)"]] {
				-1      {nap "p = p >>> (ymin - y0) / y10"}
				 1      {nap "p = p >>> (ymax - y0) / y10"}
			    }
			    nap "x2 = x0 + p * x10"
			    nap "y2 = y0 + p * y10"
			    nap "xy2 = (x2 // x1) /// (y2 // y1)"
			}
		    }
		    $xy1 set unit degrees
		    $xy2 set unit degrees
		    nap "b12 = emptyBoxedVector"
		    if {[$xy1 nels] > 0} {
			nap "b12 = b12 , xy1"
		    }
		    if {[$xy2 nels] > 0} {
			nap "b12 = b12 , xy2"
		    }
		    if {[$b12 nels] > 0} {
			nap "b = b , b12"
		    }
		    nap "i0 = icow1"
		}
		nap "i = i0 .. nels(x)-1 ... 1"
		if {[$i nels] > 1} {
		    nap "xy1 = x(i) /// y(i)"
		    $xy1 set unit degrees
		    nap "b = b , xy1"
		}
	    } else {
		unset xy
	    }
	}
	close $f
	nap "b"
    }

}
