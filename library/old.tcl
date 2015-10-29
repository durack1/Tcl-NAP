# old.tcl --
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: old.tcl,v 1.7 2002/08/07 08:19:28 dav480 Exp $
#
# Define functions & commands compatible with those defined in old versions of NAP.

# ap --
#
# This provides compatibility with obsolete function "ap"

proc ap {
    {from ""}
    {to ""}
    {step 1}
} {
    if {$from == ""} {
	nap "{}"
    } elseif {$to == ""} {
	if {[$from rank] == 0} {
	    nap "1 .. from"
	} elseif {[$from nels] == 1} {
	    nap "1 .. from(0)"
	} else {
	    nap "v = from // 1"
	    nap "v(0) .. v(1) ... v(2)"
	}
    } else {
	nap "from .. to ... step"
    }
}


# old type conversion functions --
#
# This provides compatibility with obsolete command "nap_hdf"

proc character	x {nap "c8(x)"}
proc byte	x {nap "u8(x)"}
proc short	x {nap "i16(x)"}
proc integer	x {nap "i32(x)"}
proc float	x {nap "f32(x)"}
proc double	x {nap "f64(x)"}


# nap_hdf --
#
# This provides compatibility with obsolete command "nap_hdf"

proc nap_hdf {sub_command args} {
    switch -regexp $sub_command {
        ^g              {uplevel nap_get hdf $args}
        ^l              {uplevel nap_get hdf -list $args}
        default         {return -code error "nap_hdf: Illegal sub_command"}
    }
}

# frequency --
#
# This provides compatibility with obsolete command "nap_hdf"

proc frequency {
    x
    n
    {low 0}
    {delta 1}
} {
    nap "v = low .. (low + (n-1) * delta) ... delta"
    nap "f = # i32(floor(v @ x) <<< (n-1))"
    nap "m = (shape f)(0)"
    nap "f = sum(reshape(f, m // (nels(f) / m)), 1)"
    $f set coo v
    nap "f"
}
