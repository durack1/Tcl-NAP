# wishrc.tcl --
#
# tcl/tk initialization script (for window shell "wish")
#
# For Windows this should be copied to C:\wishrc.tcl
# For  Unix   this should be copied to ~/.wishrc
#
# Copyright (c) 1999, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: wishrc.tcl,v 1.2 2005/01/13 00:53:06 dav480 Exp $

# Source initialization script for non-windows shell "tclsh" (unless already done).

if {$tcl_platform(platform) eq "unix"} {
    set script ~/.tclshrc
    foreach name {mozilla netscape} {
	if {[catch "exec which $name" caps_www_browser] == 0} {
	    if {[llength $caps_www_browser] == 1} {
		break
	    }
	}
    }
    unset name
} else {
    set script ~/tclshrc.tcl
    foreach caps_www_browser {
	{C:/Program Files/Netscape/Communicator/Program/netscape.exe}
	{C:/Program Files/Internet Explorer/IEXPLORE.EXE}
	{C:/Program Files/Plus!/Microsoft Internet/IEXPLORE.EXE}
	{IEXPLORE.EXE}
    } {
	if {[file exists $caps_www_browser]} {
	    break
	}
    }
}
if {[file exists $script]} {
    source $script
}
unset script

set tcl_www_command \
	"exec {$caps_www_browser} http://aspn.activestate.com/ASPN/Tcl/Reference/ &"
puts "tcl_www_command = $tcl_www_command"

set nap_www_command \
	"exec {$caps_www_browser} http://tcl-nap.sourceforge.net/contents.html &"
puts "nap_www_command = $nap_www_command"

if {[info exists caps_version]} {
    set caps_www_command \
	    "exec {$caps_www_browser} http://www.dar.csiro.au/rs/capshome.html &"
    puts "caps_www_command = $caps_www_command"
}

caps_nap_menu
