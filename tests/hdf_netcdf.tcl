# hdf_netcdf.tcl --
# 
# sourced by hdf.test which sets hdf_nc = "hdf"
# sourced by netcdf.test which sets hdf_nc = "netcdf"
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: hdf_netcdf.tcl,v 1.10 2002/06/11 00:09:29 dav480 Exp $

switch $hdf_nc {
    hdf		{set ext hdf; set ishdf 1}
    netcdf	{set ext nc;  set ishdf 0}
}

file delete test.$ext

Test $hdf_nc-1.1 "create $hdf_nc file" {
    [nap "a = i16{4 -8}"] $hdf_nc test.$ext abc
    nap_get $hdf_nc -list test.$ext
} {abc
abc:_FillValue}

Test $hdf_nc-1.2 "read $hdf_nc var" {
    [nap_get $hdf_nc test.$ext abc] v
} {4 -8}

Test $hdf_nc-1.3 "$hdf_nc: write another var" {
    $a $hdf_nc test.$ext d
    [nap_get $hdf_nc test.$ext d] v
} {4 -8}

Test $hdf_nc-1.4 "$hdf_nc: re-read 1st var" {
    [nap_get $hdf_nc test.$ext abc] v
} {4 -8}

Test $hdf_nc-1.5 "$hdf_nc: overwrite var" {
    [nap "{1 42}"] $hdf_nc test.$ext abc
    [nap_get $hdf_nc test.$ext abc "0 .. 1"] v
} {1 42}

Test $hdf_nc-1.6 "$hdf_nc: write var with missing values" {
    [nap "{3.6 _ _ -9}"] $hdf_nc test.$ext vec
    [nap_get $hdf_nc test.$ext vec] v
} {3.6 _ _ -9}

Test $hdf_nc-1.7 "$hdf_nc: rewrite var with missing values" {
    [nap "{_ _ 0}"] $hdf_nc test.$ext vec
    [nap_get $hdf_nc test.$ext vec] v
} {_ _ 0 -9}

Test $hdf_nc-1.8 "$hdf_nc: write & read var with non-std missing value" {
    nap "a = {1 0}"
    $a set miss 0
    $a $hdf_nc test.$ext a
    nap "tmp = [nap_get $hdf_nc test.$ext a]"
    subst "[$tmp miss]\n[$tmp]"
} {0
1 _}

unset a tmp
file delete test.$ext

file delete geog.$ext

Test $hdf_nc-2.1 "write $hdf_nc variable with coordinate variables" {
    nap "m = {{2s 4s 0s}{-3s 8s 9s}}"
    nap "i = i16({4 6})"
    $i set unit degrees_north
    nap "j = f32({8 9 9.3})"
    $j set unit degrees_east
    $m set d lat lon
    $m set coo i j
    $m $hdf_nc geog.$ext mat
    lsort [nap_get $hdf_nc -list geog.$ext]
} {lat lat:units lon lon:units mat mat:_FillValue}

Test $hdf_nc-2.2 "read $hdf_nc variable with coordinate variables using subscript" {
    nap in = [nap_get $hdf_nc geog.$ext mat "{1 0},{0 2}"]
    $in v -f %g
} {-3  9
 2  0}

Test $hdf_nc-2.3 "check coordinate variable read from $hdf_nc file" {
    nap "cv = [$in coo lat]"
    list [$cv value] [$cv unit]
} {{6 4} degrees_north}

Test $hdf_nc-2.4 "check coordinate variable read from $hdf_nc file" {
    nap "cv = [$in coo lon]"
    list [$cv value] [$cv unit]
} {{8 9.3} degrees_east}

Test $hdf_nc-2.5 "read $hdf_nc variable with coordinate variables using @@" {
    nap "index = @@{9.3 4}, @@{8.6 9.2}"
    nap "in = [nap_get $hdf_nc geog.$ext mat index]"
    unset index
    $in v -f %g
} {8 9
4 0}

Test $hdf_nc-2.6 "check coordinate variable read from $hdf_nc file" {
    [$in coo lat] v
} {6 4}

Test $hdf_nc-2.7 "check coordinate variable read from $hdf_nc file" {
    [$in coo lon] v
} {9 9.3}

Test $hdf_nc-2.8 "read $hdf_nc variable with coordinate variables" {
    nap in = [nap_get $hdf_nc geog.$ext mat]
    $in v -f %g
} { 2  4  0
-3  8  9}

Test $hdf_nc-2.9 "check coordinate variable read from $hdf_nc file" {
    [$in coo lon] v
} {8 9 9.3}

Test $hdf_nc-2.10 "check coordinate variable read from $hdf_nc file" {
    [$in coo lat] v
} {4 6}

Test $hdf_nc-2.11 "$hdf_nc scaling" {
    [nap "{{100f 110f}{100.5f 109f}}"] $hdf_nc geog.$ext scaled_mat \
    -datatype i16 -scale 0.1 -offset 5
    [nap_get $hdf_nc geog.$ext scaled_mat]
} {100.0 110.0
100.5 109.0}

Test $hdf_nc-2.12 "get data-type of $hdf_nc variable" {
    nap_get $hdf_nc -datatype geog.$ext scaled_mat
} {i16}

Test $hdf_nc-2.13 "get dim names of $hdf_nc variable" {
    nap_get $hdf_nc -dim geog.$ext mat
} {lat lon}

Test $hdf_nc-2.14 "get rank of $hdf_nc variable" {
    nap_get $hdf_nc -rank geog.$ext mat
} {2}

Test $hdf_nc-2.15 "get shape of $hdf_nc variable" {
    nap_get $hdf_nc -shape geog.$ext mat
} {2 3}

Test $hdf_nc-2.16 "get cv 0 of $hdf_nc variable" {
    [nap_get $hdf_nc -coo geog.$ext mat 0]
} {4 6}

Test $hdf_nc-2.17 "get cv 1 of $hdf_nc variable" {
    [nap_get $hdf_nc -coo geog.$ext mat lon]
} {8 9 9.3}

unset cv i in j m
file delete geog.$ext
file delete tmp.$ext

Test $hdf_nc-3.1 "text var" {
    nap "s = `line 1
    line 2`"
    $s set label {Two words}
    $s $hdf_nc tmp.$ext s
    [nap_get $hdf_nc tmp.$ext s]
} {line 1
    line 2}

Test $hdf_nc-3.2 "label" {
    [nap_get $hdf_nc tmp.$ext s] label
} {Two words}

Test $hdf_nc-3.3 "global char att" {
    $s $hdf_nc tmp.$ext :s
    [nap_get $hdf_nc tmp.$ext :s]
} {line 1
    line 2}

Test $hdf_nc-3.4 "normal char att" {
    [nap 'hello world'] $hdf_nc tmp.$ext s:a
    [nap_get $hdf_nc tmp.$ext s:a]
} {hello world}

file delete tmp.$ext

file delete ooc.$ext ragged.$ext

Test $hdf_nc-4.1 "OOC $hdf_nc write" {
    nap "m = {8 # {-1 9 0}}"
    $m set dim y x
    $m set coo "1 .. 8" "{2 5 9}"
    $m $hdf_nc -d f32 -c "1 .. 20, 1 .. 10" ooc.$ext matrix
    catch {nap "in =[nap_get $hdf_nc ooc.$ext matrix]"}
} 0

Test $hdf_nc-4.2 "check input from nap_get $hdf_nc" {
    $in a -c -1
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 20     Name: y         Coordinate-variable: [$in coo 0]
Dimension 1   Size: 10     Name: x         Coordinate-variable: [$in coo 1]
Value:
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _ -1  _  _  9  _  _  _  0  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _
 _  _  _  _  _  _  _  _  _  _"

Test $hdf_nc-4.3 "check cv" {
    [$in coo 0] v
} {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}

Test $hdf_nc-4.4 "check cv" {
    [$in coo 1] v
} {1 2 3 4 5 6 7 8 9 10}

unset m in s

Test $hdf_nc-5.1 "ragged array" {
    file del ragged.$ext
    nap "r = prune{{0 1.5 2 -1}{1n 1 4 1n}{4#1n}{1n 1n 9 -9}}"
    $r set dim i j
    $r $hdf_nc ragged.$ext r -c "{2 4 6 7 9},{1 3 4 8 9}"
    nap "in =[nap_get $hdf_nc ragged.$ext r]"
    $in da
} f64

Test $hdf_nc-5.2 "check in" {
    $in all
} "$in  f64  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 5      Name: i         Coordinate-variable: [$in coo 0]
Dimension 1   Size: 5      Name: j         Coordinate-variable: [$in coo 1]
Value:
 0.0  1.5  2.0 -1.0    _
   _  1.0  4.0    _    _
   _    _    _    _    _
   _    _  9.0 -9.0    _
   _    _    _    _    _"

Test $hdf_nc-5.3 {check cv 0} {[$in coo i]} {2 4 6 7 9}

Test $hdf_nc-5.4 {check cv 1} {[$in coo j]} {1 3 4 8 9}

unset in

Test $hdf_nc-6.1 "OOC $hdf_nc -datatype" {
    nap "v = 3 .. 6"
    $v set dim i
    $v $hdf_nc -datatype f64 ooc.$ext vector
    nap "in = [nap_get $hdf_nc ooc.$ext vector]"
    $in datatype
} f64

Test $hdf_nc-6.2 "check in" {
    $in all
} "$in  f64  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: i         Coordinate-variable: (NULL)
Value:
3 4 5 6"

unset v in

Test $hdf_nc-7.1 "OOC $hdf_nc -datatype -scale" {
    nap "m = f32 {{3.66e9 1.04e9}{-1.04e9 -8.96e9}}"
    $m set di row col
    $m $hdf_nc -datatype i16 -scale 1e8 ooc.$ext short_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext short_matrix]"
    $in datatype
} f32

Test $hdf_nc-7.2 "check in" {
    $in all
}        "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 2      Name: row       Coordinate-variable: (NULL)
Dimension 1   Size: 2      Name: col       Coordinate-variable: (NULL)
Value:
3.7e+09   1e+09
 -1e+09  -9e+09"

unset in

Test $hdf_nc-8.1 "OOC $hdf_nc -datatype -offset" {
    nap "v = 903s .. 906s"
    $v set di ii
    $v $hdf_nc -datatype i8 -offset "ishdf ? -900 : 900" ooc.$ext byte_vector
    nap "in = [nap_get $hdf_nc ooc.$ext byte_vector]"
    $in datatype
} i16

Test $hdf_nc-8.2 "check in" {
    $in all
} "$in  i16  MissingValue: -32768  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: ii        Coordinate-variable: (NULL)
Value:
903 904 905 906"

unset in v

Test $hdf_nc-9.1 "OOC $hdf_nc -coord" {
    $m set di Row Col
    $m $hdf_nc -coordinateVariable "{1 3.5 4 9},{0 -0.1 -0.5 -2}" \
	    ooc.$ext f32_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix]"
    $in datatype
} f32

Test $hdf_nc-9.2 "check cv0" {
    [$in coo 0]
} {1 3.5 4 9}

Test $hdf_nc-9.3 "check cv1" {
    [$in coo 1]
} {0 -0.1 -0.5 -2}

Test $hdf_nc-9.4 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 4      Name: Col       Coordinate-variable: [$in coo 1]
Value:
 3.66e+09  1.04e+09         _         _
-1.04e+09 -8.96e+09         _         _
        _         _         _         _
        _         _         _         _"

unset in

Test $hdf_nc-11.1 "OOC $hdf_nc use cv" {
    $m set coo "{9 1}" "{0 -2}"
    $m $hdf_nc ooc.$ext f32_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix]"
    $in datatype
} f32

Test $hdf_nc-11.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 4      Name: Col       Coordinate-variable: [$in coo 1]
Value:
-1.04e+09  1.04e+09         _ -8.96e+09
-1.04e+09 -8.96e+09         _         _
        _         _         _         _
 3.66e+09         _         _  1.04e+09"

Test $hdf_nc-12.1 "OOC $hdf_nc -subscript" {
    [nap "{{0 1i}}"] $hdf_nc -subscript "@@4, 1 .. 2" ooc.$ext f32_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix]"
    $in datatype
} f32

Test $hdf_nc-12.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 4      Name: Col       Coordinate-variable: [$in coo 1]
Value:
-1.04e+09  1.04e+09         _ -8.96e+09
-1.04e+09 -8.96e+09         _         _
        _         0       Inf         _
 3.66e+09         _         _  1.04e+09"

Test $hdf_nc-13.1 "OOC $hdf_nc -subscript. put scalar" {
    [nap "-3.8"] $hdf_nc -subscript "-2,-1" ooc.$ext f32_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix]"
    $in datatype
} f32

Test $hdf_nc-13.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 4      Name: Col       Coordinate-variable: [$in coo 1]
Value:
-1.04e+09  1.04e+09         _ -8.96e+09
-1.04e+09 -8.96e+09         _         _
        _         0       Inf      -3.8
 3.66e+09         _         _  1.04e+09"

Test $hdf_nc-14.1 "OOC $hdf_nc -subscript. put scalar" {
    [nap "{1.23e9 -0.9e9 2.5e9}"] $hdf_nc -subscript "6,1..3" ooc.$ext f32_matrix
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix]"
    $in datatype
} f32

Test $hdf_nc-14.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 4      Name: Col       Coordinate-variable: [$in coo 1]
Value:
-1.04e+09  1.04e+09         _ -8.96e+09
-1.04e+09 -8.96e+09         _         _
        _  1.23e+09    -9e+08   2.5e+09
 3.66e+09         _         _  1.04e+09"

Test $hdf_nc-15.1 "nap_get $hdf_nc with subscript" {
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix "1,{1 0}"]"
    $in datatype
} f32

Test $hdf_nc-15.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 2      Name: Col       Coordinate-variable: [$in coo]
Value:
-8.96e+09 -1.04e+09"

Test $hdf_nc-15.3 "check cv" {
    [$in coo]
} {-0.1 0}

Test $hdf_nc-16.1 "nap_get $hdf_nc with subscript" {
    nap "in = [nap_get $hdf_nc ooc.$ext f32_matrix ",@@{-9 -0.4 9}"]"
    $in datatype
} f32

Test $hdf_nc-16.2 "check in" {
    $in all
} "$in  f32  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 4      Name: Row       Coordinate-variable: [$in coo 0]
Dimension 1   Size: 3      Name: Col       Coordinate-variable: [$in coo 1]
Value:
-8.96e+09         _ -1.04e+09
        _         _ -1.04e+09
  2.5e+09    -9e+08         _
 1.04e+09         _  3.66e+09"

Test $hdf_nc-16.3 "check cv0" {
    [$in coo 0]
} {1 3.5 4 9}

Test $hdf_nc-16.4 "check cv1" {
    [$in coo 1]
} {-2 -0.5 0}

Test $hdf_nc-17.1 "scaled ragged array" {
    file delete ragged.$ext
    $r $hdf_nc ragged.$ext scaled_ragged -c "{2 4 6 7 9},{1 3 4 8 9}" -da i16 \
	    -sc 1e-2 -off "ishdf ? 99 : -0.99" -range "{-800 998}"
    nap "in =[nap_get $hdf_nc ragged.$ext scaled_ragged]"
    $in da
} f64

Test $hdf_nc-17.2 "check in" {
    $in all -format "%0.2f"
} "$in  f64  MissingValue: NaN  References: 1  Unit: (NULL)
Dimension 0   Size: 5      Name: i         Coordinate-variable: [$in coo 0]
Dimension 1   Size: 5      Name: j         Coordinate-variable: [$in coo 1]
Value:
 0.00  1.50  2.00 -1.00     _
    _  1.00  4.00     _     _
    _     _     _     _     _
    _     _  8.99 -8.99     _
    _     _     _     _     _"

Test $hdf_nc-17.3 {check cv 0} {[$in coo i]} {2 4 6 7 9}

Test $hdf_nc-17.4 {check cv 1} {[$in coo j]} {1 3 4 8 9}

Test $hdf_nc-17.5 "check range" {
    [nap_get $hdf_nc ragged.$ext scaled_ragged:valid_range]
} {-800 998}

unset in m r
file delete ooc.$ext ragged.$ext
