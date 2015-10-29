# read_gshhs --

proc read_gshhs {
    filename
    {min_area 1e5}
    {max_level 2}
    {min_longitude 0}
    {max_longitude "min_longitude + 360.0"}
    {min_latitude -90}
    {max_latitude  90}
} {
    set proc_name read_gshhs
    nap "xmin = f64(min_longitude)"
    nap "xmax = f64(max_longitude)"
    nap "ymin = f64(min_latitude)"
    nap "ymax = f64(max_latitude)"
    set min_area  [[nap "10.0 * min_area"]]
    set max_level [[nap "max_level"]]
    nap "xmid = 0.5 * (xmin + xmax)"
    nap "xorigin = xmid - 180.0"
    switch $::tcl_platform(byteOrder) {
	littleEndian {set method swap}
	bigEndian    {set method binary}
	default      {error "$proc_name: Illegal byteOrder"}
    }
    set fn [[nap "filename"]]
    set fs [file size $fn]
    set f [open $fn]
    nap "b = emptyBoxedVector = (,){}"
    while {[tell $f] < $fs} {
	set id        [[nap_get $method $f i32 "{1}"]]
	set n         [[nap_get $method $f i32 "{1}"]]
	set level     [[nap_get $method $f i32 "{1}"]]
	set west      [[nap_get $method $f i32 "{1}"]]
	set east      [[nap_get $method $f i32 "{1}"]]
	set south     [[nap_get $method $f i32 "{1}"]]
	set north     [[nap_get $method $f i32 "{1}"]]
	set area      [[nap_get $method $f i32 "{1}"]]
	set version   [[nap_get $method $f i32 "{1}"]]
	set greenwich [[nap_get $method $f i16 "{1}"]]
	set source    [[nap_get $method $f i16 "{1}"]]
	nap "xy = [nap_get $method $f i32 "n // 2"]"
	if {$level <= $max_level  &&  $area >= $min_area} {
	    nap "xy = xy * 1.0e-6"
	    nap "x = (xy(,0) - xorigin) % 360.0 + xorigin"
	    nap "y = xy(,1)"
	    nap "xregion = (x > xmax) - (x < xmin)"
	    nap "yregion = (y > ymax) - (y < ymin)"
	    nap "inside = xregion == 0  &&  yregion == 0"
	    nap "i = 0 .. nels(x)-1 ... 1"
	    nap "keep = inside(i-1) || inside(i) || inside(i+1)"
	    nap "x       = keep # x"
	    nap "y       = keep # y"
	    nap "xregion = keep # xregion"
	    nap "yregion = keep # yregion"
	    nap "inside  = keep # inside"
	    nap "i = 0 .. nels(x)-2 ... 1"
	    nap "clip = inside(i) && !inside(i+1)  ||  !inside(i) && inside(i+1)"
	    nap "wrap = !clip  &&  abs(x(i+1) - x(i)) > 180.0"
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
			nap "x1new = x1 - 360.0"
			nap "x2 = xmin"
			nap "x3 = xmax"
		    } else {
			nap "x1new = x1 + 360.0"
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
	}
    }
    close $f
    nap "b"
}

proc try {
    filename
    {min_area 1e5}
    {max_level 2}
    {min_longitude 0}
    {max_longitude "min_longitude + 360.0"}
    {min_latitude -90}
    {max_latitude  90}
    {step 0.5}
} {
    nap "latitude  = f64(-90 .. 90 ... step)"
    nap "longitude = min_longitude + f64(0 .. 360 ... step)"
    nap "m = reshape(0f32, nels(latitude) // nels(longitude))"
    $m set coo latitude longitude
    puts [time {nap "c = read_gshhs(filename, min_area, max_level, min_longitude, max_longitude,
	min_latitude, max_latitude)"}]
    set n [$c nels]
    for {set i 0} {$i < $n} {incr i} {
	nap "xy = open_box(c i)"
	nap "row =  latitude @@ xy(1,)"
	nap "col = longitude @@ xy(0,)"
	nap "col_row = col /// row"
	$m draw col_row 1
    }
    plot_nao m
}

set filename 'gshhs_c.b'
set min_area 1e5
set max_level 2

set min_longitude -180
set max_longitude 180
set min_latitude -90
set max_latitude 90
try $filename $min_area $max_level $min_longitude $max_longitude $min_latitude $max_latitude

set min_longitude 100
set max_longitude 140
set min_latitude 0
set max_latitude 50
try $filename $min_area $max_level $min_longitude $max_longitude $min_latitude $max_latitude
