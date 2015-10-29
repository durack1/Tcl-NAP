# bin_io.tcl --
#
# Binary input/output procedures oriented to Fortran unformatted IEEE files.
#
# Copyright (c) 1998, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: bin_io.tcl,v 1.13 2002/09/27 05:07:40 dav480 Exp $


# check --
#
# Check for error condition
#
# Usage
#   check <ok> <message>
#	<ok> is expr expression to be evaluated in caller name-space

proc check {
    ok
    message
} {
    if [uplevel expr !($ok)] {
	error $message
    }
    return
}


# size_of --
#
# Number of bytes in  <dataType>
#
# Usage
#   size_of <dataType>
#	<dataType> c8, u8, u16, u32,  i8, i16, i32, f32 or f64

proc size_of {
    dataType
} {
    switch -regexp $dataType {
	{^.8$}		{return 1}
	{^.16$}		{return 2}
	{^.32$}		{return 4}
	{^.64$}		{return 8}
	default		{error "size_of: Illegal dataType"}
    }
}


# get_bin --
#
# Read next binary record
#
# Usage
#   get_bin <dataType> ?<fileId>?
#	<dataType> c8, u8, u16, u32,  i8, i16, i32, f32 or f64
#	<fileId> defaults to "stdin"

proc get_bin {
    dataType
    {fileId stdin}
} {
    nap "s = [size_of $dataType]"
    nap "nbytes1 = [nap_get binary $fileId i32 1]"
    set data       [nap_get binary $fileId $dataType "nbytes1/s"]
    nap "nbytes2 = [nap_get binary $fileId i32 1]"
    check [[nap "nbytes1 == nbytes2"]] "get_bin: Unequal byte counts"
    return $data
}


# put_bin --
#
# Write binary record
#
# Usage
#   put_bin <nap_expr> ?<fileId>?
#	<nap_expr> is NAP expression to be evaluated in caller name-space
#	<fileId> defaults to "stdout"

proc put_bin {
    nap_expr
    {fileId stdout}
} {
    nap "nao = [uplevel "nap \"$nap_expr\""]"
    nap "nbytes = i32([size_of [$nao datatype]] * nels(nao))"
    $nbytes write $fileId
    $nao    write $fileId
    $nbytes write $fileId
    return
}


# get_cif1 --
#
# Read a matrix from cif (Conmap Input File) & return as NAO.
#
# Usage
#   get_cif1 ?<options>?
#	Options
#	    -f <fileId>: defaults to stdin
#	    -g 0|1: 1 (default) for geographic mode, 0 for non-geographic mode
#	    -m <real>: Input missing value (default: -7777777.0)
#	    -um <text>: Units for matrix (default: none)
#	    -ux <text>: Units for x (default: if geographic mode then degrees_east, else none)
#	    -uy <text>: Units for y (default: if geographic mode then degrees_north, else none)
#	    -x <text>: Name of dimension x (default: if geographic mode then longitude else x)
#	    -y <text>: Name of dimension y (default: if geographic mode then latitude else x)

proc get_cif1 {
    args
} {
    set fileId stdin
    set is_geog 1
    set missing_value -7777777
    set name_x ""
    set name_y ""
    set unit_m (NULL)
    set unit_x (NULL)
    set unit_y (NULL)
    set options {
	{-f {set fileId $option_value}}
	{-g {set is_geog $option_value}}
	{-m {set missing_value $option_value}}
	{-um {set unit_m $option_value}}
	{-ux {set unit_x $option_value}}
	{-uy {set unit_y $option_value}}
	{-x {set name_x $option_value}}
	{-y {set name_y $option_value}}
    }
    set i [process_options $options $args]
    check "$i == [llength $args]" "get_cif1: Illegal argument"
    if {$is_geog} {
	default name_x longitude
	default name_y latitude
	if {[string equal $unit_x (NULL)]} {
	    set unit_x degrees_east
	}
	if {[string equal $unit_y (NULL)]} {
	    set unit_y degrees_north
	}
    } else {
	default name_x x
	default name_y y
    }
    nap "ny = [get_bin i32 $fileId]"
    nap "y  = [get_bin f32 $fileId]"
    check [[nap "ny == nels(y)"]] "get_cif1: ny != nels(y)"
    $y set unit $unit_y
    nap "nx = [get_bin i32 $fileId]"
    nap "x  = [get_bin f32 $fileId]"
    check [[nap "nx == nels(x)"]] "get_cif1: nx != nels(x)"
    if {$name_x == "longitude"} {
	nap "x = fix_longitude(x)"
    }
    $x set unit $unit_x
    nap "title = [get_bin c8 $fileId]"
    nap "vec = [get_bin f32 $fileId]"
    nap "mv = 0.9999f32 * f32(missing_value)"
    if [[nap "isnan(mv)"]] {
	nap "is_missing = isnan(vec)"
    } elseif [[nap "mv < 0.0f32"]] {
	nap "is_missing = vec < mv"
    } elseif [[nap "mv > 0.0f32"]] {
	nap "is_missing = vec > mv"
    } else {
	nap "is_missing = vec == mv"
    }
    nap "i = is_missing # (0 .. (nels(vec) - 1))"	;# indices of missing values
    $vec set value "" $i				;# set missing values to NaN
    set m [nap "reshape(vec, ny // nx)"]
    $m set count +1
    $m set coord y x
    set label [string trim [$title value]]
    if {"$label" != ""} {
	$m set label $label
    }
    $m set unit $unit_m
    $m set dim $name_y $name_x
    $m set count 0 -keep
    return $m
}


# get_cif --
#
# Read 1st matrix from cif (Conmap Input File) & return as NAO.
#
# Usage
#   get_cif ?<options>?
#	Options
#	    -f <filename>: Default is "" which is treated as standard input
#	    -g 0|1: 1 (default) for geographic mode, 0 for non-geographic mode
#	    -m <real>: Input missing value (default: -7777777.0)
#	    -um <text>: Units for matrix (default: none)
#	    -ux <text>: Units for x (default: if geographic mode then degrees_east, else none)
#	    -uy <text>: Units for y (default: if geographic mode then degrees_north, else none)
#	    -x <text>: Name of dimension x (default: if geographic mode then longitude else x)
#	    -y <text>: Name of dimension y (default: if geographic mode then latitude else x)
#
# Example reading from file abc.cif with NaN as missing value.
#   nap "in = [get_cif abc.cif -m 1nf32]"

proc get_cif {
    args
} {
    set fileName ""
    set is_geog 1
    set missing_value -7777777
    set name_x ""
    set name_y ""
    set unit_m (NULL)
    set unit_x (NULL)
    set unit_y (NULL)
    set options {
	{-f {set fileName $option_value}}
	{-g {set is_geog $option_value}}
	{-m {set missing_value $option_value}}
	{-um {set unit_m $option_value}}
	{-ux {set unit_x $option_value}}
	{-uy {set unit_y $option_value}}
	{-x {set name_x $option_value}}
	{-y {set name_y $option_value}}
    }
    set i [process_options $options $args]
    check "$i == [llength $args]" "get_cif: Illegal argument"
    if {$is_geog} {
	default name_x longitude
	default name_y latitude
	if {[string equal $unit_x (NULL)]} {
	    set unit_x degrees_east
	}
	if {[string equal $unit_y (NULL)]} {
	    set unit_y degrees_north
	}
    } else {
	default name_x x
	default name_y y
    }
    if {"$fileName" == ""} {
	set fileId stdin
    } else {
	if [catch {set fileId [open $fileName]} message] {
	    error $message
	}
    }
    set result [get_cif1 \
	    -f $fileId \
	    -g $is_geog \
	    -m $missing_value \
	    -um $unit_m \
	    -ux $unit_x \
	    -uy $unit_y \
	    -x  $name_x \
	    -y  $name_y]
    close $fileId
    return $result
}


# get_nao --
#
# Read NAO from (binary) nao file
#
# Usage
#   get_nao ?<fileName>? ?<datatype>? ?<shape>?
#	<fileName> defaults to standard input
#       <datatype> is NAP datatype which can be: character, i8, i16, i32, u8,
#                  u16, u32, f32 or f64 (Default: u8)
#       <shape> is shape of result (Default: number of elements until end)

proc get_nao {
    {fileName ""}
    args
} {
    if {"$fileName" == ""} {
	set fileId stdin
    } else {
	if [catch {set fileId [open $fileName]} message] {
	    error $message
	}
    }
    set result [eval nap_get binary $fileId $args]
    close $fileId
    return $result
}


# put_cif1 --
#
# Write NAO to cif (Conmap Input File)
#
# Usage
#   put_cif1 <nap_expr> ?<fileId>?
#	<nap_expr> is NAP expression to be evaluated in caller name-space
#	<fileId> defaults to stdout

proc put_cif1 {
    nap_expr
    {fileId stdout}
} {
    nap "nao = [uplevel "nap \"f32($nap_expr)\""]"
    set rank [$nao rank]
    check {$rank == 2} "put_cif1: rank is $rank but should be 2"
    foreach dim {0 1} {
	nap "cv = f32(coordinate_variable(nao, dim))"
	nap "ne = i32(nels(cv))"
	put_bin $ne $fileId
	put_bin $cv $fileId
    }
    nap "label = reshape(label(nao) // (80 # ' '), {80})"
    put_bin $label $fileId
    put_bin $nao   $fileId
    return
}


# put_cif --
#
# Write NAO as entire cif (Conmap Input File)
#
# Usage
#   put_cif <nap_expr> ?<fileName>?
#	<nap_expr> is NAP expression to be evaluated in caller name-space
#	<fileName> defaults to standard output

proc put_cif {
    nap_expr
    {fileName ""}
} {
    if {"$fileName" == ""} {
	set fileId stdout
    } else {
	if [catch {set fileId [open $fileName w]} message] {
	    error $message
	}
    }
    nap "nao = [uplevel "nap \"f32($nap_expr)\""]"
    put_cif1 $nao $fileId
    close $fileId
    return
}


# put_nao --
#
# Write NAO to (binary) nao file
#
# Usage
#   put_nao <nap_expr> ?<fileName>?
#	<nap_expr> is NAP expression to be evaluated in caller name-space
#	<fileName> defaults to standard output

proc put_nao {
    nap_expr
    {fileName ""}
} {
    if {"$fileName" == ""} {
	set fileId stdout
    } else {
	if [catch {set fileId [open $fileName w]} message] {
	    error $message
	}
    }
    nap "nao = [uplevel "nap \"$nap_expr\""]"
    $nao write $fileId
    close $fileId
    return
}
