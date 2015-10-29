# browse_cif.tcl --
#
# GUI for browsing CIF files.
#
# Copyright (c) 2003, CSIRO Australia
#
# Author:
# Harvey Davies, CSIRO Atmospheric Research
#
# $Id: browse_cif.tcl,v 1.3 2004/02/06 05:40:17 dav480 Exp $


# browse_cif --
#
# Create window with browse_cif menu, etc.
# Usage
#   browse_cif ?<PARENT>? ?<GEOMETRY>?
#
# Example
#   browse_cif .

proc browse_cif {
    args
} {
    eval Cif::main $args
}

namespace eval Cif {
    variable filename ""
    variable is_geog 1;		# Is geographic mode?
    variable mv -7777777;	# missing value
    variable nao "";		# points to NAO

    # main --
    #
    # Create window with browse_cif menu, etc.

    proc main {
	{parent {}}
	{geometry ""}
    } {
	set Cif::filename ""
	set top [create_window cif $parent $geometry CIF]
        frame $top.head
	label $top.head.heading -text "CIF File Browser"
        button $top.head.help -text "Help" -command {::Cif::help}
        pack $top.head.heading -side left
        pack $top.head.help -side right
	frame $top.file
	checkbutton $top.geog -text "Geographic (latitude/longitude) mode" \
	    -variable ::Cif::is_geog -anchor w
	frame $top.mv
	label $top.mv.label -text "Missing value" 
	entry $top.mv.entry -relief sunken -bd 2 -background white -textvariable ::Cif::mv 
	pack $top.mv.label -side left
	pack $top.mv.entry -side left -expand true -fill x
	button $top.file.filename_button -text "File" \
	    -command {set ::Cif::filename {}; ::Cif::select_file; ::Cif::read}
	entry $top.file.filename_entry -relief sunken -bd 2 -background white \
	    -textvariable ::Cif::filename 
	# If the filename is changed by hand then also read file
	bind $top.file.filename_entry <Key-Return> {::Cif::read}
	pack $top.file.filename_button -side left
	pack $top.file.filename_entry -side left -expand true -fill x
	frame $top.do; # All the buttons along the bottom of the menu
	button $top.do.range -text "Range" -command ::Cif::range
	button $top.do.text -text "Text" -command ::Cif::text
	button $top.do.image -text "Image" -command "::Cif::image $top"
	button $top.do.nao -text "NAO" -command {::Cif::create_nao} 
	button $top.do.cancel -text Cancel -command "destroy $top"
	pack \
	    $top.do.range \
	    $top.do.text \
	    $top.do.image \
	    $top.do.nao \
	    $top.do.cancel \
	    -side left \
	    -fill x \
	    -expand true \
	    -padx 1 \
	    -pady 2
	pack \
	    $top.head  \
	    $top.geog  \
	    $top.mv  \
	    $top.file \
	    $top.do    \
	    -expand true -fill x
    }


    # image --

    proc image {
	top
    } {
	set parent $top.do.image
	set w $parent.menu
	destroy $w
	if {[$::Cif::nao rank] > 2} {
	    menu $w
	    menu_entry $w "pseudo-colour image" 2 z
	    menu_entry $w "tiled pseudo-colour image" 3 tile
	    menu_entry $w "RGB image" 3 z
	    $w add command -label cancel -command "destroy $w"
	    $w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	} elseif {[$::Cif::nao rank] > 1} {
	    draw_image 2 z
	} else {
	    Cif::warn "rank < 2"
	}
    }


    # proc menu_entry --
    #
    # add entry to graph or image menu
    # return 1 if entry added, else 0

    proc menu_entry {
	w
	label
	rank_image
	type
    } {
	global Cif::nao
	nap "i = rank(nao) - rank_image"
	set n [[nap "i < 0 ? 0 : prod((shape(nao))(0 .. (i-1) ... 1))"]]
	if {$n > 1} {
	    set label "$n ${label}s"
	}
	if {$n > 0} {
	    $w add command -label $label -command "::Cif::draw_image $rank_image $type"
	    return 1
	}
	return 0
    }

    # warn --
    #
    # Warn user of error

    proc warn {
	message
    } {
	message_window $message -label "Error!" -wait 1
    }


    # info --
    #
    # get info on sds/var
    # flag can be -rank, -shape, -dimension, -coordinate

    proc info {
	flag
	filename
	var_name
    } {
	set command [list nap_get $Cif::netcdf $flag $filename $var_name]
	if {[catch $command result]} {
	    Cif::warn \
		    "info: Error executing following command:\
		    \n$command\
		    \nwhich produced result:\
		    \n$result"
	    set result undefined
	}
	return $result
    }


    # create_nao --
    #
    # Create NAO with name specified by user

    proc create_nao {
    } {
	set name [file rootname [file tail $::Cif::filename]]
	set name [regsub -all {[^_a-zA-Z0-9]} $name _]
	if [regexp {^[0-9]} $name] {
	    set name _$name
	}
	set name [get_entry "NAO name: " -text $name -width 40]
	if {[catch "nap ::$name = ::Cif::nao"]} {
	    Cif::warn "Unable to create NAO"
	} else {
	    message_window "Created NAO $::Cif::nao named '$name'"
	}
    }


    # read --
    #
    # Read variable from CIF file into nao
    # Return 1 if OK, 0 for error

    proc read {
    } {
	global Cif::filename
	global Cif::is_geog
	global Cif::mv
	if {[catch {nap "::Cif::nao = [get_cif -g $is_geog -m $mv $filename]"}]} {
	    Cif::warn "Unable to read CIF file"
	    return 0
	}
	return 1
    }


    # help --
    #
    # Display help.

    proc help {} {
	message_window \
	     "1. Change to non-geographic mode if the coordinate variables are not \
	    \n   latitude & longitude.\
	    \n\
	    \n2. Change the missing value if necessary.\
	    \n\
	    \n3. Select a file using either of the following two methods:\
	    \n   - Press the button on the left to display a file selection widget.\
	    \n   - Type a file name into the entry field on the right. Press 'Enter' key.\
	    \n\
	    \n4. Use the buttons along the bottom to initiate the following actions.\
	    \n   'Range'  button: Display minimum and maximum value.\
	    \n   'Text'   button: Display start of data as text.\
	    \n   'Image'  button: Display data as image(s).\
	    \n   'NAO'    button: Create N-dimensional Array Object.\
	    \n   'Cancel' button: Remove CIF widget." \
	    -label "CIF help"
    }


    # draw_image --
    #
    # View CIF var using plot_nao

    proc draw_image {
	rank
	type
    } {
	global Cif::nao
	if {[catch {plot_nao $nao -rank $rank -type $type} result]} {
	    Cif::warn "Error in plot_nao:\n $result"
	}
    }


    # range --
    #
    # Display range

    proc range {
    } {
	if [catch {nap "r = range(::Cif::nao)"} result] {
	    Cif::warn "Error in nap command:\n $result"
	} else {
	    message_window \
		    "File: $::Cif::filename \
		    \nRange: [$r]" \
		    -label range
	}
    }


    # select_file --
    #
    # Select CIF file
    # Return 1 if OK, 0 for error

    proc select_file {
    } {
	global Cif::filename
	if {$filename == ""} {
	    set filename [open_input_file]
	}
	set status [file readable $filename]
	if {!$status} {
	    Cif::warn "Unable to read file $filename"
	}
	return $status
    }

    # text --
    #
    # Read variable from CIF file into nao & then use specified method for this nao

    proc text {
	{method "all"}
	{c_format ""}
	{max_cols ""}
	{max_lines ""}
    } {
	global Cif::nao
	if [read] {
	    if [regexp c8 [$nao datatype]] {
		default max_cols -1
		default max_lines -1
	    } else {
		default max_cols 50
		default max_lines 100
	    }
	    message_window \
		    "File: $::Cif::filename \
		    \n[$nao $method -format $c_format -columns $max_cols -lines $max_lines]" \
		    -label data
	}
    }

}
