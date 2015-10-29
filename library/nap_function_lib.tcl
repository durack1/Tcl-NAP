# nap_function_lib.tcl --
#
# Define various NAP functions
#
# Copyright (c) 2001, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: nap_function_lib.tcl,v 1.16 2002/08/26 06:49:00 dav480 Exp $


namespace eval ::NAP {


    # acof2boxed --
    #
    # read ascii cof (.acof) file & return boxed nao
    # example: nap "i = acof2boxed('abc.acof')"
    #
    # This version returns longitudes in range 0 to 360
    # Need arg to specify that want range -180 to 180

    proc acof2boxed {
	file_name_nao
    } {
	if [catch {set f [open [$file_name_nao value] r]} message] {
	    error $message
	}
	nap "v = f32{0 360}"
	nap "b = (0,0){}";  # create empty boxed nao
	while {[gets $f title] >= 0} {
	    set nchars [gets $f n]
	    if {$nchars <= 0} {
		error "acof2boxed: error reading n"
	    }
	    nap "yold = xold = 1nf32"
	    nap "mat = reshape(0f32, {0 2})"
	    for {set i 0} {$i < $n} {incr i} {
		set nchars [gets $f line]
		if {$nchars <= 0} {
		    error "acof2boxed: error reading line"
		}
		nap "row = f32{$line}"
		if {[$row shape] != 2} {
		    error "acof2boxed: line does not contain exactly 2 numbers"
		}
		nap "x = row(0) % 360f32"
		nap "y = row(1)"
		if [[nap "x - xold > 180f32"]] {
		    nap "xtmp = x - 360f32"
		    nap "y0 = yold - xold * (y - yold) / (xtmp - xold)"
		    nap "mat = mat // (0f32 // y0)"
		    nap "b = b , mat"
		    nap "mat = reshape(360f32 // y0, {1 2})"
		} elseif [[nap "xold - x > 180f32"]] {
		    nap "xtmp = x + 360f32"
		    nap "y0 = yold - xold * (y - yold) / (xtmp - xold)"
		    nap "mat = mat // (360f32 // y0)"
		    nap "b = b , mat"
		    nap "mat = reshape(0f32 // y0, {1 2})"
		}
		nap "mat = mat // (x // y)"
		nap "xold = x"
		nap "yold = y"
	    }
	    nap "b = b , mat"
	}
	close $f
	nap "b"
    }


    # ap --
    #
    # Arithmetic Progression
    #
    # If (to-from)/step is not integer value then round to nearest integer value

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
	    if {[[nap "(to - from) % step != 0"]]} {
		nap "to = from + step * i32(nint(f64(to - from) / step))"
	    }
	    nap "from .. to ... step"
	}
    }


    # color_wheel --
    #
    # nap function giving square containing color wheel.
    #
    # Usage
    #   color_wheel(size, value, background_rgb)
    #     where
    #	size is number of rows & columns (scalar integer)
    #	value is desired "value" level (scalar)
    #	background_rgb is colour outside circle (3-element vector in range 0 to 255)
    #
    # Example
    #   plot_nao "color_wheel(100, 255, 3 # 150)"
    #   This produces a u8 array with shape {3 100 100} with values from 0 to 255.
    #
    # Use coordinate system with x and y ranging from -1 to +1.
    # Circle has radius 1 and its centre is the origin.

    proc color_wheel {
	size value background_rgb
    } {
	nap "n = size - 1"
	nap "i = 0 .. n"
	nap "x = reshape(2f32 * i / n - 1f32, size // size)"
	nap "y = -transpose(x)"
	nap "h = 180p-1 * atan2(y, x)"
	nap "s = sqrt(x * x + y * y)"
	nap "v = reshape(f32(value), shape(h))"
	nap "hsv = h /// s /// v"
	nap "s < 1f32 ? u8(hsv2rgb(hsv)) : transpose(reshape(u8(background_rgb), shape(h) // 3))"
    }


    # cv --
    #
    # Simply alias for long word 'coordinate_variable'.

    proc cv {
	main_nao
	{dim_number 0}
    } {
	nap "coordinate_variable(main_nao, dim_number)"
    }


    # fix_longitude --
    #
    # Adjust elements of longitude vector by adding or subtracting multiple of 360 to ensure:
    #     -180 <= x(0) < 180
    #     0 <= x(i+1)-x(i) < 360
    # Ensure unit is "degrees_east"

    proc fix_longitude {
	longitude
    } {
	nap "x = f64(longitude)"
	nap "x0 = (x(0) + 180.0) % 360.0 - 180.0"
	$x set value x0 0		;# Ensure -180 <= x(0) < 180
	nap "n = nels(x)"
	nap "d = (x(1 .. (n-1)) - x(0 .. (n-2))) % 360.0"
	nap "x = psum(x0 // d)"
	nap "result = [$longitude datatype](x)"
	$result set unit "degrees_east"
	nap "result"
    }


    # fuzzy_ceil --
    #
    # Same as ceil() except that allow for some rounding error

    proc fuzzy_ceil {
	x
	{eps 1e-9}
    } {
	nap "ceil(x - eps)"
    }


    # fuzzy_floor --
    #
    # Same as floor() except that allow for some rounding error

    proc fuzzy_floor {
	x
	{eps 1e-9}
    } {
	nap "floor(x + eps)"
    }


    # gets_matrix --
    #
    # Read text file and return NAO matrix whose rows correspond to the lines in the file.
    # Ignore blank lines and lines whose first non-whitespace character is '#'

    proc gets_matrix {
	file_name_nao
    } {
	if [catch {set f [open [$file_name_nao value] r]} message] {
	    error $message
	}
	set list ""
	while {[gets $f line] >= 0} {
	    set line "[string trim $line] "
	    if {[llength $line] > 0  &&  ![regexp {^#} $line]} {
		lappend list $line
	    }
	}
	close $f
	nap "{$list}"
    }


    # head --
    #
    # If n >= 0 then result is 1st n elements of x, cycling if n > nels(x)
    # If n <  0 then result is 1st nels(x)+n elements of x i.e. drop -n from end

    proc head {
	x
	{n 1}
    } {
	nap "n = n < 0 ? n % nels(x) : n"
	nap "x(0 .. (n-1))"
    }


    # hsv2rgb --
    #
    # nap function to convert hsv to rgb
    #
    # Usage
    #   hsv2rgb(hsv)
    #     where hsv is an array whose leading dimension has size 3.
    #	Layer 0 along this dimension corresponds to hue as an angle in degrees.
    #	  Angles of any sign or magnitude are allowed.
    #	  Red = 0, yellow = 60, green = 120, cyan = 180, blue = -120, magenta = -60.
    #	Layer 1 along this dimension corresponds to saturation in range 0.0 to 1.0.
    #	Layer 2 along this dimension corresponds to "value". This has the same
    #	  range as the RGB values, normally either 0.0 to 1.0 or 0 to 255.
    #	  If you are casting the result to an integer & want a maximum of 255 then
    #	  set the maximum to say 255.999. Otherwise you will get few if any 255s.
    #  The result has the same shape as the argument (hsv).
    #
    # Example
    #   nap "hsv2rgb {180.0 0.5 100.0}"
    #   This produces the vector {50 100 100}
    #
    # See Foley, vanDam, Feiner and Hughes, Computer Graphics
    # Principles and Practice, Second Edition, 1990, ISBN 0201121107
    # page 593. 

    proc hsv2rgb {hsv} {
	nap "hsv = f32(hsv)"
	set r [$hsv rank]
	set c [commas "$r - 1"]
	nap "h = hsv(0$c)"
	nap "s = hsv(1$c)"
	nap "v = hsv(2$c)"
	nap "h = (h % 360f32) / 60f32"
	nap "i = floor(h)"
	nap "f = h - i"
	nap "p = v * (1f32 - s)"
	nap "p = v * (1f32 - s)"
	nap "q = v * (1f32 - (s * f))"
	nap "t = v * (1f32 - (s * (1f32 - f)))"
	nap "i == 0 ? (v /// t /// p) :
	     i == 1 ? (q /// v /// p) :
	     i == 2 ? (p /// v /// t) :
	     i == 3 ? (p /// q /// v) :
	     i == 4 ? (t /// p /// v) :
		      (v /// p /// q)"
    }


    # isMissing --
    #
    # nap function giving 1 if element is missing, 0 if present.

    proc isMissing nao {
	nap "!count(nao,0)"
    }


    # isPresent --
    #
    # nap function giving 0 if element is missing, 1 if present.

    proc isPresent nao {
	nap "count(nao,0)"
    }


    # merid_wt --
    #
    # calculate normalised (so sum weights = 1) meridional weights from longitudes

    proc merid_wt longitude {
	nap "x = f64(longitude)"
	nap "n = nels(x)"
	nap "x1 = x(n-1) // x(0 .. (n-2))"
	nap "x2 = x(1 .. n)"
	nap "w = (x - x1) % 360.0 + (x2 - x) % 360.0"
	nap "n > 1 ? w / sum(w) : {1}"
    }


    # mixed_base --
    #
    # convert scalar value to mixed base (defined by vector)
    #
    # Example
    # Following converts 87 inches to yards, feet & inches, giving the result {2 1 3}
    # nap "mixed_base(87, {3 12})"

    proc mixed_base {
	x
	b
    } {
	if {[$x rank] != 0} {
	    error "mixed_base: 1st argument not scalar"
	}
	if {[$b rank] != 1} {
	    error "mixed_base: 2nd argument (base) not vector"
	}
	nap "result = {}"
	for {set i [expr [$b nels] - 1]} {$i >= 0} {incr i -1} {
	    nap "rem = x % b(i)"
	    nap "x = (x - rem) / b(i)"
	    nap "result = rem // result"
	}
	nap "x // result"
    }


    # outer --
    #
    # tensor outer-product
    #
    # dyad can be name of function or operand
    # In either case there must be two operands/arguments
    # x and y must be vectors
    # Result is cross-product of x and y (applying dyad to each combination of x & y)
    # x & y are the coordinate variables of the result

    proc outer {
	dyad
	y
	{x y}
    } {
	set d [$dyad value]
	nap "ymat = transpose(reshape(y, nels(x) // nels(y)))"
	if {[string is alpha [string index $d 0]]} {
	    nap "result = ${d}(ymat, x)"
	} else {
	    nap "result = ymat $d x"
	}
	$result set coo y x
	nap "result"
    }


    # reverse --
    #
    # nap function to reverse order of items in array

    proc reverse {
	x
	{verb_rank "rank(x)"}
    } {
	set r [$x rank]
	set vr [[nap "verb_rank"]]
	if {$vr == 0} {
	    nap "x"
	} else {
	    set vr [[nap "1 + (vr - 1) % r"]]
	    nap "n = (shape x) ($r - $vr)"
	    nap "i = ap(n - 1, 0, -1)"
	    nap "x([commas "$r - $vr"]i[commas "$vr - 1"])"
	}
    }


    # scaleAxis --

    #   Find suitable values for axis.
    #   Result is the arithmetic progression which:
    #   - is within interval from XSTART to XEND
    #   - has same order (ascending/descending) as {XSTART, XEND}
    #   - has increment equal to element of NICE times a power (-30 .. 30) of 10
    #   - has at least two elements
    #   - has no more than NMAX elements if possible
    #   - has as many elements as possible (Ties are resolved by choosing earlier
    #     element in NICE.)

    # Usage
    #   scaleAxis XSTART XEND ?NMAX? ?NICE?
    #       XSTART: 1st data value
    #       XEND: Final data value
    #       NMAX: Max. allowable number of elements in result (Default: 10)
    #       NICE: Allowable increments (Default: {1 2 5})

    # Example
    #   nap "axis = scaleAxis(-370, 580, 10, {10 20 25 50})"
    # This sets axis to vector {-300 -200 -100 0 100 200 300 400 500}

    proc scaleAxis {
	xstart
	xend
	{nmax 10}
	{nice "{1 2 5}"}
    } {
	nap "nice = f64(nice)"
	nap "xmin = f64(xstart <<< xend)"
	nap "xmax = f64(xstart >>> xend)"
	nap "nice = reshape(nice,61*shape(nice)) * (shape(nice)#(10.0 ** (-30 .. 30)))"
	nap "nv = 1.0 + (fuzzy_floor(xmax/nice) - fuzzy_ceil(xmin/nice))"
	nap "nv = (nv > 1.0) # nv"
	nap "n = 2 >>> max((nv <= (nmax >>> min(nv))) # nv)"
	nap "d = nice(nv @@ n)"
	nap "d = isnan(d) ? 1.0 : d"
	nap "xmin = d * fuzzy_ceil(xmin/d)"
	nap "xmax = xmin + (n-1) * d"
	nap "xstart < xend ? (xmin .. xmax ... d) : (xmax .. xmin ... -d)"
    }


    # scaleAxisSpan --

    #   Find suitable values for axis.
    #   Result is the arithmetic progression which:
    #   - includes the interval from XSTART to XEND
    #   - has same order (ascending/descending) as {XSTART, XEND}
    #   - has increment equal to element of NICE times a power (-30 .. 30) of 10
    #   - has at least two elements 
    #   - has no more than NMAX elements if possible
    #   - has as many elements as possible (Ties are resolved by choosing earlier
    #     element in NICE.)

    # Usage
    #   scaleAxisSpan XSTART XEND ?NMAX? ?NICE?
    #       XSTART: 1st data value
    #       XEND: Final data value
    #       NMAX: Max. allowable number of elements in result (Default: 10)
    #       NICE: Allowable increments (Default: {1 2 5})

    # Example
    #   nap "axis = scaleAxisSpan(-370, 580, 10, {10 20 25 50})"
    # This sets axis to vector {-400 -200 0 200 400 600}

    proc scaleAxisSpan {
	xstart
	xend
	{nmax 10}
	{nice "{1 2 5}"}
    } {
	nap "nice = f64(nice)"
	nap "xmin = f64(xstart <<< xend)"
	nap "xmax = f64(xstart >>> xend)"
	nap "nice = reshape(nice,61*shape(nice)) * (shape(nice)#(10.0 ** (-30 .. 30)))"
	nap "nv = 1.0 + (fuzzy_ceil(xmax/nice) - fuzzy_floor(xmin/nice))"
	nap "nv = (nv > 1.0) # nv"
	nap "n = 2 >>> max((nv <= (nmax >>> min(nv))) # nv)"
	nap "d = nice(nv @@ n)"
	nap "d = isnan(d) ? 1.0 : d"
	nap "xmin = d * fuzzy_floor(xmin/d)"
	nap "xmax = xmin + (n-1) * d"
	nap "xstart < xend ? (xmin .. xmax ... d) : (xmax .. xmin ... -d)"
    }


    # range --
    #
    # Find min & max of any NAO.  Result is 2-element vector containing min & max.

    proc range nao {
	nap "minValue = maxValue = nao"
	while {[$maxValue rank] > 0} {
	    nap "maxValue = max(maxValue)"
	    nap "minValue = min(minValue)"
	}
	nap "minValue // maxValue"
    }


    # tail --
    #
    # If n >= 0 then result is final n elements of x, cycling if n > nels(x)
    # If n <  0 then result is final nels(x)+n elements of x i.e. drop -n from start

    proc tail {
	x
	{n 1}
    } {
	nap "n = n < 0 ? n % nels(x) : n"
	nap "x((-n) .. -1)"
    }


    # zone_wt --
    #
    # calculate normalised (so sum of weights is 1) zonal weights from latitudes

    proc zone_wt latitude {
	nap "s = sin(latitude / 180p-1)"
	nap "n = nels(s)"
	nap "mid = s(0 .. (n-2)) + s(1 .. (n-1))"
	nap "1r4 * ((mid // 2.0) - (-2.0 // mid))"
    }


}
