# wish_tests.tcl --
# 
# Do those tests which need wish (tk)
#
# Copyright (c) 1999, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: wish_tests.tcl,v 1.15 2002/11/29 06:28:46 dav480 Exp $

puts "\n******* At end click on 'cancel' button in window .win6 *******\n"

# if no nap then load nap shared lib from current working directory
if {![info exists nap_version]} {
    if {[info exists env(PACKAGE_SHLIB)]} {
	set shared_lib [file join [pwd] $env(PACKAGE_SHLIB)]
        puts "Loading shared library $shared_lib"
        load $shared_lib
    } else {
        error "No shared library defined"
    }
}
namespace import ::NAP::*


# Work-around problem with "puts stdout" under windows
# Environment variable TMP_STDOUT is "" under unix but defined under windows

if {[string length $env(TMP_STDOUT)] > 0} {
    file delete $env(TMP_STDOUT)
    set ::tmp_stdout [open $env(TMP_STDOUT) w]
    rename puts old_puts
    proc puts_write {nonewline channelId string} {
	switch $channelId {
	    stderr	-
	    stdout	{set channelId $::tmp_stdout}
	}
	if $nonewline {
	    old_puts -nonewline $channelId $string
	} else {
	    old_puts $channelId $string
	}
    }
    proc puts args {
	set channelId stdout
	set n [llength $args]
	if {$n == 1} {
	    set nonewline 0
	} elseif {$n == 2} {
	    set nonewline [string match -n* $args]
	    if {! $nonewline} {
		set channelId [lindex $args 0]
	    }
	} elseif {$n == 3} {
	    set nonewline 1
	    set channelId [lindex $args 1]
	} else {
	    error "wrong number of arguments"
	}
	puts_write $nonewline $channelId [lindex $args end]
    }
}

# Test plot_nao

source $env(LIBRARY_DIR)/colour.tcl
source $env(LIBRARY_DIR)/nap_function_lib.tcl
source $env(LIBRARY_DIR)/old.tcl
source $env(LIBRARY_DIR)/pal.tcl
source $env(LIBRARY_DIR)/plot_nao.tcl
source $env(LIBRARY_DIR)/plot_nao_procs.tcl
source $env(LIBRARY_DIR)/proc_lib.tcl
source $env(LIBRARY_DIR)/print_gui.tcl

# xy vector

nap "x = -2p1 .. 2p1 ... 0.01"
nap "y = sin x"
$y set coo x
set window [plot_nao y]

# xy matrix

nap "y = y /// 1.0 / cosh x"
$y set coo x
set window [plot_nao y]

# bar vector

nap "x = 1 .. 12"
nap "y = x ** 2"
$y set coo x
set window [plot_nao y -type bar]

# bar matrix

nap "y = y /// 10 * x"
$y set coo x
set window [plot_nao y -type bar]

# small z matrix

set window [plot_nao "reshape(0..9, 2#10)"]

# z matrix (function F10 comes from Renka: ACM Algorithm 792)

nap "n = 201"
nap "x = y = ap_n(0f32, 1f32, n)"
nap "X = reshape(x, 2 # n)"
nap "Y = transpose X"
nap "tmp = sqrt((80f32 * X - 40f32)**2 + (90f32 * Y - 45f32)**2)"
nap "F10 = exp(-0.04f32 * tmp) * cos(0.15f32 * tmp)"
$F10 set coo x y
set window [plot_nao F10 -palette ""]

# z 3D

set window [plot_nao "F10 /// X // Y"]

tkwait window $window

if [info exists ::tmp_stdout] {
    close $::tmp_stdout
}

exit
