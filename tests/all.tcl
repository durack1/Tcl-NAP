# all.tcl --
# 
# Test command 'nap'
#
# Copyright (c) 1999, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: all.tcl,v 1.16 2002/11/27 06:07:21 dav480 Exp $


if {[lsearch [namespace children] ::tcltest] == -1} {
    package require tcltest
    namespace import ::tcltest::*
}

set ::tcltest::testConstraints(have_shared_lib) 0
set ::tcltest::testConstraints(tk) [info exists tk_version]
set ::tcltest::testsDirectory [file dir [info script]]

::tcltest::configure -verbose bp;	# p = Print line for each  passed test
::tcltest::configure -verbose b;	# b = Print line for each  failed test

set data_dir [file join $::tcltest::testsDirectory data]

# if no nap then load nap shared lib from current working directory
if {![info exists nap_version]} {
    if {[info exists env(PACKAGE_SHLIB)]} {
        set shared_lib [file join $::tcltest::workingDirectory $env(PACKAGE_SHLIB)]
        puts "Loading shared library $shared_lib"
        load $shared_lib
	set ::tcltest::testConstraints(have_shared_lib) 1
    } else {
        error "No shared library defined"
    }
}
namespace import ::NAP::*

set files "\
	$env(LIBRARY_DIR)/nap_proc_lib.tcl \
	$env(LIBRARY_DIR)/nap_function_lib.tcl \
	$env(LIBRARY_DIR)/proc_lib.tcl \
	$env(LIBRARY_DIR)/old.tcl \
	[::tcltest::getMatchingFiles]"
foreach file $files {
    puts stdout "[clock format [clock seconds] -format %H:%M:%S] Sourcing file $file"
    if {[catch {source $file} msg]} {
	puts stdout "error processing file $file: $msg"
    }
    puts "[llength [list_naos]] NAOs using [lindex [nap_info bytes] 0] bytes"
}

::tcltest::cleanupTests
