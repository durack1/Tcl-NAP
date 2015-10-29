# land.tcl --
# 
# Copyright (c) 2002, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: land.tcl,v 1.3 2004/08/12 02:14:31 dav480 Exp $

namespace eval ::NAP {


    # is_land --
    #
    #	Produce i8 (8-bit signed integer) matrix with 1 for land and 0 for sea.
    #
    #   If latitude & longitude arguments are either both vectors (rank = 1) or one is a vector
    #   & other is a scalar (rank = 0) then they are used as the coordinate variables of the
    #   matrix (rank = 2) result. Otherwise the result has the same shape & coordinate variables
    #   as the one of higher rank.

    proc is_land {
	latitude
	longitude
	{data_dir "''"}
    } {
	if {[[nap "nels(data_dir) == 0"]]} {
	    nap "data_dir =
		'[lindex [lsort [glob [file dirname $::tcl_library]/nap*.*/data/land_flag]] end]'"
	}
	nap "err = 0"
	nap "maxlen = 100"
	nap "msg = reshape(' ', maxlen)"
	nap "lat = +f32(latitude)"
	nap "lon = +f32(longitude)"
	nap "slat = shape(lat)"
	nap "slon = shape(lon)"
	set rlat [$lat rank]
	set rlon [$lon rank]
	set rmax [expr $rlat > $rlon ? $rlat : $rlon]
	if {$rmax == 1} {
	    nap "lat = reshape(lat)"
	    nap "lon = reshape(lon)"
	    $lat set unit degrees_north
	    $lon set unit degrees_east
	    nap "nx = nels(lon)"
	    nap "ny = nels(lat)"
	    nap "result = reshape(0i8, ny // nx)"
	    $result set dim latitude longitude
	    $result set coo lat lon
	    nap "lat = transpose(reshape(lat <<< 89.9f32 >>> -89.9f32, nx // ny))"
	    nap "lon = reshape((lon + 180f32) % 360f32 - 180f32,       ny // nx)"
	    land_flag data_dir ny nx lat lon result err msg maxlen
	} else {
	    nap "lat = lat <<< 89.9f32 >>> -89.9f32"
	    nap "lon = (lon + 180f32) % 360f32 - 180f32"
	    if {$rlat < $rmax} {
		if {[[nap "prod(slat == slon((-rlat) .. -1 ... 1))"]]} {
		    nap "lat = reshape(lat, slon)"
		    eval $lat set dim [$longitude dim]
		    eval $lat set coo [$longitude coo]
		} else {
		    error "latitude & longitude have incompatible shapes"
		}
	    }
	    if {$rlon < $rmax} {
		if {[[nap "prod(slon == slat((-rlon) .. -1 ... 1))"]]} {
		    nap "lon = reshape(lon, slat)"
		} else {
		    error "latitude & longitude have incompatible shapes"
		}
	    }
	    nap "present_lat = isPresent(lat)"
	    nap "present_lon = isPresent(lon)"
	    nap "lat = present_lat ? lat : 0.0f32"
	    nap "lon = present_lon ? lon : 0.0f32"
	    nap "result = reshape(0i8, shape(lat))"
	    eval $result set dim [$lat dim]
	    eval $result set coo [$lat coo]
	    land_flag data_dir 1 nels(lat) lat lon result err msg maxlen
	    nap "result = present_lat && present_lon ? result : _"
	}
	if [[nap "err"]] {
	    error "[$msg]"
	}
	nap "result"
    }

    # is_coast --
    #
    #	Produce i8 (8-bit signed integer) matrix with 1 for coast and 0 otherwise.
    #	The arguments (latitude & longitude) are used to define the coordinate variables of the
    #	result.

    proc is_coast {
	latitude
	longitude
	{data_dir "''"}
    } {
	if {[$latitude rank] != 1} {
	    error "rank of latitude != 1"
	}
	if {[$longitude rank] != 1} {
	    error "rank of longitude != 1"
	}
	nap "lat = +f32(latitude)"
	nap "lon = +f32(longitude)"
	$lat set unit degrees_north
	$lon set unit degrees_east
	nap "lat2 = (lat(0) + lat(0) - lat(1)) // lat // (lat(-1) + lat(-1) - lat(-2))"
	nap "lon2 = (lon(0) + lon(0) - lon(1)) // lon // (lon(-1) + lon(-1) - lon(-2))"
	nap "land = is_land(lat2, lon2, $data_dir)"
	nap "se = {{0 1 0}{1 0 1}{0 1 0}}"
	nap "result = (land && !erode(land, se, {1 1}))(1 .. nels(lat), 1 .. nels(lon))"
	$result set dim latitude longitude
	$result set coo lat lon
	nap "result"
    }

}
