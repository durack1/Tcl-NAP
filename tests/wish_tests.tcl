# wish_tests.tcl --
# 
# Do those tests which need wish (tk)
#
# Copyright (c) 1999, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: wish_tests.tcl,v 1.26 2004/10/21 03:01:09 dav480 Exp $

puts "\n******* At end click on 'cancel' button in window .win11 *******\n"

# if no nap then load nap shared lib from current working directory
if {![info exists nap_version]} {
    if {[info exists env(PACKAGE_SHLIB)]} {
	set shared_lib [file join [pwd] $env(PACKAGE_SHLIB)]
        puts "Loading shared library $shared_lib"
        load $shared_lib
    } else {
        error "No shared library defined"
    }
    namespace import ::NAP::*
}

# Test plot_nao

source $env(LIBRARY_DIR)/choose_file.tcl
source $env(LIBRARY_DIR)/colour.tcl
source $env(LIBRARY_DIR)/nap_function_lib.tcl
source $env(LIBRARY_DIR)/old.tcl
source $env(LIBRARY_DIR)/pal.tcl
source $env(LIBRARY_DIR)/plot_nao.tcl
source $env(LIBRARY_DIR)/plot_nao_procs.tcl
source $env(LIBRARY_DIR)/proc_lib.tcl
source $env(LIBRARY_DIR)/print_gui.tcl
source $env(LIBRARY_DIR)/select_font.tcl

# xy vector

nap "x = -2p1 .. 2p1 ... 0.01"
$x set unit radians
nap "y = sin x"
$y set coo x
set window [plot_nao y]

# xy matrix

nap "y = y /// 1.0 / cosh x"
$y set coo "" x
set window [plot_nao y -xlabel angle]

# bar vector

nap "x = 1 .. 12"
nap "y = x ** 2"
$y set coo x
set window [plot_nao y -type bar]

# bar matrix

nap "y = y /// 10 * x"
$y set coo "" x
set window [plot_nao y -type bar]

# small z matrix

set window [plot_nao "reshape(0..9, 2#10)"]

# z matrix (function F10 comes from Renka: ACM Algorithm 792)

nap "n = 201"
nap "x = +y = n ... 0f32 .. 1f32"
$x set unit metres
$y set unit seconds
nap "X = reshape(x, 2 # n)"
nap "Y = transpose X"
nap "tmp = sqrt((80f32 * X - 40f32)**2 + (90f32 * Y - 45f32)**2)"
nap "F10 = exp(-0.04f32 * tmp) * cos(0.15f32 * tmp)"
nap "z = F10 /// X // Y"
$F10 set coo y x
set window [plot_nao F10 -palette ""]

# tile 3D z

set window [plot_nao z -type t]

# treat 3D z as RGB layers

set window [plot_nao z]

# land_flag

source $env(LIBRARY_DIR)/geog.tcl
source $env(LIBRARY_DIR)/land.tcl
nap "land_flag_data_dir = '$env(DATA_DIR)/land_flag'"
plot_nao "is_land(-90 .. 90, 0 .. 360, land_flag_data_dir)" -overlay N
set window [plot_nao "is_coast(-90.0 .. 90.0, -180 .. 180, land_flag_data_dir)" -overlay N]

# inPolygon

set s 1r32
nap "xv = 0 .. 8 ... s"
nap "yv = (1 .. 10 ... s)(-)"
nap "x = reshape(xv, nels(yv) // nels(xv))"
nap "y = reshape(nels(xv) # yv, nels(yv) // nels(xv))"
$x set value _ "0 .. 31, 0 .. 31"
$y set value _ "-1 .. -64, 0 .. 63"
$y set coo yv xv
nap "p = {
{7 4 _}
{3 4 _}
{6 7 _}
{6 9 _}
{5 7 _}
{3 7 _}
{2 9 _}
{3 5 _}
{1 2 _}
}"
nap "z = inPolygon(x, y, p)"
set window [plot_nao z]

# scattered2grid

nap "x = 0 .. 25 ... 1r4"
nap "y = 0 .. 20 ... 1r4"
nap "xyz = gets_matrix('../tests/data/xyz.txt')"
nap "grid = scattered2grid(xyz, y, x)"
set window [plot_nao grid]

tkwait window $window

exit
