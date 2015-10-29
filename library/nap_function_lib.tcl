# nap_function_lib.tcl --
#
# Define various NAP functions
#
# Copyright (c) 2001, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: nap_function_lib.tcl,v 1.34 2003/10/28 23:11:05 dav480 Exp $


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


    # area_on_globe --
    #
    # Each element of matrix result is fraction of Earth's surface area

    proc area_on_globe {
	latitude
	longitude
    } {
	nap "latitude = +latitude"
	$latitude set unit degrees_north
	nap "longitude = fix_longitude(longitude)"
	nap "zw = transpose(reshape(zone_wt(latitude), nels(longitude) // nels(latitude)))"
	nap "result = zw * merid_wt(longitude)"
	$result set coo latitude longitude
	nap "result"
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
	nap "hsv = h /// s // v"
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


    # get_gridascii --
    #
    # Read a file in ARC/INFO GRIDASCII format

    proc get_gridascii {
	filename
    } {
	set f [open [$filename value]]
	foreach var_name {ncols nrows xllcorner yllcorner cellsize nodata_value} {
	    if {[gets $f line] <= 0} {
		error "Empty header record"
	    }
	    if {$var_name ne [string tolower [lindex $line 0]]} {
		error "Wrong name in header line"
	    }
	    set $var_name [lindex $line 1]
	}
	nap "z = f32{}"
	while {[gets $f line] > 0} {
	    nap "z = z // f32{$line}"
	}
	close $f
	set ne [expr $nrows * $ncols]
	set na [$z nels]
	if {$na != $ne} {
	    error "Expected to read $ne values, but actually read $na values"
	}
	nap "z = reshape(z, nrows // ncols)"
	nap "xmin = xllcorner + 0.5 * cellsize"
	nap "xmax = xmin + (ncols - 1) * cellsize"
	nap "ymin = yllcorner + 0.5 * cellsize"
	nap "ymax = ymin + (nrows - 1) * cellsize"
	nap "longitude = ncols ... xmin .. xmax"
	nap "latitude  = nrows ... ymax .. ymin"
	$longitude set unit degrees_east
	$latitude  set unit degrees_north
	$z set coo latitude longitude
	$z set miss $nodata_value
	nap "z"
    }


    # gets_matrix --
    #
    # Read text file and return NAO f64 matrix whose rows correspond to the lines in the file.
    # Ignore blank lines and lines whose first non-whitespace character is '#'

    proc gets_matrix {
	file_name_nao
    } {
	if [catch {set f [open [$file_name_nao value] r]} message] {
	    error $message
	}
	while {[gets $f line] >= 0} {
	    set line "[string trim $line] "
	    if {[string length $line] > 0  &&  ![string equal [string index $line 0] #]} {
		if {[info exists ncols]} {
		    if {[llength $line] != $ncols} {
			error "Following line has wrong number of fields\n$line"
		    }
		} else {
		    set ncols [llength $line]
		}
		lappend lines $line
	    }
	}
	close $f
	set nrows [llength $lines]
	nap "result = reshape(0.0, nrows // ncols)"
	for {set i 0} {$i < $nrows} {incr i} {
	    $result set value "{[lindex $lines $i]}" i,
	}
	nap "result"
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
	nap "i == 0 ? (v /// t // p) :
	     i == 1 ? (q /// v // p) :
	     i == 2 ? (p /// v // t) :
	     i == 3 ? (p /// q // v) :
	     i == 4 ? (t /// p // v) :
		      (v /// p // q)"
    }


    # isInsidePolygon --
    #
    # Usage: isInsidePolygon(x, y, poly)
    # Tests whether points defined by x & y are inside polygon defined by poly.
    #
    # poly is normally matrix with 2 columns.  Each row corresponds to a point.
    # Column 0 contains x values & column 1 contains y values.
    # If poly is a vector then it will be reshaped to a matrix with same number of elements.
    #
    # x & y must have shapes which are compatible with each other.
    # Result has the same shape as x or y (whichever has the higher rank)
    #
    # Based on function 'pnpoly' by Randolph Franklin at URL
    # http://astronomy.swin.edu.au/~pbourke/geometry/insidepoly/
    # This page was written by Paul Bourke in November 1987 & is titled
    # 'Determining if a point lies on the interior of a polygon'.
    #
    # Note that we loop for each vertex of the polygon, so this function is only suitable for
    # polygons consisting of fairly small numbers of vertices. But it is efficient if x & y
    # are large arrays.

    proc isInsidePolygon {
	x
	y
	poly
    } {
	if {[$poly rank] == 1} {
	    nap "poly = reshape(poly, (nels(poly) / 2) // 2)"
	}
	if {[[nap "rank(poly) != 2  ||  (shape(poly))(1) != 2"]]} {
	    error "isInsidePolygon: poly has illegal shape"
	}
	set vars {x y poly}
	foreach var $vars {
	    lappend types [eval $$var datatype]
	}
	if {[lsearch $types f32] >= 0  &&  [lsearch $types f64] < 0} {
	    set type f32
	} else {
	    set type f64
	}
	foreach var $vars {
	    nap "$var = type($var)"
	}
	nap "c = 0"
	set n [lindex [$poly shape] 0]
	for {set i 0} {$i < $n} {incr i} {
	    nap "j = i - 1"
	    nap "xpi = poly(i,0)"
	    nap "ypi = poly(i,1)"
	    nap "xpj = poly(j,0)"
	    nap "ypj = poly(j,1)"
	    nap "c = c != ((((ypi <= y) && (y < ypj)) || ((ypj <= y) && (y < ypi)))
		    && (x < (xpj - xpi) * (y - ypi) / (ypj - ypi) + xpi))"
	}
	nap "c"
    }


    # isMember --
    #
    # isMember(a,v) tests whether elements of array a are members of vector v.
    # Result has shape of a.

    proc isMember {
	a
	v
    } {
	nap "count(v @@@ a, 0)"
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


    # magnify_generic --
    #
    # Called by magnify_nearest & magnify_interp

    proc magnify_generic {
	x
	mag_factor
	want_nearest
    } {
	set want_nearest [$want_nearest]
	set rank [$x rank]
	switch [$mag_factor rank] {
	    0 {nap "mag_factor = rank # mag_factor"}
	    1 {}
	    default {error "magnify_generic: mag_factor is not scalar or vector"}
	}
	if {[$mag_factor nels] != $rank} {
	    error "magnify_generic: nels(mag_factor) != rank"
	}
	nap "old_shape = shape(x)"
	nap "i = (,){}"
	for {set d 0} {$d < $rank} {incr d} {
	    nap "n0 = old_shape(d)"
	    nap "n1 = nint(1 + mag_factor(d) * (n0 - 1))"
	    nap "s = n1 ... 0 .. (n0-1)"
	    nap "new_cv$d = (coordinate_variable(x, d))(s)"
	    lappend cv_list [set new_cv$d]
	    if {$want_nearest} {
		nap "s = i32(nint(s))"
	    }
	    nap "i = i , s"
	}
	nap "result = x(i)"
	eval $result set coo $cv_list
	nap "result"
    }


    # magnify_interp --
    #
    # Magnify array by specified factor mag_factor.
    # Contract if mag_factor < 1.0.
    # Border elements magnify only inwards not outwards.
    # mag_factor is either scalar or vector with element for each dimension.
    # Use interpolation to define new values.

    proc magnify_interp {
	x
	mag_factor
    } {
	nap "magnify_generic(x, mag_factor, 0)"
    }


    # magnify_nearest --
    #
    # Magnify array by specified factor mag_factor.
    # Contract if mag_factor < 1.0.
    # Border elements magnify only inwards not outwards.
    # mag_factor is either scalar or vector with element for each dimension.
    # Use nearest neigbours to define new values.
    # Define CVs of result using interpolation.

    proc magnify_nearest {
	x
	mag_factor
    } {
	nap "magnify_generic(x, mag_factor, 1)"
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


    # moving_average --
    #
    # Move window of specified shape by specified step (can vary for each dimension).
    # Result is arithmetic mean of values in each window.
    # x is array (ranks > 2 not supported yet)
    # Both shape_window & step are vectors with an element for each dimension (after
    # reshaping if necessary).
    # Missing values in x are treated as 0 (which is probably not desired!).

    proc moving_average {
	x
	shape_window
	{step 1}
    } {
	set r [$x rank]
	nap "w = i32(reshape(shape_window, r))"
	nap "s = i32(reshape(step, r))"
	switch $r {
	    0 {
		nap "result = x"
	    }
	    1 {
		nap "w = w(0)"
		nap "s = s(0)"
		nap "n = nels(x) / s * s"
		nap "p = 0 // psum(x)"
		nap "result = f64(p(w .. n ... s) - p(0 .. (n-w) ... s)) / w"
	    }
	    2 {
		nap "n = shape(x) / s * s"
		nap "p = 0 // transpose(0 // transpose(psum(x)))"
		nap "i0 = 0 .. (n(0) - w(0)) ... s(0)"
		nap "j0 = 0 .. (n(1) - w(1)) ... s(1)"
		nap "i1 = w(0) .. n(0) ... s(0)"
		nap "j1 = w(1) .. n(1) ... s(1)"
		nap "result = f64(p(i1,j1) + p(i0,j0) - p(i0,j1) - p(i1,j0)) / w(0) / w(1)"
	    }
	    default {
		error "moving_average: Not implemented for rank > 2"
	    }
	}
	nap "result"
    }


    # nub --
    #
    # Result is vector of distinct values in argument (in same order)

    proc nub {
	x
    } {
	nap "v = reshape(x)"
	nap "v = isPresent(v) # v"
	nap "result = v{}"
	while {[$v nels] > 0} {
	    nap "result = result // v(0)"
	    nap "v = (v != v(0)) # v"
	}
	nap "result"
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
	    nap "x([commas "$r - $vr"]-[commas "$vr - 1"])"
	}
    }


    # scaleAxis --
    #
    #   Find suitable values for axis.
    #   Normal result is the arithmetic progression (AP) which:
    #   - has increment equal to an element of NICE times a power (-30 .. 30) of 10
    #   - has elements equal to integer multiple of this increment
    #   - has same order (ascending/descending) as {XSTART, XEND}
    #   - has as many elements as possible, but no more than NMAX
    #   - is within the interval from XSTART to XEND if MODE is 0
    #   - contains  the interval from XSTART to XEND if MODE is 1
    #	If no such AP exists but one or more exist for N > NMAX, then the one with minimum
    #	N is selected and the result is the 2-element vector containing its range.
    #   If no such AP with at least 2 elements exists, then the result is set to an empty vector.
    #
    # Usage
    #   scaleAxis(XSTART, XEND ?,NMAX? ?,NICE? ?,MODE?)
    #       XSTART: 1st data value
    #       XEND: Final data value
    #       NMAX: Max. allowable number of elements in result (Default: 10)
    #       NICE: Allowable increments (Default: {1 2 5})
    #       MODE: Want axis to contain START & XEND? (Default: 0)
    #
    # Example
    #   nap "axis = scaleAxis(-370, 580, 10, {10 20 25 50})"
    # This sets axis to vector {-300 -200 -100 0 100 200 300 400 500}

    proc scaleAxis {
	xstart
	xend
	{nmax 10}
	{nice "{1 2 5}"}
	{mode 0}
    } {
	if {[[nap "xstart == xend"]]} {
	    if {[[nap "mode"]]} {
		nap "x = sort(0 // (xstart == 0 ? 1 : xstart))"
		nap "result = scaleAxis(x(0), x(1), nmax, nice, mode)"
	    } else {
		nap "result = reshape(xstart)"
	    }
	} else {
	    if {[[nap "mode"]]} {
		set f0 fuzzy_floor
		set f1 fuzzy_ceil
	    } else {
		set f0 fuzzy_ceil
		set f1 fuzzy_floor
	    }
	    nap "xmin = f64(xstart <<< xend)"
	    nap "xmax = f64(xstart >>> xend)"
	    nap "p = 10.0 ** (-30 .. 30)"
	    nap "nn = nels(nice)"
	    nap "nice_vec = sort(reshape(f64(nice), nels(p) * nn) * (nn # p))"
	    nap "nv0 =  f0(xmin/nice_vec)"
	    nap "nv1 =  f1(xmax/nice_vec)"
	    nap "nv = 1.0 + (nv1 - nv0)"
	    nap "max32 = 2e9"; # near limit for i32 number
	    nap "mask = abs(nv0) < max32  &&  abs(nv1) < max32"
	    nap "mask = mask  &&  nv > 1.5  &&  nv <= (nmax >>> min(nv))"
	    nap "j = mask @@@ 1"
	    if {[[nap "isMissing(j)"]]} {
		nap "result = xstart // xend"
	    } else {
		nap "d = nice_vec(j)"
		nap "n = i32(nv(j))"
		nap "i = i32(nv0(j) + (0 // (n-1)))"
		nap "n = n > nmax ? 2 : n"
		nap "result = d * (n ... i(xstart > xend) .. i(xstart < xend))"
	    }
	}
	nap "result"
    }


    # scaleAxisSpan --
    #
    #   Find suitable values for axis which includes XSTART & XEND
    #
    # Usage
    #   scaleAxisSpan(XSTART, XEND ?,NMAX? ?,NICE?)
    #       XSTART: 1st data value
    #       XEND: Final data value
    #       NMAX: Max. allowable number of elements in result (Default: 10)
    #       NICE: Allowable increments (Default: {1 2 5})
    #
    # Example
    #   nap "axis = scaleAxisSpan(-370, 580, 10, {10 20 25 50})"
    # This sets axis to vector {-400 -200 0 200 400 600}

    proc scaleAxisSpan {
	xstart
	xend
	{nmax 10}
	{nice "{1 2 5}"}
    } {
	nap "scaleAxis(xstart, xend, nmax, nice, 1)"
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


    # regression --
    #
    # Multiple regression (predicting y from x)
    # If x & y are both vectors (of same length) then result is 2-element vector b which defines
    # predictive equation  y = b(0) + b(1) * x
    # 
    # x & y can be matrices (with columns corresponding to variables)
    # If y is vector then result is vector b which defines
    # predictive equation  y = b(0) + b(1) * x0 + b(2) * x1 + b(3) * x2 + ...
    # If y is matrix then result is matrix with same number of columns (corresponding to variables)

    proc regression {
	x
	y
    } {
	switch [$x rank] {
	    1 {nap "A = transpose(1f32 /// x)"}
	    2 {nap "A = transpose(1f32 // transpose(x))"}
	    default {error "regression: rank of x is not 1 or 2"}
	}
	switch [$y rank] {
	    1 {}
	    2 {}
	    default {error "regression: rank of y is not 1 or 2"}
	}
	nap "solve_linear(A, y)"
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
        nap "c = 2.0 * sign(latitude(1) - latitude(0))"
	nap "0.25 * abs((mid // c) - (-c // mid))"
    }


}
