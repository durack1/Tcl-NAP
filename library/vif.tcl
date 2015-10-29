# vif.tcl --
#
# Define procedure 'vif' for viewing tk image files e.g. GIF files.
# This provides menu buttons to send postscript to printer or file.
# Standard tk supports PPM, PGM & GIF formats. If package "Img" is installed then vif will use it,
# giving support for BMP, XBM, XPM, PNG, JPEG, TIFF & postscript as well.
#
# Copyright (c) 2002, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: vif.tcl,v 1.6 2002/02/19 01:49:32 dav480 Exp $


# vif --
#
# View image file
# Interface to main procedure "view_image_file"
#
# Usage
#   See variable help_usage below

proc vif {
    args
} {
    eval ::View_image_file::view_image_file $args
}

namespace eval View_image_file {

    variable help_usage \
	    "Usage:\
	    \n   vif <INFILE> ?options?\
	    \n     <INFILE>: name of input file\
	    \n Options are:\
	    \n     -border <distance>: border width (default: \"20m\" i.e. 20 mm on each side)\
	    \n     -fill <0 or 1>: 1 = Scale PostScript to fill page. (Default: 0)\
	    \n     -geometry <string>: If specified use to create new toplevel window\
	    \n     -height <distance>: paper height (default: \"297m\" i.e. 297 mm (A4))\
	    \n     -help: Display this page\
	    \n     -outfile <FILENAME>: name of postscript file (default: tmp.ps)\
	    \n     -parent <string>: parent window. \"\" for toplevel. (Default: \".\")\
	    \n     -print <0 or 1>: 1 = automatic printing (for batch processing) (Default: 0)\
	    \n     -printer <string>: printer name (Default: Use environment variable\
	    \n          PRINTER if defined)\
	    \n     -width <distance>: paper width (default: \"210m\" i.e. 210 mm (A4))\
	    \n\
	    \n Example:\
	    \n   vif abc.gif -g +0+0 -pr colour1"

    proc view_image_file {
	{infile ""}
	args
    } {
	switch -glob -- $infile {
	    "" {
		eval ::View_image_file::view_image_file [open_input_file] $args
	    }
	    -* {
		puts $::View_image_file::help_usage
	    }
	    default {
		if {[file exists $infile]} {
		    ::Print_gui::init
		    catch "package require Img"
		    set auto_print 0
		    set border       20m
		    set geometry ""
		    set parent "."
		    set ::Print_gui::maxpect 0
		    set i [process_options {
			    {-border   {set border $option_value}}
			    {-fill     {set ::Print_gui::maxpect $option_value}}
			    {-geometry {set geometry $option_value}}
			    {-height   {set ::Print_gui::paperheight $option_value}}
			    {-help     {puts $::View_image_file::help_usage}}
			    {-outfile  {set ::Print_gui::filename $option_value}}
			    {-parent   {set parent $option_value}}
			    {-print    {set auto_print $option_value}}
			    {-printer  {set ::Print_gui::printer_name $option_value}}
			    {-width    {set ::Print_gui::paperwidth $option_value}}
			} $args]
		    if {$i != [llength $args]} {
			error "Illegal option"
		    }
		    set all [create_window vif $parent $geometry $infile]
		    set img [image create photo -file $infile]
		    set image_width  "[image width $img].0"
		    set image_height "[image height $img].0"
		    set can [canvas $all.canvas -width $image_width -height $image_height]
		    $can create image 0 0 -image $img -anchor nw
		    set frame $all.frame
		    frame $frame
		    set command "::Print_gui::canvas2ps $can $border $image_height $image_width"
		    button $frame.print -text print \
			    -command [list ::Print_gui::widget $command $parent]
		    button $frame.cancel -text cancel -command "destroy $all"
		    set help_command \
			{message_window $::View_image_file::help_usage -geometry +0+0 -parent ""}
		    button $frame.help -text help -command $help_command
		    pack $frame.print $frame.cancel $frame.help -side left
		    pack $frame $can
		    if {$auto_print} {
			update idletasks
			::Print_gui::print $command
			update idletasks
			destroy $all
		    }
		} else {
		    error "File $infile not found"
		}
	    }
	}
    }

}
