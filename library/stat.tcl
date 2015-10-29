# stat.tcl --
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: stat.tcl,v 1.20 2004/09/03 05:02:04 dav480 Exp $
#
# Statistics functions

namespace eval ::NAP {


    # STAT contains internal (private) procedures

    namespace eval STAT {

	# define_stat --
	#
	# This generalises vector definition to other ranks

	proc define_stat {
	    X
	    verb_rank
	    scalar_defn
	    vector_defn
	} {
	    nap "X = f64([uplevel 2 nap "\"$X\""])"
	    set r [$X rank]
	    set vr [[nap "(verb_rank) % (r + 1)"]]
	    if {$vr == 0} {
		eval $scalar_defn
	    } elseif {$r == 1} {
		eval $vector_defn
	    } else {
		nap "s = shape X"
		nap "j = r - vr"
		nap "i = 0 .. (r - 1)"
		nap "ii = (i != j) # i"
		nap "result_shape = s(ii)"
		set result_nels [[nap "prod(result_shape)"]]
		nap "result = reshape(0.0, result_nels)"
		nap "XX = transpose(X, ii)"
		nap "XX = reshape(XX, result_nels // (nels(X) / result_nels))"
		for {set k 0} {$k < $result_nels} {incr k} {
		    nap "vector = XX(k,)"
		    $result set value [define_stat $vector 1 $scalar_defn $vector_defn] $k
		}
		nap "result = reshape(result, result_shape)"
		eval $result set coordinate [eval $X coordinate [$ii value]]
		eval $result set dimension  [eval $X dimension  [$ii value]]
		nap "result"
	    }
	}


	# var01 --
	#
	# internal function called by 'sd', 'sd1', 'var' & 'var1'
	# delta is 0 for var/sd and 1 for var1/sd1

	proc var01 {
	    X
	    vr
	    delta
	} {
	    set r [$X rank]
	    if [[nap "vr == 0"]] {
		nap "result = X * {0.0 _}(delta)"
	    } elseif {$r == 1} {
		nap "n = count(X)"
		nap "result = sum((X - sum(X) / n)**2) / (n - delta)"
	    } elseif {$r == 2} {
		if [[nap "vr == r"]] {
		    nap "n = count(X)"
		    nap "s = sum(X)"
		    nap "result = sum((X - s/n)**2, vr) / (n - delta)"
		} else {
		    nap "result = transpose(STAT::var01(transpose(X), r, delta))"
		}
	    } else {
		nap "result = [::NAP::STAT::define_stat $X $vr {nap "1nf64 * X"} \
		    "nap n = count(X); nap sum((X - sum(X) / n)**2) / (n-$delta)"]"
	    }
	    nap "result"
	}

    }


    # am --
    #
    # arithmetic mean

    proc am {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	set r [$X rank]
	set vr [[nap "(verb_rank) % (r + 1)"]]
	if {$vr == 0} {
	    nap "result = X"
	} elseif {$r == 1} {
	    nap "result = sum(X) / count(X)"
	} else {
	    nap "result = sum(X, vr) / count(X, vr)"
	}
	$result set unit [$X unit]
	nap "result"
    }


    # gm --
    #
    # geometric mean

    proc gm {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	set r [$X rank]
	set vr [[nap "(verb_rank) % (r + 1)"]]
	if {$vr == 0} {
	    nap "result = X"
	} elseif {$r == 1} {
	    nap "result = prod(X) ** (1.0 / count(X))"
	} else {
	    nap "result = prod(X, vr) ** (1.0 / count(X, vr))"
	}
	$result set unit [$X unit]
	nap "result"
    }


    # median --

    proc median {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	set r [$X rank]
	set vr [[nap "(verb_rank) % (r + 1)"]]
	if {$vr == 0} {
	    nap "result = X"
	} elseif {$r == 1} {
	    nap "result = (sort(count(X,0) # X)) (0.5 * (count(X) - 1))"
	} else {
	    nap "result = [::NAP::STAT::define_stat $X $vr {nap "X"} {
		nap "(sort(count(X,0) # X)) (0.5 * (count(X) - 1))"}]"
	}
	$result set unit [$X unit]
	nap "result"
    }


    # mode --
    #
    # Handle possibility of multiple modes by defining result as mean of values whose
    # frequency = max(frequency).
    #
    # n is number of class intervals, which is only used for floating-point data types.
    # (Default: 64)

    proc mode {
	X
	{verb_rank "rank(X)"}
	{n 64}
    } {
	nap "X = [uplevel nap "\"$X\""]"
	set r [$X rank]
	set vr [[nap "(verb_rank) % (r + 1)"]]
	if {$vr == 0} {
	    nap "result = X"
	} elseif {$r == 1} {
	    nap "Xmin = min(X)"
	    if {[regexp {^f} [$X datatype]]} {
		nap "step = (max(X) - Xmin) / n"
		nap "f = # i32((X - Xmin) / step + 0.5f32)"
		nap "i = (f == max(f)) # (0 .. (nels(f) - 1))"
		nap "result = f32(am(i) * step + Xmin)"
	    } else {
		nap "f = # (X - Xmin)"
		nap "i = (f == max(f)) # (0 .. (nels(f) - 1))"
		nap "result = f32(am(i) + Xmin)"
	    }
	} else {
	    nap "result = f32([::NAP::STAT::define_stat $X $vr {nap "X"} {nap "mode(X)"}])"
	}
	$result set unit [$X unit]
	nap "result"
    }


    # moving_average --
    #
    # Move window of specified shape by specified step (can vary for each dimension).
    # Result is arithmetic mean of values in each window.
    #
    # 'shape_window' is either a scalar or a vector with an element for each dimension.
    # If it is a scalar then it is treated as a vector with rank(x) identical elements. 
    #
    # Similarly, 'step' is either a scalar or a vector with an element for each dimension.
    # If it is a scalar then it is treated as a vector with rank(x) identical elements. 
    # The value -1 is treated like 1, except that missing values are prepended & appended
    # (along this dimension of x) to produce a result with the same dimension size as x.
    #
    # x can have any rank > 0.

    proc moving_average {
	x
	shape_window
	{step 1}
    } {
	set r [$x rank]
	if {$r < 1} {
	    error "moving_average: x is scalar"
	}
	set unit [$x unit]
	nap "w = i32(reshape(shape_window, r))"
	nap "s = i32(reshape(step, r))"
	set expand 0
	for {set d 0} {$d < $r} {incr d} {
	    if {[$x coo $r] eq "(NULL)"} {
		lappend cv_list ""
	    } else {
		nap "old_cv = + coordinate_variable(x, d)"
		$old_cv set coo; # Ensure no coord. var. to prevent infinite recursion
		nap "cv$d = moving_average(old_cv, w(d), s(d))"
		lappend cv_list [set cv$d]
	    }
	    if {[[nap "s(d)"]] == -1} {
		set expand 1
		nap "n = (shape(x))(d) - 1"
		nap "i$d = ((w(d) / 2) # _) // (0 .. n) // (((w(d) - 1) / 2) # _)"
	    }
	}
	if {$expand} {
	    nap "i = (,){}"
	    for {set d 0} {$d < $r} {incr d} {
		nap "i = i , i$d"
	    }
	    nap "x = x(i)"
	}
	nap "s = abs(s)"
	nap "n = w + (shape(x) - w) / s * s"
	nap "p = (1 .. (r-1) ... 1) //  0"; # permutation of dimensions
	nap "c = count(x,0)";	# 0 if missing, 1 if present
	nap "px = psum(f64 x)";	# partial sum of x
	nap "pc = psum(f64 c)";	# partial sum of c
	for {set d 0} {$d < $r} {incr d} {
	    nap "i1_$d = w(d) .. n(d) ... s(d)"
	    nap "i0_$d = i1_$d - w(d)"
	    nap "px = 0f64 // transpose(px, p)"
	    nap "pc = 0f64 // transpose(pc, p)"
	}
	nap "moving_sum = moving_count = 0f64"
	set jj [expr "1 << $r"]
	for {set j 0} {$j < $jj} {incr j} {
	    set parity [expr "$r % 2"]
	    nap "i = (,){}"
	    for {set d 0} {$d < $r} {incr d} {
		set bit [expr "($j >> $d) & 1"]
		nap "i = i , i${bit}_$d"
		set parity [expr "$parity ^ $bit"]
	    }
	    if {$parity} {
		nap "moving_sum   = moving_sum   - px(i)"
		nap "moving_count = moving_count - pc(i)"
	    } else {
		nap "moving_sum   = moving_sum   + px(i)"
		nap "moving_count = moving_count + pc(i)"
	    }
	}
	nap "result = moving_count > 0 ? moving_sum / moving_count : _"
	eval $result set coo $cv_list
	if {$unit ne "(NULL)"} {
	    $result set unit $unit
	}
	nap "result"
    }


    # rms --
    #
    # root mean square 

    proc rms {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	set r [$X rank]
	set vr [[nap "(verb_rank) % (r + 1)"]]
	if {$vr == 0} {
	    nap "result = X"
	} elseif {$r == 1} {
	    nap "result = sqrt(sum(X*X) / count(X))"
	} else {
	    nap "result = sqrt(sum(X*X, vr) / count(X, vr))"
	}
	$result set unit [$X unit]
	nap "result"
    }


    # sd --
    #
    # standard-deviation (with division by n)

    proc sd {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	nap "vr = (verb_rank) % (rank(X) + 1)"
	nap "v = STAT::var01(X, vr, 0)"
	nap "result = sqrt(v)"
	$result set unit [$X unit]
	nap "result"
    }


    # sd1 --
    #
    # standard-deviation (with division by n-1)

    proc sd1 {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	nap "vr = (verb_rank) % (rank(X) + 1)"
	nap "v = STAT::var01(X, vr, 1)"
	nap "result = sqrt(v)"
	$result set unit [$X unit]
	nap "result"
    }


    # var --
    #
    # variance (with division by n)

    proc var {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	nap "vr = (verb_rank) % (rank(X) + 1)"
	nap "STAT::var01(X, vr, 0)"
    }


    # var1 --
    #
    # variance (with division by n-1)

    proc var1 {
	X
	{verb_rank "rank(X)"}
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	nap "vr = (verb_rank) % (rank(X) + 1)"
	nap "STAT::var01(X, vr, 1)"
    }


}
