# pkgIndex.tcl --
#
# Tcl package index file
# Author: Harvey Davies, CSIRO Atmospheric Research, Melbourne
#
# This file is generated by the "configure" command from
# the following file
# $Id: pkgIndex.tcl.in,v 1.3 2002/10/28 03:32:41 dav480 Exp $
#
# This file is sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.
#
# Note that following apparently redundant command
# set dir {$dir}
# defines another variable called "dir" within uplevel.

package ifneeded nap 3.3 [subst {
    [list load [file join \
	[file dirname [file dirname $dir]] \
	lib \
	libnap3.3.so]]
    set dir {$dir}
    [list source [file join $dir tclIndex]]
    unset dir
}]
