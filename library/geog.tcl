# geog.tcl --
#
# Define NAP functions useful for processing geographic data
#
# Copyright (c) 2001-2004, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: geog.tcl,v 1.4 2004/11/18 03:41:05 dav480 Exp $


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


    # div_wind --
    #
    # divergence of 2D wind = du/dx + dv/dy
    #
    # Usage:
    #	div_wind(u, v)
    #       u is matrix containing zonal      (x-component i.e. from west  to  east) wind
    #       v is matrix containing meridional (y-component i.e. from south to north) wind
    # Units:
    #   u & v are in m/s
    #   Coordinate variables of u & v are latitude (degrees_north) & longitude (degrees_east)
    #   Result is in /s (Hz)
    #
    # Calculated using following:
    #   (du/dP + d(v cos T)/dT) / (r cos T)
    #   where
    #	  T (in place of theta) is latitude in radians
    #	  P (in place of phi)  is longitude in radians
    #	  r is radius of earth in metres
    #	  d means partial derivative

    proc div_wind {
	u
	v
    } {
	nap "latitude  = coordinate_variable(u, 0)"
	nap "longitude = coordinate_variable(u, 1)"
	nap "ncols = nels(longitude)"
	nap "r = 6371e3f32"; # mean radius of earth (m)
	nap "T = latitude / 180p-1f32"
	nap "j = -1 .. ncols"; # Use wrap-around to add column at both start & end
	nap "P = fix_longitude(longitude j) / 180p-1f32"
	nap "u2 = u(,j)"
	nap "v2 = v(,j)"
	nap "c2 = reshape((ncols + 2) # cos(T), shape(u2))"
	$u2 set dim T P
	$v2 set dim T P
	$c2 set dim T P
	$u2 set coo T P
	$v2 set coo T P
	$c2 set coo T P
	nap "result = (derivative(u2, 'P') + derivative(v2 * c2, 'T')) / (r * c2)"
	nap "result = result(, 1 .. ncols)"
	nap "mw = merid_wt(longitude)"
	if {[[nap "abs(latitude(0)) == 90"]]} {
	    $result set value "sum(mw * result(1,))" "0,"
	}
	if {[[nap "abs(latitude(-1)) == 90"]]} {
	    $result set value "sum(mw * result(-2,))" "-1,"
	}
	$result set label "divergence"
	$result set unit "/s"
	$result set dim latitude longitude
	$result set coo latitude longitude
	nap "result"
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


    # vorticity_wind --
    #
    # vertical component of vorticity (from 2D wind) = dv/dx - du/dy
    #
    # Usage:
    #	vorticity_wind(u, v)
    #       u is matrix containing zonal      (x-component i.e. from west  to  east) wind
    #       v is matrix containing meridional (y-component i.e. from south to north) wind
    # Units:
    #   u & v are in m/s
    #   Coordinate variables of u & v are latitude (degrees_north) & longitude (degrees_east)
    #   Result is in /s (Hz)
    # Calculated using following:
    #   (dv/dP - d(u cos T)/dT) / (r cos T)
    #   where
    #	  T (in place of theta) is latitude in radians
    #	  P (in place of phi)  is longitude in radians
    #	  r is radius of earth in metres
    #	  d means partial derivative

    proc vorticity_wind {
	u
	v
    } {
	nap "latitude  = coordinate_variable(u, 0)"
	nap "longitude = coordinate_variable(u, 1)"
	nap "ncols = nels(longitude)"
	nap "r = 6371e3f32"; # mean radius of earth (m)
	nap "T = latitude / 180p-1f32"
	nap "j = -1 .. ncols"; # Use wrap-around to add column at both start & end
	nap "P = fix_longitude(longitude j) / 180p-1f32"
	nap "u2 = u(,j)"
	nap "v2 = v(,j)"
	nap "c2 = reshape((ncols + 2) # cos(T), shape(u2))"
	$u2 set dim T P
	$v2 set dim T P
	$c2 set dim T P
	$u2 set coo T P
	$v2 set coo T P
	$c2 set coo T P
	nap "result = (derivative(v2, 'P') - derivative(u2 * c2, 'T')) / (r * c2)"
	nap "result = result(, 1 .. ncols)"
	nap "mw = merid_wt(longitude)"
	if {[[nap "abs(latitude(0)) == 90"]]} {
	    $result set value "sum(mw * result(1,))" "0,"
	}
	if {[[nap "abs(latitude(-1)) == 90"]]} {
	    $result set value "sum(mw * result(-2,))" "-1,"
	}
	$result set label "vorticity"
	$result set unit "/s"
	$result set coo latitude longitude
	nap "result"
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


# put_gridascii --
#
# Write a matrix to a file in ARC/INFO GRIDASCII format
#
# All cells must be squares of the same size.
# Coordinate variable 0 (usually latitude) can be either ascending or descending.

proc put_gridascii {
    nap_expr
    filename
    {missing_value_string 1e9}
} {
    nap "nao = [uplevel "nap \"$nap_expr\""]"
    if {[$nao rank] != 2} {
	error "put_gridascii: Array is not matrix"
    }
    nap "y = cv(nao,0)"
    if {[$y step] ne "AP"} {
	error "put_gridascii: latitude steps vary in size"
    }
    set ystep [[nap "y(1) - y(0)"]]
    nap "x = cv(nao,1)"
    if {[$x step] ne "AP"} {
	error "put_gridascii: longitude steps vary in size"
    }
    set xstep [[nap "x(1) - x(0)"]]
    if {$xstep <= 0} {
	error "put_gridascii: longitude step size <= 0"
    }
    if {$xstep != abs($ystep)} {
	error "put_gridascii: latitude step size differs from longitude step size"
    }
    nap "row = 0 .. (nels(y) - 1)"
    if {$ystep > 0} {
	nap "row = row(-)"
    }
    set f [open $filename w]
    puts $f "NCOLS [$x nels]"
    puts $f "NROWS [$y nels]"
    puts $f "XLLCORNER [[nap "x(0)       - 0.5 * xstep"]]"
    puts $f "YLLCORNER [[nap "y(row(-1)) - 0.5 * ystep"]]"
    puts $f "CELLSIZE $xstep"
    puts $f "NODATA_VALUE $missing_value_string"
    foreach i [$row value] {
	puts $f [[nap "nao(i,)"] value -missing $missing_value_string]
    }
    close $f
}


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
