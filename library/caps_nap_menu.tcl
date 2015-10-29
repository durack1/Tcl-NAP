# caps_nap_menu.tcl --
#
# Copyright (c) 1998-2003, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: caps_nap_menu.tcl,v 1.2 2003/07/29 06:33:26 dav480 Exp $


# caps_nap_menu --

proc caps_nap_menu {
    {geometry +0+0}
} {
    ::NAP::create_main_menu $geometry
}


namespace eval NAP {

    proc create_main_menu {
	geometry
    } {
	update idletasks
	wm geometry . $geometry
	if {[info exists ::caps_patchLevel]} {
	    lappend title CAPS$::caps_patchLevel
	}
	if {[info exists ::nap_patchLevel]} {
	    lappend title NAP$::nap_patchLevel
	}
	if {[info exists title]} {
	    wm title . $title
	}
	frame .menu 
        frame .menu.l -borderwidth 2 -relief raised
	create_logo .menu.l.logo
        pack .menu.l.logo
	frame .menu.mbar -relief raised
	menubutton .menu.mbar.browse -text "Browse" -menu .menu.mbar.browse.menu -relief raised
	menubutton .menu.mbar.command -text "Command" -menu .menu.mbar.command.menu -relief raised
	menubutton .menu.mbar.help -text "Help" -menu .menu.mbar.help.menu -relief raised
	create_browse_menu .menu.mbar.browse.menu
	create_command_menu .menu.mbar.command.menu
	create_help_menu .menu.mbar.help.menu
	pack .menu.mbar.browse .menu.mbar.command .menu.mbar.help \
        -side left -fill y
	pack .menu.l .menu.mbar -side left -fill y
	pack .menu -anchor w
    }


    proc create_logo {
	name
    } {
	canvas $name \
		-relief raised \
		-width 21 \
		-height 30
	    #
	    # If something goes wrong with the logo then keep going
	    #
	if {![catch {image create photo -file $::caps_directory/caps.gif} imageName]} {
	    $name create image 2 2 -image $imageName -anchor nw
	    bind $name <Button-1> {
		::NAP::help_www \
			$::caps_www_command \
			"CAPS/NAP Web documentation"
	    }
	}
    }


    proc create_browse_menu {
	menu_name
    } {
	set browse [menu $menu_name]
	$browse add command \
		-label "Variables" \
		-command {browse_var .}
	if {[info exists ::caps_patchLevel]} {
	    $browse add command \
		    -label "AVHRR" \
		    -command {get_avhrr_gui .}
	    $browse add command \
		    -label "ATSR" \
		    -command {get_atsr_gui .}
	}
	$browse add command \
		-label "CIF files" \
		-command {browse_cif .}
	$browse add command \
		-label "HDF" \
		-command {hdf . hdf}
	$browse add command \
		-label "image files" \
		-command {vif}
	$browse add command \
		-label "netCDF" \
		-command {hdf . netcdf}
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
	if {[info exists ::caps_www_command]} {
	    $help add command \
		    -label "CAPS Web documentation" \
		    -command {
			::NAP::help_www \
			    $::caps_www_command \
			    "CAPS Web documentation"
			}
	}

	if {[info exists ::nap_www_command]} {
	    $help add command \
		    -label "NAP Web documentation" \
		    -command {
			::NAP::help_www \
			    $::nap_www_command \
			    "NAP Web documentation"
			}
	}

    }

    proc help_menu {} {
	message_window \
	    "The buttons have the following functions:\
	    \n'CAPS Logo': Connect to CAPS Web documentation.\
	    \n   'Browse': Select from browsers for:\
	    \n                 - Tcl variables\
	    \n                 - AVHRR files\
	    \n                 - ATSR files\
	    \n                 - CIF files\
	    \n                 - HDF files\
	    \n                 - netCDF files\
	    \n                 - image files\
	    \n  'History': Display commands entered from command-line.\
	    \n     'Help': Documentation (including access to Web).\
	    \n     'Exit': Quit."\
	    -label "Main Menu Help"
    }


    proc help_www {command description} {
	if [catch $command] {
	    message_window \
		"Unable to access $description using following command:\
		\n$command"
	}
    }

}
