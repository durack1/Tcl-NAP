# caps_nap_menu.tcl --
#
# Copyright (c) 1998-2003, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: caps_nap_menu.tcl,v 1.14 2005/01/16 22:43:46 dav480 Exp $


# caps_nap_menu --

proc caps_nap_menu {
    args
} {
    eval ::NAP::create_main_menu $args
}


namespace eval NAP {

    proc create_main_menu {
	{geometry +0+0}
	{parent "."}
        {font {-family Helvetica -size 10}}
    } {
	set title ""
	if {[info exists ::caps_patchLevel]} {
	    lappend title CAPS$::caps_patchLevel
	}
	if {[info exists ::nap_patchLevel]} {
	    lappend title NAP$::nap_patchLevel
	}
	if {$parent eq "."} {
	    set m ""
	    set p .
	} else {
	    set m [create_window caps_nap_menu $parent $geometry $title]
	    set p $m
	}
	create_logo $m.caps_logo
	frame $m.mbar -relief raised
	menubutton $m.mbar.browse -font $font \
		-text "Browse" -menu $m.mbar.browse.menu -relief raised
	menubutton $m.mbar.command -font $font \
		-text "Command" -menu $m.mbar.command.menu -relief raised
	menubutton $m.mbar.help -font $font \
		-text "Help" -menu $m.mbar.help.menu -relief raised
	create_browse_menu $m.mbar.browse.menu $p SW
	create_command_menu $m.mbar.command.menu
	create_help_menu $m.mbar.help.menu
	pack $m.mbar.browse $m.mbar.command $m.mbar.help -side left -fill y
	pack $m.caps_logo $m.mbar -side left -fill y
	update idletasks
	if {$parent eq "."} {
	    wm geometry . $geometry 
	    wm title . $title 
	}
    }

    # create_logo --
    # Try to create PJT's famous caps logo
    # If something goes wrong with the logo then keep going

    proc create_logo {
	frame
    } {
	if {![info exists ::caps_directory]  ||
		[catch {image create photo -file $::caps_directory/caps.gif} imageName]} {
	    frame $frame -width 0 -height 0
	} else {
	    frame $frame -borderwidth 2 -relief raised
	    set canvas $frame.canvas
	    canvas $canvas \
		    -relief raised \
		    -width 21 \
		    -height 30
	    $canvas create image 2 2 -image $imageName -anchor nw
	    pack $canvas
	    bind $canvas <Button-1> {
		::NAP::display_help \
			$::caps_www_command \
			"CAPS/NAP Web documentation"
	    }
	}
    }


    proc create_browse_menu {
	menu_name
	parent
	geometry
    } {
	set browse [menu $menu_name]
	$browse add command \
		-label "Variables" \
		-command [list browse_var $parent $geometry]
	if {[info exists ::caps_patchLevel]} {
	    $browse add command \
		    -label "AVHRR" \
		    -command [list get_avhrr_gui $parent $geometry]
	    $browse add command \
		    -label "ATSR" \
		    -command [list get_atsr_gui $parent $geometry]
	}
	$browse add command \
		-label "CIF files" \
		-command [list browse_cif $parent $geometry]
	$browse add command \
		-label "HDF" \
		-command [list hdf $parent $geometry]
	$browse add command \
		-label "image files" \
		-command [list vif "" -parent $parent -geometry $geometry]
	$browse add command \
		-label "netCDF" \
		-command [list netcdf $parent $geometry]
    }


    proc create_command_menu {
	menu_name
    } {
	set m [menu $menu_name]
	$m add command -label "History" -command {message_window "[history]" -label history}
	# $m add command -label "Destroy menu bar" -command "destroy .menu"
	$m add command -label "Exit" -command exit
    }


    proc create_help_menu {
	menu_name
    } {
	set help [menu $menu_name]
	$help add command \
		-label "Help for Main CAPS/NAP Menu" \
		-command ::NAP::help_menu
	set label "Tcl/Tk Local documentation"
	if {$::tcl_platform(platform) eq "windows"} {
	    set file "[file dirname [file dirname $::tcl_library]]/doc/ActiveTclHelp.chm"
	    set hh {C:/WINDOWS/hh.exe}
	    if {[file readable $file]  &&  [file readable $hh]} {
		set command [list exec $hh $file &]
		$help add command -label $label \
			-command "[list ::NAP::display_help $command $label]"
	    }
	} else {
	    set file "[file dirname [file dirname $::tcl_library]]/doc/html/index.html"
	    if {[file readable $file]  &&  [info exists ::tcl_www_command]} {
		set command [list exec $::caps_www_browser file://localhost/$file &]
		$help add command -label $label \
			-command "[list ::NAP::display_help $command $label]"
	    }
	}
	if {[info exists ::tcl_www_command]} {
	    set label "Tcl/Tk Web documentation"
	    $help add command -label $label \
		    -command "[list ::NAP::display_help $::tcl_www_command $label]"
	}
	set file [file dirname $::tcl_library]/nap$::nap_version/html/contents.html
	if {[file readable $file]} {
	    set label "NAP Local documentation"
	    set command [list exec $::caps_www_browser file://localhost/$file &]
	    $help add command -label $label \
		    -command "[list ::NAP::display_help $command $label]"
	}
	if {[info exists ::nap_www_command]} {
	    set label "NAP Web documentation"
	    $help add command -label $label \
		    -command "[list ::NAP::display_help $::nap_www_command $label]"
	}
	if {[info exists ::caps_www_command]} {
	    set label "CAPS Web documentation"
	    $help add command -label $label \
		    -command "[list ::NAP::display_help $::caps_www_command $label]"
	}
    }


    proc help_menu {} {
	set file [file dirname $::tcl_library]/nap$::nap_version/html/caps_nap_menu.html
	if {[file readable $file]} {
	    exec $::caps_www_browser file://localhost/$file &
	} else {
	    message_window \
		"The buttons have the following functions:\
		\n'Browse': Select from browsers for:\
		\n    - Tcl variables (including those referencing NAOs)\
		\n    - AVHRR satellite files\
		\n    - ATSR satellite files\
		\n    - CIF files (used mainly in Melbourne)\
		\n    - HDF files\
		\n    - netCDF files\
		\n    - image files (e.g. GIF, JPEG)\
		\n'Command':\
		\n    'History': Display command history in scrolled window.\
		\n    'Exit': Quit.\
		\n'Help': Documentation (including access to Web)." \
		-label "Main Menu Help"
	}
    }


    proc display_help {
	command
	description
    } {
	if [catch $command] {
	    message_window \
		"Unable to access $description using following command:\
		\n$command"
	}
    }

}
