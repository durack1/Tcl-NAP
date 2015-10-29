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
# $Id: hdf.tcl,v 1.92 2003/12/03 04:36:30 dav480 Exp $


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
    eval ::Hdf::main $args
}

package require BWidget

namespace eval Hdf {
    variable delay 500;		# time (msec) between windows (frames) of animation
    variable filename ""
    variable hdf_netcdf "";	# "hdf" or "netcdf"
    variable index "";		# subscript of NAO
    variable is_current 0;	# 1 means nao is up-to-date
    variable nao "";		# points to NAO
    variable nao_name "";	# name specified by user
    variable new_filename "";	# current name in spinbox
    variable raw 0;		# 1 means want raw data (ignoring attributes like scale_factor)
    variable sds_name "";	# sds-name : attribute-name
    variable sds_rank ""
    variable windows "";	# list of windows for animation

    # main --
    #
    # Create window with HDF menu, etc.

    proc main {
	{master {}}
	{hdf_netcdf hdf}
    } {
	trace variable ::Hdf::sds_name w ::Hdf::need_read
	trace variable ::Hdf::index    w ::Hdf::need_read
	trace variable ::Hdf::raw      w ::Hdf::need_read
	set ::Hdf::filename ""
	set ::Hdf::sds_name ""
	set ::Hdf::hdf_netcdf $hdf_netcdf

	destroy .hdf
	if {$master == ""} {
	    toplevel .hdf -relief ridge -borderwidth 4
	} else {
	    frame .hdf -relief ridge -borderwidth 4
	    pack .hdf -in $master -side top -padx 2 -pady 2 -fill x
	}

        frame .hdf.head
	switch $hdf_netcdf {
	    hdf		{set extension hdf; set file_type HDF}
	    netcdf	{set extension nc ; set file_type netCDF}
	}
	label .hdf.head.heading -text "$file_type Browser"
        button .hdf.head.help -text "Help" -command {::Hdf::hdf_help}
        pack .hdf.head.heading -side left
        pack .hdf.head.help -side right

	frame .hdf.file
	button .hdf.file.open  -text Open -command ::Hdf::open_file
	label .hdf.file.label -text "file"
	spinbox .hdf.file.entry \
	    -relief sunken -bd 2 -background white -wrap 1 \
	    -values [glob -nocomplain *.$extension] \
	    -textvariable ::Hdf::new_filename
	bind .hdf.file.entry <Key-Return> ::Hdf::open_file
	button .hdf.file.gui -text GUI -command "::Hdf::file_gui $file_type $extension"
	pack .hdf.file.open .hdf.file.label -side left
	pack .hdf.file.entry -side left -expand true -fill x
	pack .hdf.file.gui -side left
	.hdf.file.entry xview moveto 1.0; # In case filename is too long
	focus .hdf.file.entry

	frame .hdf.tree -background white; # HDF file tree
	frame .hdf.index; # Spatial index widget
	frame .hdf.do; # All the buttons along the bottom of the menu

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
	pack .hdf.head  -expand true -fill x
	pack .hdf.file  -expand true -fill x
	pack .hdf.tree  -expand true -fill x
	pack .hdf.index -expand true -fill x
	pack .hdf.do    -expand true -fill x
    }


    # need_read --
    #
    # Called by write trace on variables ::Hdf::sds_name, ::Hdf::index, ::Hdf::raw
    # If any of these change we need to read variable again from file

    proc need_read {
	name
	element
	op
    } {
	set ::Hdf::is_current 0
    }


    # open_file --

    proc open_file {
    } {
	global ::Hdf::filename
	global ::Hdf::new_filename
	if {$new_filename ne ""  &&  $new_filename ne $filename} {
	    if {[file readable $new_filename]} {
		set filename $new_filename
		create_tree
	    } else {
		::Hdf::hdf_warn "Unable to read file $new_filename"
	    }
	}
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
		::Hdf::hdf_warn "rank < 2"
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
	    ::Hdf::hdf_warn "no window-sequence"
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
	global ::Hdf::nao
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
	set command [list nap_get $::Hdf::hdf_netcdf $flag $filename $var_name]
	if {[catch $command result]} {
	    ::Hdf::hdf_warn \
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
	    regsub -all {[^_a-zA-Z0-9]} [::Hdf::hdf_var_name] _ ::Hdf::nao_name
	    if [regexp {^[0-9]} $::Hdf::nao_name] {
		set ::Hdf::nao_name _$::Hdf::nao_name
	    }
	    set ::Hdf::nao_name [get_entry "NAO name: " -text $::Hdf::nao_name -width 40]
	    uplevel {
		if {[catch {nap "$::Hdf::nao_name = ::Hdf::nao"}]} {
		    ::Hdf::hdf_warn "Unable to create NAO"
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
	global ::Hdf::filename
	global ::Hdf::hdf_netcdf 
	global ::Hdf::index
	global ::Hdf::sds_name
	global ::Hdf::is_current
	global ::Hdf::raw
	set status 0
	if {$is_current} {
	    set status 1
	} elseif {$filename ne ""} {
	    hdf_var_name
	    setIndex
	    if {[catch {nap "::Hdf::nao = 
		    [nap_get $hdf_netcdf $filename $sds_name $index $raw]"}]} {
		::Hdf::hdf_warn "Unable to read NAO"
	    } else {
		set status 1
		set is_current 1
	    }
	}
	return $status
    }


    # hdf_help --
    #
    # Display help.

    proc hdf_help {} {
	global ::Hdf::hdf_netcdf
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
	global ::Hdf::nao
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
		::Hdf::hdf_warn "Error in plot_nao:\n $result"
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
		::Hdf::hdf_warn "Error in nap command:\n $result"
	    } else {
		message_window \
			"File: $::Hdf::filename \
			\nVariable: $::Hdf::sds_name \
			\nRange: [$r]" \
			-label range
	    }
	}
    }


    proc file_gui {
	file_type
	extension
	{parent .hdf}
    } {
	set ::Hdf::new_filename [ChooseFile::choose_file $parent *.$extension]
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
	global ::Hdf::nao
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
	if {![winfo exists .hdf.tree.w]} {
	    ::Hdf::create_tree
	}
	if {${::Hdf::sds_name} eq ""} {
	    switch $::Hdf::hdf_netcdf {
		hdf	{error "You have not chosen an SDS!"}
		netcdf	{error "You have not chosen a variable!"}
	    }
	}
	return  ${::Hdf::sds_name}
    }


    # create_tree --
    #
    # Create a tree structure for an HDF file

    proc create_tree {
	{w .hdf}
    } {
	global ::Hdf::filename
	set hdfContents [nap_get $::Hdf::hdf_netcdf -list $filename]
	. config -bd 3 -relief flat
	set tree $w.tree.w
	set sbar $w.tree.sb
	destroy $tree $sbar
	set hdfList [split $hdfContents "\n"]
        # Adjust the tree window size according to the number of items in the file
        set number_items [llength $hdfList]
	set height [expr $number_items > 40 ? 20 : $number_items < 20 ? 10 : $number_items/2]
	Tree $tree -height $height -background white -padx 2 -yscrollcommand "$sbar set"
	scrollbar $sbar -orient vertical -command "$tree yview"
	pack $sbar -side right -fill y
	pack $tree -expand true -fill x -anchor w
	set max_nels 0
	set default_item ""
        set dup 0
        set i 1
	foreach item $hdfList {
	    incr i
	    regsub {:.*} $item "" sds
	    regsub {[^:]*(:|$)} $item "" att
	    set eitem [encode $item]
	    if {"$sds" eq ""} {
		if {![$tree exists /]} {
		    $tree insert end root / -text "Global attributes"
		}
		    # Catch problems caused by duplicate nodes.
		    # Add the characters " D<sequence number>" and set the displayed name to red.
		    # The encrypted name will include the " D<sequence number>" but the displayed
		    # screen tree title will be unchanged.
		if {[catch {$tree insert end / $eitem -text $att} result]} {
                    incr dup
                    set eitem [encode "$item D$dup"]
                    if {[catch {$tree insert end / $eitem -text $att} result]} {
                        tk_messageBox -type ok -icon warning -message \
                        "error $result \nadding duplicate $item D$dup to tree" 
                    } else {
	                $tree itemconfigure $eitem -fill red
                    }
                }
	    } else {
		if {"$att" eq ""} {
		    set shape [hdf_info -shape "$filename" "$sds"]
		    if {[string match "$sds:*" [lindex $hdfList $i]]} {
			set drawcross allways; # Need this (wrong) spelling!
		    } else {
			set drawcross never
		    }
		    if {[catch {$tree insert end root $eitem \
			    -drawcross $drawcross -text "$sds  $shape"} result]} {
                        incr dup
                        set eitem [encode "$item D$dup"]
		        if {[catch {$tree insert end root $eitem -text "$sds  $shape"} result]} {
                            tk_messageBox -type ok -icon warning -message \
                            "error $result \nadding duplicate $item D$dup to tree" 
                        } else {
        	            $tree itemconfigure $eitem -fill red
                        }
                    }
		    set nels [[nap "prod{$shape}"]]
		    if {$nels > $max_nels} {
			set max_nels $nels
			set default_item $sds
                    }
		} else {
		    if {[catch {$tree insert end [encode $sds] $eitem -text $att} result]} {
                        incr dup
                        set eitem [encode "$item D$dup"]
		        if {[catch {$tree insert end [encode $sds] $eitem -text $att} result]} {
                            tk_messageBox -type ok -icon warning -message \
                            "error $result \nadding duplicate $item D$dup to tree" 
                        } else {
	                    $tree itemconfigure $eitem -fill red
                        }
                    }
		}
	    }
	    update idletasks
	}
	$tree bindText <ButtonPress-1> "::Hdf::button_command $tree"
	if {$default_item ne ""} {
	    set ::Hdf::sds_name $default_item
	    button_command $tree [encode $default_item]
	}
        update idletasks
    }


    # destroy_tree --

    proc destroy_tree {
	{w .hdf.tree}
    } {
	set tree $w.w
	if {[$tree exists /]} {
	    $tree delete [$tree nodes root]
	    destroy $tree $w.sb
	    update idletasks
	}
    }


    # encode --
    #
    # convert string to hex (doubling length of string)
    #
    # Example:
    # % encode abc
    # 616263
    # % decode 616263
    # abc

    proc encode {
	s
    } {
	binary scan $s "H*" hex
	return $hex
    }


    # decode --
    #
    # convert hex to string

    proc decode {
	h
    } {
	return [binary format "H*" $h]
    }


    # button_command --

    proc button_command {
	tree
	eitem
    } {
	global ::Hdf::sds_name
	if {$sds_name ne ""} {
	    set old [encode $sds_name]
	    if {![$tree exists $old]} {
		error "Tree item for $sds_name does not exist"
	    }
	    $tree itemconfigure $old -fill black
	}
	if {$eitem ne "/"} {
		# Entries in red are duplicates and should not be changed.
		# This is a temporary fix by Peter Turner
            set colour [$tree itemcget $eitem -fill]
            if {$colour ne "red"} {
	        $tree itemconfigure $eitem -fill DarkViolet
	        set sds_name [decode $eitem]
	        show_index
            }
	}
    }

    # show_index --
    #
    # Display the index widgets in the HDF menu.

    proc show_index {
	{relief ridge}
    } {
	global ::Hdf::filename
	global ::Hdf::sds_name
	global ::Hdf::index
	global ::Hdf::sds_rank
	if {[string length $sds_name] == 0} {
	    return
	}
	set sds_rank [hdf_info -rank $filename $sds_name]
	set shp [hdf_info -shape $filename $sds_name]
	set win .hdf.index
	set win ${win}.sf
	destroy $win
	set names [namespace children [namespace current]::indexWidget]
	if [llength $names] {
	    eval namespace delete $names
	}
	frame ${win} -relief raised -borderwidth 2
	pack ${win} -expand true -fill x -anchor w
	grid propagate ${win}
	grid columnconfigure ${win} 0 -weight 1
	label ${win}.l0 -text "$sds_name"
	grid ${win}.l0 -columnspan 10 -sticky nw
	    # Check for attribute
	if {[string match "*:*" $sds_name]} {
	    label ${win}.l1 -text "attribute size  $shp"
	    grid ${win}.l1 -columnspan 10 -sticky nw
	    return
	}  
	set row [lindex [grid size $win] 1]
	frame $win.hor_line -height 2 -relief $relief -bd 1
	grid $win.hor_line -sticky ew -row $row -column 1 -columnspan 9
	set col 0
	checkbutton $win.raw -text Raw -variable ::Hdf::raw
	grid $win.raw -row [incr row] -column $col
	foreach var {from to step} {
	    frame $win.${var}_vert_line -width 2 -relief $relief -bd 1
	    grid $win.${var}_vert_line -sticky ns -row $row -column [incr col]
	    label $win.$var -text [string toupper $var 0]
	    grid $win.$var -sticky nsew -columnspan 2 -row $row -column [incr col]
	    incr col
	}
	set max_unit_length 10
	for {set i 0} {$i < $sds_rank} {incr i} {
	    set cv [nap_get $::Hdf::hdf_netcdf -coordinate $filename $sds_name $i]
	    if {$cv == ""} {
		set cv$i ""
		set unit($i) ""
	    } else {
		nap "cv$i = $cv"
		set unit($i) [fix_unit [[set cv$i] unit]]
		if {[string equal $unit($i) (NULL)]} {
		    set unit($i) ""
		}
		set max_unit_length [min 20 [max $max_unit_length [string length $unit($i)]]]
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
		    $max_unit_length \
		    $relief
	}
    }

    # fix_unit --
    #
    # Return "°E" if arg is anything equivalent to this e.g. "degreeE"
    # Return "°N" if arg is anything equivalent to this e.g. "degreeN"
    # Return "" if arg is "(NULL)"
    # Otherwise just return arg

    proc fix_unit {
	unit
    } {
	set result [string trim $unit]
	set degree "\xb0"; # ISO-8859 code for degree symbol
	switch -regexp [string tolower $result] {
	    {^\(null\)$}	{set result ""}
	    {^degree.*e}	{set result "${degree}E"}
	    {^degree.*n}	{set result "${degree}N"}
	}
	return $result
    }

    # setIndex --
    #
    # Set the value of the index variable

    proc setIndex {
    } {
	global ::Hdf::filename
	global ::Hdf::sds_rank
	global ::Hdf::sds_name
	# Check for attribute
	if [string match "*:*" $::Hdf::sds_name] {
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
		    ::Hdf::hdf_warn \
			    "setIndex: nap error evaluating index for dimension $i ($name)\n$msg"
		    }
		}
	    }
	    if {$all_blank} {
		set ::Hdf::index ""
	    }
	}
    }

    # set_spin --

    proc set_spin {
	spinbox
	values
	i
    } {
	$spinbox set [lindex $values $i]
    }

    # set_scale --

    proc set_scale {
	scale
	values
	value
    } {
	if {[lindex $values 0] < [lindex $values 1]} {
	    $scale set [lsearch -sorted -real -increasing $values $value]
	} else {
	    $scale set [lsearch -sorted -real -decreasing $values $value]
	}
    }

    namespace eval indexWidget {

	# createIndexWidget --
	#
	# Create a widget to enter spatial scale values.
	#
	# The proceedure requires a window id, a unique
	# id and the CV for the particular scaling operation.

	proc createIndexWidget {
	    parent
	    id
	    dim_name
	    n
	    cvNao
	    unit
	    max_unit_length
	    relief
	} {
	    # Define local variable names
	    #
	    # We use the cv to convert between extrema in index and coordinate space.
	    # However, we calculate the step in index and coordinate space only once
	    namespace eval ${id} {
		variable n;			# size of dimension
		variable cv;			# Coordinate variable for this dimension
		variable from
		variable to
		variable step
	    }
	    set ns [namespace current]
	    global ${ns}::${id}::cv
	    global ${ns}::${id}::from
	    global ${ns}::${id}::to
	    global ${ns}::${id}::step
	    set ${ns}::${id}::n $n
	    set n1 [expr $n - 1]
	    if {$cvNao eq ""} {
		nap "cv = 0 .. n1"
	    } else {
		nap "cv = cvNao"
	    }
	    set row [lindex [grid size $parent] 1]
	    frame $parent.hor_line$id -height 2 -relief $relief -bd 1
	    grid $parent.hor_line$id -sticky ew -row $row -columnspan 10
	    incr row
	    set col 0
	    label $parent.dimname$id -text $dim_name -anchor w \
		-width [min 64 [string length $dim_name]]
	    grid $parent.dimname$id -sticky nsew -row $row -column $col
	    set from_values ""
	    for {set i 0} {$i < $n} {incr i} {
		lappend from_values [[nap "cv(i)"]]
	    }
	    set to_values $from_values
	    if {[$cv step] eq "AP"} {
		set step_values ""
		for {set i 0} {$i < $n} {incr i} {
		    lappend step_values [[nap "cv(i) - cv(0)"]]
		}
	    } else {
		set step_values [[nap "0 .. n1"] value]
	    }
	    set from 0
	    set to  $n1
	    set step  1
	    foreach var {from to step} {
		trace variable $var w ::Hdf::need_read
		set values [set ${var}_values]
		set max_length 0
		foreach value $values {
		    set length [string length $value]
		    if {$length > $max_length} {
			set max_length $length
		    }
		}
		frame $parent.$var${id}vert_line -width 2 -relief $relief -bd 1
		grid $parent.$var${id}vert_line -sticky ns -row $row -column [incr col]
		scale $parent.$var${id}index \
		    -showvalue true -orient horizontal \
		    -from 0 -to $n1 \
		    -variable ${ns}::${id}::$var \
		    -command "::Hdf::set_spin $parent.$var${id}cv.spin {$values}"
		grid $parent.$var${id}index -sticky ew -row $row -column [incr col]
		frame $parent.$var${id}cv
		label $parent.$var${id}cv.label -text $unit
		spinbox $parent.$var${id}cv.spin \
		    -justify right -width $max_length -values $values \
		    -command "::Hdf::set_scale $parent.$var${id}index {$values} %s"
		pack $parent.$var${id}cv.label $parent.$var${id}cv.spin 
		grid $parent.$var${id}cv    -sticky ew -row $row -column [incr col]
		::Hdf::set_spin $parent.$var${id}cv.spin $values [set $var]
	    }
	}

	# getIndex --
	#
	# Return the values of the current spatial sampling indices

	proc getIndex {
	    id
	} {
	    set ns [namespace current]
	    global ${ns}::${id}::n
	    set from [set ${ns}::${id}::from]
	    set to [set ${ns}::${id}::to]
	    set step [set ${ns}::${id}::step]
	    if {$from == $to  ||  $step == 0} {
		return $from
	    } elseif {$from == 0  &&  $to == $n-1  &&  $step == 1} {
		return ""
	    } elseif {($to > $from && $step > 0)  ||  ($from > $to && $step < 0)} {
		return "($from .. $to ... $step)"
	    } else {
		return "($to .. $from ... $step)"
	    }
	}

    }

}
