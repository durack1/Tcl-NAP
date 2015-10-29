# hdf.tcl --
#
# HDF/netCDF GUI.
#
# Copyright (c) 1998-2002, CSIRO Australia
#
# Authors:
# Harvey Davies, CSIRO Atmospheric Research
# P.J. Turner, CSIRO Atmospheric Research
#
# $Id: hdf.tcl,v 1.83 2003/03/24 01:31:58 dav480 Exp $


# hdf --
#
# Create window with HDF menu, etc.
# Usage
#   hdf ?<MASTER>? ?<HDF_NETCDF>?
#       <MASTER>: widget in which to pack. If none (default) then toplevel.
#	<HDF_NETCDF>: Either "hdf" or "netcdf"
#
# Example
#   hdf .

proc hdf {
    args
} {
    eval Hdf::main $args
}

namespace eval Hdf {
    variable delay 500;		# time (msec) between windows (frames) of animation
    variable filename ""
    variable hdf_netcdf "";	# "hdf" or "netcdf"
    variable index "";		# subscript of NAO
    variable is_current 0;	# 1 means nao is up-to-date
    variable nao "";		# points to NAO
    variable nao_name "";	# name specified by user
    variable raw 0;		# 1 means want raw data (ignoring attributes like scale_factor)
    variable sds_name "";	# sds-name : attribute-name)
    variable sds_rank ""
    variable windows "";	# list of windows for animation

    # main --
    #
    # Create window with HDF menu, etc.

    proc main {
	{master {}}
	{hdf_netcdf hdf}
    } {

	trace variable ::Hdf::filename w ::Hdf::need_read
	trace variable ::Hdf::sds_name w ::Hdf::need_read
	trace variable ::Hdf::index    w ::Hdf::need_read
	trace variable ::Hdf::raw      w ::Hdf::need_read
	set Hdf::filename ""
	set Hdf::sds_name ""
	set Hdf::hdf_netcdf $hdf_netcdf

	destroy .hdf
	if {$master == ""} {
	    toplevel .hdf
	} else {
	    frame .hdf -relief raised -borderwidth 4
	    pack .hdf -in $master -side top -padx 2 -pady 2 -fill x
	}

        frame .hdf.head
	switch $hdf_netcdf {
	    hdf		{label .hdf.head.heading -text "HDF Browser"}
	    netcdf	{label .hdf.head.heading -text "netCDF Browser"}
	}

        button .hdf.head.help -text "Help" -command {::Hdf::hdf_help}
        pack .hdf.head.heading -side left
        pack .hdf.head.help -side right

	frame .hdf.grid
	grid columnconfigure .hdf.grid 0 -weight 0
	grid columnconfigure .hdf.grid 1 -weight 1

	button .hdf.grid.filename_button -text "File" \
	    -command {set ::Hdf::filename {}; ::Hdf::create_tree .hdf.grid.tree}

	entry .hdf.grid.filename_entry -relief sunken -bd 2 \
	    -textvariable Hdf::filename

	# If the filename is changed by hand then also update the SDS display

	bind .hdf.grid.filename_entry <Key-Return> {::Hdf::create_tree .hdf.grid.tree}
	grid .hdf.grid.filename_button .hdf.grid.filename_entry \
	    -sticky ew

	# Create a frame to put the HDF file tree in and put it in the grid

	frame .hdf.grid.tree -bg white
        # This frame forces the tree frame to the right
        # allowing the scroll bar to be on the far right
        # On Sun systems the scroll bar had white space on the right
        # This plus an increase in canvas width from 400 to 450
        # fixes this problem. It seems like there is a bug in Tk. 
        frame .hdf.grid.pad -bg white
        grid .hdf.grid.pad .hdf.grid.tree -sticky news

	# Spatial index widget

	frame .hdf.grid.index
	grid .hdf.grid.index -columnspan 2 -sticky news

	# All the buttons along the bottom of the menu
	frame .hdf.do
	button .hdf.do.range -text "Range" -command ::Hdf::hdf_range
	button .hdf.do.text -text "Text" -command ::Hdf::hdf_text
	button .hdf.do.graph -text "Graph" -command {::Hdf::hdf_graph} 
	button .hdf.do.image -text "Image" -command {::Hdf::hdf_image} 
	button .hdf.do.animate -text "Animate" -command {::Hdf::hdf_animate} 
	button .hdf.do.nao -text "NAO" -command {::Hdf::hdf_create_nao} 
	button .hdf.do.cancel -text Cancel -command {destroy .hdf}
	pack \
	    .hdf.do.range \
	    .hdf.do.text \
	    .hdf.do.graph \
	    .hdf.do.image \
	    .hdf.do.animate \
	    .hdf.do.nao \
	    .hdf.do.cancel \
	    -side left \
	    -fill x \
	    -expand true \
	    -padx 1 \
	    -pady 2
#
# Can use either pack or grid. Tried grid to see if it
# helped with the scroll bar bug - it did not!
#
#	pack .hdf.head  -expand true -fill x
#	pack .hdf.grid  -expand true -fill x -anchor e
#	pack .hdf.do -expand true -fill x
	grid .hdf.head  -sticky ew
	grid .hdf.grid  -sticky ew
	grid .hdf.do -sticky ew
    }


    # need_read --
    #
    # Called by write trace on variables ::Hdf::filename, ::Hdf::sds_name, ::Hdf::index, ::Hdf::raw
    # If any of these change we need to read variable again from file

    proc need_read {
	name
	element
	op
    } {
	set ::Hdf::is_current 0
    }

    # hdf_graph --

    proc hdf_graph {
    } {
	set parent .hdf.do.graph
	set w $parent.menu
	destroy $w
	if [read_nao] {
	    if {[$::Hdf::nao rank] > 1} {
		menu $w
		menu_entry $w "graph" 1 xy
		menu_entry $w "overlaid graph" 2 xy
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } else {
		draw_image 1 xy
	    }
	}
    }

    # hdf_image --

    proc hdf_image {
    } {
	set parent .hdf.do.image
	set w $parent.menu
	destroy $w
	if [read_nao] {
	    if {[$::Hdf::nao rank] > 2} {
		menu $w
		menu_entry $w "pseudo-colour image" 2 z
		menu_entry $w "tiled pseudo-colour image" 3 tile
		menu_entry $w "RGB image" 3 z
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } elseif {[$::Hdf::nao rank] > 1} {
		draw_image 2 z
	    } else {
		Hdf::hdf_warn "rank < 2"
	    }
	}
    }

    # hdf_animate --

    proc hdf_animate {
    } {
	set parent .hdf.do.animate
	set w $parent.menu
	destroy $w
	if {[llength $::Hdf::windows] > 1} {
	    menu $w
	    $w add command -label "animate last window-sequence" -command "::Hdf::animate"
	    $w add command -label "set animation period" -command "set ::Hdf::delay \
		    \[get_entry {period per window (msec)} -parent .hdf -text \$::Hdf::delay\]"
	    $w add command -label "delete last window-sequence" \
		    -command "destroy $::Hdf::windows; set ::Hdf::windows {}"
	    $w add command -label cancel -command "destroy $w"
	    $w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	} else {
	    Hdf::hdf_warn "no window-sequence"
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
	global Hdf::nao
	nap "i = rank(nao) - rank_image"
	set n [[nap "i < 0 ? 0 : prod((shape(nao))(0 .. (i-1) ... 1))"]]
	if {$n > 1} {
	    set label "$n ${label}s"
	}
	if {$n > 0} {
	    $w add command -label $label -command "::Hdf::draw_image $rank_image $type"
	    return 1
	}
	return 0
    }

    # hdf_warn --
    #
    # Warn user of error

    proc hdf_warn {
	message
    } {
	message_window $message -label "Error!" -wait 1
    }


    # hdf_info --
    #
    # get info on sds/var
    # flag can be -rank, -shape, -dimension, -coordinate

    proc hdf_info {
	flag
	filename
	var_name
    } {
	set command [list nap_get $Hdf::hdf_netcdf $flag $filename $var_name]
	if {[catch $command result]} {
	    Hdf::hdf_warn \
		    "hdf_info: Error executing following command:\
		    \n$command\
		    \nwhich produced result:\
		    \n$result"
	    set result undefined
	}
	return $result
    }


    # hdf_create_nao --
    #
    # Create NAO with name specified by user

    proc hdf_create_nao {
    } {
	if [read_nao] {
	    regsub -all {[^_a-zA-Z0-9]} [::Hdf::hdf_var_name] _ Hdf::nao_name
	    if [regexp {^[0-9]} $Hdf::nao_name] {
		set Hdf::nao_name _$Hdf::nao_name
	    }
	    set Hdf::nao_name [get_entry "NAO name: " -text $Hdf::nao_name -width 40]
	    uplevel {
		if {[catch {nap "$::Hdf::nao_name = ::Hdf::nao"}]} {
		    Hdf::hdf_warn "Unable to create NAO"
		} else {
		    message_window "Created NAO $::Hdf::nao named '$::Hdf::nao_name'"
		}
	    }
	}
    }


    # read_nao --
    #
    # Read variable from HDF file into nao
    # Return 1 if OK, 0 for error

    proc read_nao {
    } {
	global Hdf::filename
	global Hdf::hdf_netcdf 
	global Hdf::index
	global Hdf::sds_name
	global Hdf::is_current
	global Hdf::raw
	set status 0
	if {$is_current} {
	    set status 1
	} else {
	    if [hdf_select_file] {
		hdf_var_name
		setIndex
		if {[catch {nap "::Hdf::nao = 
			    [nap_get $hdf_netcdf $filename $sds_name $index $raw]"}]} {
		    Hdf::hdf_warn "Unable to read NAO"
		} else {
		    set status 1
		    set is_current 1
		}
	    }
	}
	return $status
    }


    # hdf_help --
    #
    # Display help.

    proc hdf_help {} {
	global Hdf::hdf_netcdf
	switch $hdf_netcdf {
	    hdf		{set v SDS}
	    netcdf	{set v variable}
	}
	message_window \
	    "1. Select a file.\
	    \n   The 'file' button has an entry field on the right, showing the current\
	    \n   value. You can change this value in two ways:\
	    \n    - Press the button to display a file selection widget.\
	    \n    - Type in a file name in the entry field.\
	    \n   Once a file has been selected a 'file structure tree' will appear.\
	    \n\
	    \n2. Select an $v/Attribute from the tree using the mouse.\
	    \n   Click '+' to display attributes. Spatial sampling widgets appear for\
	    \n   $v entries. An attribute name and size appears for attributes.\
	    \n   (A ':' is used as a separator in an attribute name. Attributes cannot be\
	    \n   spatially sampled.)\
	    \n\
	    \n3. Select 'Raw' mode if you want the following attributes to be ignored:\
	    \n   scale_factor, add_offset, valid_min, valid_max, valid_range.\
	    \n\
	    \n4. Change the spatial scaling values to your requirements.\
	    \n   Each row corresponds to a dimension. Click in the 'Units' column to toggle\
	    \n   between coordinate-variable-mode and index-mode. Click in the 'Expr'\
	    \n   column to toggle between arithmetic-progression-mode and expression-mode.\
	    \n   (Spatial scaling operates by rounding to the nearest integer value for\
	    \n   fractional index requests -- it does not interpolate.) A right mouse click\
	    \n   toggles each scale value between the default value and what you entered.\
	    \n\
	    \n5. Use the buttons along the bottom to initiate the following actions.\
	    \n   'Range'   button: Display minimum and maximum value.\
	    \n   'Text'    button: Display start of data as text.\
	    \n   'Graph'   button: Display data as XY graph(s).\
	    \n   'Image'   button: Display data as image(s).\
	    \n   'Animate' button: Animate window-sequence produced by 'Graph' or 'Image'.\
	    \n   'NAO'     button: Create Numeric Array Object.\
	    \n   'Help'    button: Display this '$hdf_netcdf help'.\
	    \n   'Cancel'  button: Remove $hdf_netcdf widget." \
	    -label "$hdf_netcdf help"
    }


    # draw_image --
    #
    # View HDF var using plot_nao

    proc draw_image {
	rank
	type
    } {
	global Hdf::nao
	if [read_nao] {
	    set label [string trim [$nao label]]
	    set unit  [string trim [$nao unit]]
	    if {[string equal $unit (NULL)]} {
		set unit ""
	    }
	    set title $::Hdf::sds_name
	    if {$unit != ""} {
		set title "$title ($unit)"
	    }
	    if {$label != ""} {
		set title "$label\n$title"
	    }
	    if {[catch {plot_nao $nao -rank $rank -title $title -type $type} result]} {
		Hdf::hdf_warn "Error in plot_nao:\n $result"
	    } else {
		if {[llength $result] > 1} {
		    set ::Hdf::windows $result
		    raise .
		}
	    }
	}
    }


    # animate --

    proc animate {
    } {
	set ms 0
	foreach win "$::Hdf::windows ." {
	    after $ms "raise $win; update idletasks"
	    incr ms $::Hdf::delay
	}
    }
    

    # hdf_range --
    #
    # Display range

    proc hdf_range {
    } {
	if [read_nao] {
	    if [catch {nap "r = range(::Hdf::nao)"} result] {
		Hdf::hdf_warn "Error in nap command:\n $result"
	    } else {
		message_window \
			"File: $::Hdf::filename \
			\nVariable: $::Hdf::sds_name \
			\nRange: [$r]" \
			-label range
	    }
	}
    }


    # hdf_select_file --
    #
    # Select HDF file
    # Return 1 if OK, 0 for error

    proc hdf_select_file {
    } {
	global Hdf::filename
	set ext(hdf) .hdf
	set ext(netcdf) .nc
	if {$filename == ""} {
	    set filename [open_input_file "" $ext($Hdf::hdf_netcdf)]
	}
	set status [file readable $filename]
	if {!$status} {
	    Hdf::hdf_warn "Unable to read file $filename"
	}
	return $status
    }

    # hdf_text --
    #
    # Read variable from HDF file into nao & then use specified method for this nao

    proc hdf_text {
	{method "all"}
	{c_format ""}
	{max_cols ""}
	{max_lines ""}
    } {
	global Hdf::nao
	if [read_nao] {
	    if [regexp c8 [$nao datatype]] {
		default max_cols -1
		default max_lines -1
	    } else {
		default max_cols 50
		default max_lines 100
	    }
	    message_window \
		    "File: $::Hdf::filename \
		    \nVariable: $::Hdf::sds_name \
		    \n[$nao $method -format $c_format -columns $max_cols -lines $max_lines]" \
		    -label data
	}
    }


    # hdf_var_name --
    #
    # Return value of HDF::sds_name (which combines names of both sds/var & attribute)
    #
    # Usage:
    #   hdf_var_name

    proc hdf_var_name {} {
	 if {![winfo exists .hdf.grid.tree.w]} {
	    ::Hdf::create_tree .hdf.grid.tree
	 }
	 if {${Hdf::sds_name} == ""} {
	    tkwait variable Hdf::sds_name
	 }
	 return  ${Hdf::sds_name}
    }


    # create_tree --
    #
    # Create a tree structure for an HDF file

    proc create_tree {w} {
	global Hdf::filename
	if [hdf_select_file] {
	    set hdfContents [nap_get $Hdf::hdf_netcdf -list $filename]
	} else {
	    return
	}
	. config -bd 3 -relief flat

	destroy $w.w
	destroy $w.sb
	#
	# Create the space for a tree with scroll bar
	#
	set hdfList [split $hdfContents "\n"]
        #
        # Adjust the tree window size according to
        # the number of items in the file
        #
        set number_items [llength $hdfList]
        set view_height 100 
        if {$number_items > 10} {
            set view_height 150
        }
        if {$number_items > 20} {
            set view_height 200
        }
	::Tree::Tree:create $w.w -width 450 -height $view_height \
             -yscrollcommand "$w.sb set"
	scrollbar $w.sb -orient vertical -command "$w.w yview"
	grid $w.w -row 0 -column 0 -sticky nes
	grid $w.sb -row 0 -column 1 -sticky nes
        update idletasks
	#
	# Write out the information
	#
	set global_attribute 0
        set update_counter 0
	foreach item $hdfList {
	    set items [split $item ":"]
	    set sds [lindex $items 0]
	    set attr [lindex $items 1]
	    set attr [string map {/ ":"} $attr]
	    if {"$sds" == ""} {
		if {!$global_attribute} {
		    ::Tree::Tree:newitem $w.w "/Global attributes"
		    set global_attribute 1
		}
		::Tree::Tree:newitem $w.w "/Global attributes/$attr"
	    } else {
		set shape [hdf_info -shape "$filename" "$sds"]
		::Tree::Tree:newitem $w.w "/$sds" -attributes "    $shape"
		if {"$attr" != ""} {
		    ::Tree::Tree:newitem $w.w "/${sds}/$attr"
		}
	    }
#
# Only update in groups to avoid countinuous updating
#
            incr update_counter
            if {$update_counter == 20} {
                set update_counter 0
                update idletasks
            }
	}
        update idletasks
	#
	# set bindings and draw the tree
	#
	.hdf.grid.tree.w bind x <1> {
	    set lbl [::Tree::Tree:labelat %W %x %y]
	    ::Tree::Tree:setselection %W $lbl
	#
	# write the result of the tree selection
	#
	# To use this as the structure of HDF file
	# we need to modify the result to get
	# an SDSname or and attribute
	#
	# Remove leading /
	#
	    set mlbl [string range $lbl 1 end]
	#
	# Map any / to : and map any : to /
	# This is a kludge to prevent a / in the name
	# messing up this tree script. Really should be
	# rewritten using lists to avoid the problems
	# created by special characters
	#
	    set mlbl [string map {/ : : /} $mlbl]
	#
	# If it is not "Global Attributes" then
	# change the sdsname
	#
	    if [string compare "Global attributes" "$mlbl"] {
		if {[string length $mlbl] > 17} {
		    set temp [string range $mlbl 0 16]
		    if [string compare "Global attributes" "$temp"] {
			set Hdf::sds_name $mlbl
			::Hdf::show_index 
		    } else {
			set Hdf::sds_name [string range $mlbl 17 end]
			::Hdf::show_index
		    }
		} else {
		    set Hdf::sds_name $mlbl
		    ::Hdf::show_index
		}
	    } 
	}

	#
	# This is suppose to open a tree node 
	# with a double click.
	#
	.hdf.grid.tree.w bind x <Double-1> {
	    ::Tree::Tree:open %W [::Tree::Tree:labelat %W %x %y]
	}
	update idletasks
    }

    #
    # show_index --
    #
    # Display the index widgets in the HDF menu.
    #
    #
    proc show_index {} {

	global Hdf::filename
	global Hdf::sds_name
	global Hdf::index
	global Hdf::sds_rank

	if {[string length $sds_name] == 0} {
	    return
	}
	set sds_rank [hdf_info -rank $filename $sds_name]
	set shp [hdf_info -shape $filename $sds_name]
	set win .hdf.grid.index
	set win ${win}.sf
	destroy $win
	set names [namespace children [namespace current]::indexWidget]
	if [llength $names] {
	    eval namespace delete $names
	}
	frame ${win} -relief raised -borderwidth 2
	pack ${win} -expand true -fill x -anchor w
	grid propagate ${win}
	grid columnconfigure ${win} {0 1} -weight 1
	label ${win}.l0 -text "$sds_name"
	grid ${win}.l0 -row 0 -column 0 -columnspan 5 -sticky nw
	    # Check for attribute
	if {[string match "*:*" $sds_name]} {
	    label ${win}.l1 -text "attribute size  $shp"
	    grid ${win}.l1 -row 1 -column 0 -sticky nw
	    return
	}  
	checkbutton $win.l1 -text Raw -variable ::Hdf::raw
	label ${win}.l2 -text "Units" -anchor w -padx 20
	label ${win}.ap -text "Expr"
	label ${win}.l3 -text "Range"
	label ${win}.l5 -text "Step"
	grid ${win}.l1 -row 1 -column 0 -sticky nw
	grid ${win}.l2 -row 1 -column 1 -sticky nw
	grid ${win}.ap -row 1 -column 2
	grid ${win}.l3 -row 1 -column 3 -columnspan 2
	grid ${win}.l5 -row 1 -column 5 -sticky nw
	set max_unit_length 10
	for {set i 0} {$i < $sds_rank} {incr i} {
	    set cv [nap_get $Hdf::hdf_netcdf -coordinate $filename $sds_name $i]
	    if {$cv == ""} {
		set cv$i ""
		set unit($i) ""
	    } else {
		nap "cv$i = $cv"
		set unit($i) [[set cv$i] unit]
		if {[string equal $unit($i) (NULL)]} {
		    set unit($i) ""
		}
		set max_unit_length [min 64 [max $max_unit_length [string length $unit($i)]]]
	    }
	}
	set dim_names [hdf_info -dimension $filename $sds_name]
	for {set i 0} {$i < $sds_rank} {incr i} {
	    ::Hdf::indexWidget::createIndexWidget \
		    ${win} \
		    $i \
		    [lindex $dim_names $i] \
		    [lindex $shp $i] \
		    [set cv$i] \
		    $unit($i) \
		    $max_unit_length
	}
    }

    # setIndex --
    #
    # Set the value of the index variable

    proc setIndex {} {

	global Hdf::filename
	global Hdf::sds_rank
	global Hdf::sds_name
	
	#
	# Check for attribute
	#
	if [string match "*:*" $Hdf::sds_name] {
	    set ::Hdf::index ""
	} else {
	    set dim_names [hdf_info -dimension $filename $sds_name]
	    set all_blank 1
	    for {set i 0} {$i < $sds_rank} {incr i} {
		set name [lindex $dim_names $i]
		set tmp [::Hdf::indexWidget::getIndex $i]
		set is_blank [expr [string length $tmp] == 0]
		set all_blank [expr $all_blank && $is_blank]
		if {$i == 0} {
		    set ::Hdf::index $tmp
		} else {
		    set tmp "$::Hdf::index , $tmp"
		}
		if {$i > 0  || ! $is_blank} {
		    if [catch {nap "::Hdf::index = $tmp"} msg] {
		    Hdf::hdf_warn \
			    "setIndex: nap error evaluating index for dimension $i ($name)\n$msg"
		    }
		}
	    }
	    if {$all_blank} {
		set ::Hdf::index ""
	    }
	}
    }

    #
    # Create a namespace for this stuff
    #
    namespace eval indexWidget {

    # createIndexWidget --
    #
    # Create a widget to enter spatial scale values.
    #
    # The proceedure requires a window id, a unique
    # id and the CV for the particular scaling operation.

    proc createIndexWidget {
	nm
	id
	dim_name
	nel
	cvNao
	unit
	max_unit_length
    } {
	# Define local variable names
	#
	# We use the cv to convert between extrema
	# in index and coordinate space. However,
	# we calculate the step in index and
	# coordinate space only once

	namespace eval ${id} {
	    variable expr_mode 0;		# 1 = expr mode, 0 = AP mode
	    variable n;			# size of dimension
	    variable cv;		# Coordinate variable for this dimension
	    variable expr ""
	# Current values
	    variable start
	    variable stop
	    variable step
	# User set values
	    variable ustart
	    variable ustop
	    variable ucstep
	    variable uistep 
	    variable dcstep;		# default coordinate step
	    variable distep;		# default index step
	# Check button state 
	    variable state 0;		# 0 = cv mode, 1 = index mode
	    trace variable start	w ::Hdf::need_read
	    trace variable stop		w ::Hdf::need_read
	    trace variable step		w ::Hdf::need_read
	    trace variable ucstep	w ::Hdf::need_read
	    trace variable uistep	w ::Hdf::need_read
	    trace variable expr		w ::Hdf::need_read
	}

	set ns [namespace current]
	global ${ns}::${id}::expr_mode
	global ${ns}::${id}::cv
	global ${ns}::${id}::n
	global ${ns}::${id}::start
	global ${ns}::${id}::stop
	global ${ns}::${id}::step
	global ${ns}::${id}::dcstep
	global ${ns}::${id}::distep
	global ${ns}::${id}::ustart
	global ${ns}::${id}::ustop
	global ${ns}::${id}::ucstep
	global ${ns}::${id}::uistep
	global ${ns}::${id}::state

	set cv ""
	set n $nel
	set start ""
	set stop ""
	set step ""
	set uistep 1
	set ucstep 1
	set distep 1
	if {$cvNao != ""} {
	    nap cv = cvNao
	    set start [[nap cv(0)]]
	    set stop [[nap cv(-1)]]
	    if {$n <= 1} {
		set step 1
	    } else {
		if {[$cv step] == "AP"} {
		    if {$n == 2} {
			set step [[nap cv(-1) - cv(0)]]
		    } else {
			set step [[nap (cv(-2)-cv(0))/(n - 2)]]
		    }
		}
	    }
	}
	set ustop $stop
	set ustart $start
	set ucstep $step
	set dcstep $step

	label $nm.l1$id -text "$dim_name" -anchor w -width [min 64 [string length $dim_name]]

	if {$cvNao == ""} {
	    label $nm.state$id \
		-relief groove \
		-text "$unit" \
		-width $max_unit_length \
		-anchor w
	} else {
	    checkbutton $nm.state$id \
		-variable ${ns}::${id}::state \
		-selectcolor orange \
		-command "::Hdf::indexWidget::toggleIndex $nm.state$id $id {$unit}" \
		-relief groove \
		-text "$unit" \
		-width $max_unit_length \
		-anchor w
	}

	checkbutton $nm.ap$id \
	    -variable ${ns}::${id}::expr_mode \
	    -selectcolor orange \
	    -relief flat \
	    -command "::Hdf::indexWidget::toggle_expr_mode $nm $id"

	entry $nm.e1$id \
	    -relief sunken \
	    -width 7 \
	    -textvariable ${ns}::${id}::start

	label $nm.l2$id -text stop

	entry $nm.e2$id \
	    -relief sunken \
	    -width 7 \
	    -textvariable ${ns}::${id}::stop

	label $nm.l3$id -text "incr"

	entry $nm.e3$id \
	   -relief sunken \
	   -width 6 \
	   -textvariable ${ns}::${id}::step

	entry $nm.e$id \
	   -relief sunken \
	   -textvariable ${ns}::${id}::expr

	bind $nm.e1$id <KeyRelease> "::Hdf::indexWidget::enterUser %W $id start" 
	bind $nm.e2$id <KeyRelease> "::Hdf::indexWidget::enterUser %W $id stop" 
	bind $nm.e3$id <KeyRelease> "::Hdf::indexWidget::enterUser %W $id step" 

	bind $nm.e1$id <3> "::Hdf::indexWidget::toggleDefault %W $id start" 
	bind $nm.e2$id <3> "::Hdf::indexWidget::toggleDefault %W $id stop" 
	bind $nm.e3$id <3> "::Hdf::indexWidget::toggleDefault %W $id step" 
	#
	grid $nm.l1$id $nm.state$id $nm.ap$id $nm.e1$id $nm.e2$id $nm.e3$id \
	    -sticky ew \
	    -padx 2 \
	    -pady 1
	if {$step == ""} {
	    set state 1
	    toggleIndex $nm.state$id $id $unit
	}
    }

    # toggle_expr_mode --

    proc toggle_expr_mode {
	nm
	id
    } {
	set ns [namespace current]
	global ${ns}::${id}::expr_mode
	set ::Hdf::is_current 0
	set info [grid info $nm.ap$id]
	set master [lindex $info 1]
	set row [lindex $info [expr 1 + [lsearch $info -row]]]
	if {$expr_mode} {
	    grid remove $nm.e1$id $nm.e2$id $nm.e3$id
	    grid $nm.e$id \
		    -in $master \
		    -columnspan 3 \
		    -row $row \
		    -column 3 \
		    -sticky ew \
		    -padx 2 \
		    -pady 1
	} else {
	    grid remove $nm.e$id
	    grid $nm.e1$id -in $master -row $row -column 3
	    grid $nm.e2$id -in $master -row $row -column 4
	    grid $nm.e3$id -in $master -row $row -column 5
	}
    }

    # toggleIndex --
    #
    # Switch between coordinate values and index values

    proc toggleIndex {win id unit} {

	set ns [namespace current]
	global ${ns}::${id}::cv
	global ${ns}::${id}::n
	global ${ns}::${id}::start
	global ${ns}::${id}::stop
	global ${ns}::${id}::step
	global ${ns}::${id}::ustart
	global ${ns}::${id}::ustop
	global ${ns}::${id}::ucstep
	global ${ns}::${id}::uistep
	global ${ns}::${id}::distep
	global ${ns}::${id}::dcstep
	global ${ns}::${id}::state

	# Change the entry values according to coordinate (state = 0) or index mode (state = 1)
	if {$state} {
	    $win configure -text "index    "
	    if {$cv == ""} {
		set start 0 
		set stop [expr $n - 1]
		set step $uistep
	    } else {
		if [catch {[nap cv@@start]} tempStart] {
		    Hdf::hdf_warn "Warning - bad from value: $start "
		    set start 0 
		} else {
		    set start $tempStart
		}
		if [catch {[nap cv@@stop]} tempStop] {
		    Hdf::hdf_warn "Warning - bad to value: $stop "
		    set stop [[nap n-1]] 
		} else {
		    set stop $tempStop
		}
		if {"$dcstep" != "" && "$step" != ""} {
		    if [catch {expr $step/$dcstep} tempStep] {
			Hdf::hdf_warn "Warning - bad step value: $step "
			set step $distep 
		    } else {
			set step [format %g $tempStep]
			set uistep $step
		    }
		} else {
		    set step $uistep
		}
	    }
	} else {
	    if {$cv == ""} {
		set state 1; # coord mode not allowed
	    } else {
		$win configure -text "$unit"
		if [catch {[nap cv(start)]} tempStart] {
		    Hdf::hdf_warn "Warning - bad from value: $start "
		    set start [[nap cv(0)]] 
		} else {
		    set start $tempStart
		}
		if [catch {[nap cv(stop)]} tempStop] {
		    Hdf::hdf_warn "Warning - bad to value: $stop "
		    set stop [[nap cv(-1)]] 
		} else {
		    set stop $tempStop
		}
		if {"$dcstep" != ""} {
		    if [catch {expr $step*$dcstep} tempStep] {
			Hdf::hdf_warn "Warning - bad step value: $step "
			set step $dcstep
		    } else {
			set step [format %g $tempStep]
			set ucstep $step
		    }
		} else {
		    set step $ucstep
		}
	    }
	}
    }

    # enterUser --
    #
    # Change the background to white when the user
    # enters a number. Also make sure the user entry
    # is valid.

    proc enterUser {win id name} {

	set ns [namespace current]
	global ${ns}::${id}::cv
	global ${ns}::${id}::start
	global ${ns}::${id}::stop
	global ${ns}::${id}::step
	global ${ns}::${id}::ustart
	global ${ns}::${id}::ustop
	global ${ns}::${id}::ucstep
	global ${ns}::${id}::uistep
	global ${ns}::${id}::state

	$win configure -background white

	#
	# Check to see if we are dealing with a coordinate
	# or an index value
	#
	# We have allowed for testing inputs but do not
	# do anything much!
	#

	if {$state} {
	    switch -exact -- $name {
		start {
		}
		stop {
		}
		step  {
		    set uistep $step
		}
	    }

	#
	# Coordinate case
	#

	} else {
	    switch -exact -- $name {
		start {
		}
		stop {
		}
		step {
		    set ucstep $step
		}
	    }
	}
    }

    # toggleDefault --
    #
    # Switch between user and default values
    # Not yet used or complete!

    proc toggleDefault {win id name} {

	set ns [namespace current]
	global ${ns}::${id}::cv
	global ${ns}::${id}::start
	global ${ns}::${id}::stop
	global ${ns}::${id}::step
	global ${ns}::${id}::ustart
	global ${ns}::${id}::ustop
	global ${ns}::${id}::ucstep
	global ${ns}::${id}::uistep
	global ${ns}::${id}::state
	global ${ns}::${id}::dcstep
	global ${ns}::${id}::distep

	# Check which mode we are in!
	#

	set backColour [lindex [$win configure -background] 3]
	set colour [lindex [$win configure -background] 4]

	#
	# We should introduce checks here!   
	#

	if {$colour == "white"} {
	    $win configure -background $backColour
	#
	# Back to default values
	#
	    if {$state} {
		switch -exact -- $name {
		    start {
			set ustart [[nap cv($start)]]
			set start 0
		    }
		    stop {
			set ustop [[nap cv($stop)]]
			set stop [[nap n-1]]
		    }
		    step  {
			set uistep $step
			set step $distep
		    }
		}

	#
	# Coordinate case
	#

	    } else {
		switch -exact -- $name {
		    start {
			set ustart $start
			set start [[nap cv(0)]]
		    }
		    stop {
			set ustop $stop
			set stop [[nap cv(-1)]]
		    }
		    step {
			set ucstep $step
			set step $dcstep
		    }
		}
	    }
	} else {
	    $win configure -background "white"
	#
	# Back to user values
	#
	    if {$state} {
		switch -exact -- $name {
		    start {
			set start [[nap cv@@$ustart]]
		    }
		    stop {
			set stop [[nap cv@@$ustop]]
		    }
		    step  {
			set step $uistep
		    }
		}

	#
	# Coordinate case
	#

	    } else {
		switch -exact -- $name {
		    start {
			set start $ustart
		    }
		    stop {
			set stop $ustop
		    }
		    step {
			set step $ucstep
		    }
		}
	    }
	}
    }

    # getIndex --
    #
    # Return the values of the current spatial sampling
    # indices to the calling routine.

    proc getIndex {id} {

	set ns [namespace current]

	global Hdf::index

	global ${ns}::${id}::expr_mode
	global ${ns}::${id}::n
	global ${ns}::${id}::cv
	global ${ns}::${id}::expr
	global ${ns}::${id}::start
	global ${ns}::${id}::stop
	global ${ns}::${id}::step
	global ${ns}::${id}::ucstep
	global ${ns}::${id}::uistep
	global ${ns}::${id}::dcstep
	global ${ns}::${id}::distep
	global ${ns}::${id}::state

	set lastIndex [[nap n-1]]
	#
	# Return the information to create a set of nap
	# commands
	#

	if {$state} {
	#
	# Index mode
	#

	    if {$expr_mode} {
		return $expr
	    }

	#
	# Update the user coordinate step value in case
	# we need to use it
	#

	    if {"$dcstep" != ""} {
		set tempStep [expr $dcstep*$step]
		set ucstep [format %g $tempStep]
	    }

	#
	# If we have default coordinates then return nothing
	#

	    if {$start == $stop} {
		return $start
	    } elseif {$start == 0 && $stop == $lastIndex && "$step" == 1} {
		return ""
	    } else { 
		if {"$step" != ""} {
	# Make sure we get a result
		    if {($stop > $start && $step > 0) || \
			($start > $stop && $step < 0)} {
			return "nint(ap0($start,$stop,$step))"
		    } else {
			return "nint(ap0($stop,$start,$step))"
		    }
		} else {
		    if {$ucstep != ""} {
	# Make sure we get a positive result
			set t1 [[nap cv($start)]]
			set t2 [[nap cv($stop)]]
			if {($t2 > $t1 && $ucstep > 0) || \
			    ($t1 > $t2 && $ucstep < 0)} {
			    return "nint($cv@@ap0(cv($start),cv($stop),$ucstep))"
			} else {
			    return "nint($cv@@ap0(cv($stop),cv($start),$ucstep))"
			}

		    } else {
			Hdf::hdf_warn "Warning - bad index value dimension ${id}"
			return ""
		    }
		}
	    }
	
	} else {
	    if {$expr_mode} {
		return "@@($expr)"
	    }
	    if {$start == $stop} {
		return [[nap cv@@$start]]
	    } elseif {[[nap cv(0)]]==$start && [[nap cv(-1)]]==$stop && \
		"$step"=="$dcstep"} {
		return ""
	    } else {
		set ucstep $step
		if {"$ucstep" == ""} {
		    set t1 [[nap cv@@$start]]
		    set t2 [[nap cv@@$stop]]
		    if {"$uistep" == ""} {
			return "$t1..$t2"
		    } else {
			if {($t2 > $t1 && $uistep > 0) || ($t1 > $t2 && $uistep < 0)} {
			    return "nint(ap0($t1,$t2,$uistep))"
			} else {
			    return "nint(ap0($t2,$t1,$uistep))"
			}
		    }
		} else {
		    if {($stop > $start && $ucstep > 0)|| \
			($start > $stop && $ucstep < 0)} {
			return "nint($cv@@ap0($start,$stop,$ucstep))"
		    } else {
			return "nint($cv@@ap0($stop,$start,$ucstep))"
		    }
		}
	    }
	}
    }

    # End of namespace indexWidget
    }

}
