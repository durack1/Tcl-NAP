# stat.tcl --
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: stat.tcl,v 1.14 2002/06/05 00:44:07 dav480 Exp $
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
		nap "result = [STAT::define_stat $X $vr {nap "1nf64 * X"} \
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


    # corr --
    #
    # Pearson Product-moment correlation coefficient
    #
    # Currently X & Y must have rank 1

    proc corr {
	X
	Y
    } {
	nap "X = f64([uplevel nap "\"$X\""])"
	if [[nap "rank(X) != 1"]] {
	    nap "X = reshape(X)"
	}
	nap "Y = f64([uplevel nap "\"$Y\""])"
	if [[nap "rank(Y) != 1"]] {
	    nap "Y = reshape(Y)"
	}
	if [[nap "nels(X) != nels(Y)"]] {
	    error "corr: nels(X) != nels(Y)"
	}
	nap "mask = count(X,0) && count(Y,0)"
	nap "X = mask # X"
	nap "Y = mask # Y"
	nap "n = nels(X)"
	nap "Xmean = sum(X) / n"
	nap "Ymean = sum(Y) / n"
	nap "x = X - Xmean"
	nap "y = Y - Ymean"
	nap "sum(x*y) / sqrt(sum(x*x) * sum(y*y))"
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
	    nap "result = [STAT::define_stat $X $vr {nap "X"} {
		nap "(sort(count(X,0) # X)) (0.5 * (count(X) - 1))"}]"
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
