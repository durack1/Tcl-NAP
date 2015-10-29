# print_gui.tcl --
# 
# Copyright (c) 2002, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: print_gui.tcl,v 1.7 2003/05/16 06:47:03 dav480 Exp $
#
# GUI interface to package "printer"
#
# Usage
#
#   ::Print_gui::init
#	Must be called at start
#
#   ::Print_gui::widget <COMMAND> <PARENT>
#	Main procedure which creates widget, etc.
#       <COMMAND>: command to create postScript string
#           This command returns postScript string as result & is called as follows:
#               eval <COMMAND> <PAPER_HEIGHT> <PAPER_WIDTH> <MAXPECT>
#                   <PAPER_HEIGHT>: e.g. "297m" (mm) for A4
#                   <PAPER_WIDTH>:  e.g. "210m" (mm) for A4
#                   <MAXPECT>: 1 = expand/contract to fit page
#       <PARENT>: parent window (default: ".")
#
#   ::Print_gui::print <COMMAND>
#	Allows printing without using GUI (useful for batch mode)
#
#   ::Print_gui::write <COMMAND>
#	Allows writing of postScript to file without using GUI (useful for batch mode)

namespace eval Print_gui {

    variable filename "tmp.ps";	# name of output postScript file
    variable maxpect 0;		# Expand PostScript to fit page?
    variable paperheight 297m;	# A4
    variable paperwidth  210m;	# A4
    variable printer_name "";	#


    # init --
    #
    # Load package 'printer'.
    # Create namespace 'Print_gui'.
    # Define ::Print_gui::printer_name.

    proc init {
    } {
	global ::Print_gui::printer_name
	package require printer
	if {$printer_name != ""} {
	} elseif {[lsearch [array names ::env] PRINTER] >= 0} {
	    set printer_name $::env(PRINTER)
	} else {
	    set printers [printer list]
	    if {[llength $printers] > 0} {
		set printer_name [lindex $printers 0]
	    }
	}
    }


    # widget --

    proc widget {
	create_ps_command
	{parent .}
    } {
	if {$parent == "."} {
	    set f .print
	} else {
	    set f $parent.print
	}
	destroy $f
	toplevel $f -relief raised -borderwidth 4
	wm geometry $f +[winfo rootx $parent]+[winfo rooty $parent]
	#
	label $f.width_label -text "paper width"
	entry $f.width_entry -textvariable ::Print_gui::paperwidth
	grid x $f.width_label $f.width_entry -sticky we
	#
	label $f.height_label -text "paper height"
	entry $f.height_entry -textvariable ::Print_gui::paperheight
	grid x $f.height_label $f.height_entry -sticky we
	#
	checkbutton $f.scale -text "Scale to fill page?" \
		-variable ::Print_gui::maxpect -anchor w
	grid $f.scale -column 1 -sticky we
	#
	button $f.select_printer_button -text "select printer" \
		-command "::Print_gui::select_printer $parent $f"
	grid $f.select_printer_button -sticky we
	#
	button $f.print_button -text print -command "::Print_gui::print $create_ps_command"
	label $f.print_label -text "using printer "
	entry $f.printer -textvariable ::Print_gui::printer_name
	grid $f.print_button $f.print_label $f.printer -sticky we
	#
	button $f.write_button -text write -command "::Print_gui::write $create_ps_command"
	label $f.write_label -text "PostScript file named "
	entry $f.write_file -textvariable ::Print_gui::filename
	grid $f.write_button $f.write_label $f.write_file -sticky we
	#
	button $f.cancel -text cancel -command "destroy $f"
	grid $f.cancel -sticky we
    }


    # select_printer --

    proc select_printer {
	parent
	f
    } {
	set printers [printer list]
	if {[llength $printers] == 0} {
	    error "select_printer: No known printers"
	} else {
	    if {$parent == "."} {
		set m .printer_menu
	    } else {
		set m $parent.printer_menu
	    }
	    if {![winfo exists $m]} {
		menu $m -tearoff 0 -background white
		foreach p $printers {
		    $m add radiobutton -label $p -value $p \
			    -variable ::Print_gui::printer_name
		}
	    }
	    set x [winfo rootx $f]
	    set y [winfo rooty $f]
	    tk_popup $m $x $y
	}
    }

    # print --
    #
    # Send postScript to printer

    proc print {
	args
    } {
	global ::Print_gui::maxpect
	global ::Print_gui::paperwidth
	global ::Print_gui::paperheight
	global ::Print_gui::printer_name
	if {[lsearch -exact [printer list] $printer_name] < 0} {
	    error "print_graph: Illegal printer name"
	} else {
	    printer send \
		    -printer $printer_name \
		    -data [eval [join $args] $paperheight $paperwidth $maxpect]
	}
    }

    # write --
    #
    # Write postScript to file

    proc write {
	args
    } {
	global ::Print_gui::filename;		# name of output postScript file
	global ::Print_gui::maxpect
	global ::Print_gui::paperwidth
	global ::Print_gui::paperheight
	if {$filename != ""} {
	    set f [open $filename w]
	    puts -nonewline $f [eval [join $args] $paperheight $paperwidth $maxpect]
	    close $f
	} else {
	    error "filename for output PostScript is not defined"
	}
    }

    # canvas2ps --
    #
    # create postScript from canvas

    proc canvas2ps {
	can
	border
	image_height
	image_width
	paperheight
	paperwidth
	maxpect
    } {
	if {$image_height == 0} {
	    set image_height [$can cget -height]
	}
	if {$image_width == 0} {
	    set image_width [$can cget -width]
	}
	set paper_border [expr 2.0 * [winfo fpixels . $border]]
	set paper_height [expr [winfo fpixels . $paperheight] - $paper_border]
	set paper_width  [expr [winfo fpixels . $paperwidth]  - $paper_border]
	set is_landscape [expr $image_width > $image_height]
	if {$is_landscape} {
	    set tmp $paper_height
	    set paper_height $paper_width
	    set paper_width $tmp
	}
	if {$maxpect} {
	    if {$image_height/$image_width > $paper_height/$paper_width} {
		set pageheight $paper_height
		set pagewidth [expr $pageheight * $image_width / $image_height]
	    } else {
		set pagewidth $paper_width
		set pageheight [expr $pagewidth * $image_height / $image_width]
	    }
	    set pageheight "[expr $pageheight / [winfo fpixels . 1m]]m"
	    set pagewidth  "[expr $pagewidth  / [winfo fpixels . 1m]]m"
	    $can postscript -rotate $is_landscape -pageheight $pageheight -pagewidth $pagewidth
	} else {
	    $can postscript -rotate $is_landscape
	}
    }

}
