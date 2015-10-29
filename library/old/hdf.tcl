# hdf.tcl --
#
# HDF/netCDF browser.
#
# Copyright (c) 1998-2002, CSIRO Australia
#
# Authors:
# Harvey Davies, CSIRO Atmospheric Research
# P.J. Turner, CSIRO Atmospheric Research
#
# $Id: hdf.tcl,v 1.98 2004/02/13 06:37:08 dav480 Exp $


# hdf --
#
# Run HDF browser.
#
# Usage
#   hdf ?<PARENT>? ?<GEOMETRY>?
#
# Example
#   hdf . +0+0

proc hdf {
    args
} {
    eval ::Hdf::main hdf $args
}

# netcdf --
#
# Run netCDF browser.
#
# Usage
#   netcdf ?<PARENT>? ?<GEOMETRY>?
#
# Example
#   netcdf . +0+0

proc netcdf {
    args
} {
    eval ::Hdf::main netcdf $args
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
    variable top;		# name of topmost window
    variable windows "";	# list of windows for animation

    # main --
    #
    # Create window with HDF menu, etc.

    proc main {
	{hdf_netcdf hdf}
	{parent .}
	{geometry sw}
    } {
	trace add variable ::Hdf::sds_name write ::Hdf::need_read
	trace add variable ::Hdf::index    write ::Hdf::need_read
	trace add variable ::Hdf::raw      write ::Hdf::need_read
	trace add variable ::Hdf::new_filename write ::Hdf::close_file
	set ::Hdf::filename ""
	set ::Hdf::sds_name ""
	set ::Hdf::hdf_netcdf $hdf_netcdf
        set ::Hdf::top [create_window $hdf_netcdf $parent $geometry $hdf_netcdf]
	switch $hdf_netcdf {
	    hdf		{set extension hdf; set file_type HDF}
	    netcdf	{set extension nc ; set file_type netCDF}
	}
	create_head     $::Hdf::top $extension $file_type
	create_file_gui $::Hdf::top $extension $file_type
    }


    # create_head --
    #
    # Create the row at the top containing: heading, help-button, cancel-button-button-button

    proc create_head {
	top
	extension
	file_type
	{row 0}
    } {
        destroy $top.head
        frame $top.head
	label $top.head.heading -text "$file_type Browser"
        button $top.head.help -text "Help" -command "::Hdf::hdf_help $top"
	button $top.head.cancel -text Cancel -command "destroy $top"
        pack $top.head.heading -side left
        pack $top.head.cancel $top.head.help -side right
	grid $top.head -sticky ew -row $row
    }


    # create_file_gui --
    #
    # Create the GUI for the filename

    proc create_file_gui {
	top
	extension
	file_type
	{row 1}
    } {
	frame $top.file
	button $top.file.open  -text Open -command "::Hdf::open_file $top"
	label $top.file.label -text "file"
	spinbox $top.file.entry \
	    -relief sunken -bd 2 -background white -wrap 1 \
	    -values [glob -nocomplain *.$extension] \
	    -textvariable ::Hdf::new_filename
	bind $top.file.entry <Key-Return> "::Hdf::open_file $top"
	button $top.file.gui -text GUI -command "::Hdf::file_gui $file_type $extension $top"
	pack $top.file.open $top.file.label -side left
	pack $top.file.entry -side left -expand true -fill x
	pack $top.file.gui -side left
	$top.file.entry xview moveto 1.0; # In case filename is too long
	focus $top.file.entry
	grid $top.file -sticky ew -row $row
    }


    # create_tree --
    #
    # Create a tree structure for an HDF file

    proc create_tree {
	top
	{row 2}
    } {
	global ::Hdf::filename
	set hdfContents [nap_get $::Hdf::hdf_netcdf -list $filename]
	. config -bd 3 -relief flat
	set all $top.tree
	destroy $all
	frame $all -background white; # HDF file tree
	grid $all -sticky news -row $row
	grid rowconfigure $top $row -weight 1
	set tree $all.w
	set sbar $all.sb
	destroy $tree $sbar
	set hdfList [split $hdfContents "\n"]
        # Adjust the tree window size according to the number of items in the file
        set number_items [llength $hdfList]
	set height [expr $number_items > 40 ? 20 : $number_items < 20 ? 10 : $number_items/2]
	Tree $tree -height $height -background white -padx 2 -yscrollcommand "$sbar set"
	scrollbar $sbar -orient vertical -command "$tree yview"
	pack $sbar -side right -fill y
	pack $tree -expand true -fill both -anchor w
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
	$tree bindText <ButtonPress-1> "::Hdf::button_command $top $tree"
	if {$default_item ne ""} {
	    set ::Hdf::sds_name $default_item
	    button_command $top $tree [encode $default_item]
	}
        update idletasks
    }


    # create_index_widget --
    #
    # Create the index widget

    proc create_index_widget {
	top
	{ncols 7}
	{row 3}
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
	foreach name [namespace children ::Hdf] {
	    eval namespace delete $name
	}
	    # Define new index grid "$win" which is row 3 of parent grid
	set win $top.index
	destroy $win
	frame $win -relief raised -borderwidth 2
	grid $win -sticky ew -row $row
	grid propagate ${win}
	grid columnconfigure ${win} 0 -weight 1
	    # frame for name of SDS/variable & "raw" checkbutton
	frame ${win}.sds_raw
	label ${win}.sds_raw.name -text "$sds_name"
	pack  ${win}.sds_raw.name -side left
	grid ${win}.sds_raw -columnspan $ncols -sticky news
	    # Check for attribute
	if {[string match "*:*" $sds_name]} {
	    pack ${win}.sds_raw.name
	    label ${win}.att_shape -text "attribute size  $shp"
	    grid ${win}.att_shape -columnspan $ncols -sticky nw
	} else {  
		# "raw" checkbutton
	    checkbutton $win.sds_raw.raw -text Raw -variable ::Hdf::raw
	    pack $win.sds_raw.raw -side right
		# From/To/Step headings
	    set row [lindex [grid size $win] 1]
	    frame $win.hor_line -height 2 -relief $relief -bd 1
	    grid $win.hor_line -sticky ew -row $row -column 0 -columnspan $ncols
	    set col 0
	    incr row
	    set str(from) From
	    set str(to) "To (or expression)"
	    set str(step) "Step (0 = none)"
	    foreach var {from to step} {
		frame $win.${var}_vert_line -width 2 -relief $relief -bd 1
		grid $win.${var}_vert_line -sticky ns -row $row -column [incr col]
		label $win.$var -text $str($var)
		grid $win.$var -sticky nsew -row $row -column [incr col]
	    }
		# 2 rows for each dimension
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
		}
	    }
	    set dim_names [hdf_info -dimension $filename $sds_name]
	    for {set i 0} {$i < $sds_rank} {incr i} {
		::Hdf::createDimWidget \
			${win} \
			$i \
			[lindex $dim_names $i] \
			[lindex $shp $i] \
			[set cv$i] \
			$unit($i) \
			$relief \
			$ncols
	    }
	}
    }


    # create_do_buttons --
    #
    # Create the 'do' buttons along the bottom

    proc create_do_buttons {
	top
	{row 4}
    } {
	destroy $top.do
	frame $top.do
	button $top.do.range -text "Range" -command "::Hdf::hdf_range $top"
	button $top.do.text -text "Text" -command "::Hdf::hdf_text $top"
	button $top.do.graph -text "Graph" -command "::Hdf::hdf_graph $top"
	button $top.do.image -text "Image" -command "::Hdf::hdf_image $top" 
	button $top.do.animate -text "Animate" -command "::Hdf::hdf_animate $top"
	button $top.do.nao -text "NAO" -command "::Hdf::hdf_create_nao $top"
	button $top.do.reread -text Re-read -command ::Hdf::need_read
	pack \
	    $top.do.range \
	    $top.do.text \
	    $top.do.graph \
	    $top.do.image \
	    $top.do.animate \
	    $top.do.nao \
	    $top.do.reread \
	    -side left \
	    -fill x \
	    -expand true \
	    -padx 1 \
	    -pady 2
	grid $top.do -sticky ew -row $row
    }


    # close_file --
    #
    # Called by write trace on variable ::Hdf::new_filename

    proc close_file {
	args
    } {
	destroy $::Hdf::top.tree $::Hdf::top.index $::Hdf::top.do
    }


    # need_read --
    #
    # Called by write trace on variables ::Hdf::sds_name, ::Hdf::index, ::Hdf::raw
    # If any of these change we need to read variable again from file

    proc need_read {
	args
    } {
	set ::Hdf::is_current 0
    }


    # open_file --

    proc open_file {
	top
    } {
	global ::Hdf::filename
	global ::Hdf::new_filename
	if {$new_filename ne ""} {
	    if {[file readable $new_filename]} {
		set filename $new_filename
		create_tree $top
	    } else {
		::Hdf::hdf_warn "Unable to read file $new_filename"
	    }
	}
    }


    # hdf_graph --

    proc hdf_graph {
	top
    } {
	set parent $top.do.graph
	set w $parent.menu
	destroy $w
	if [read_nao $top] {
	    if {[$::Hdf::nao rank] > 1} {
		menu $w
		menu_entry $top $w "graph" 1 xy
		menu_entry $top $w "overlaid graph" 2 xy
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } else {
		draw_image 1 xy $top
	    }
	}
    }

    # hdf_image --

    proc hdf_image {
	top
    } {
	set parent $top.do.image
	set w $parent.menu
	destroy $w
	if [read_nao $top] {
	    if {[$::Hdf::nao rank] > 2} {
		menu $w
		menu_entry $top $w "pseudo-colour image" 2 z
		menu_entry $top $w "tiled pseudo-colour image" 3 tile
		menu_entry $top $w "RGB image" 3 z
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } elseif {[$::Hdf::nao rank] > 1} {
		draw_image 2 z $top
	    } else {
		::Hdf::hdf_warn "rank < 2"
	    }
	}
    }

    # hdf_animate --

    proc hdf_animate {
	top
	{geometry SW}
    } {
	set parent $top.do.animate
	set w $parent.menu
	destroy $w
	if {[llength $::Hdf::windows] > 1} {
	    menu $w
	    $w add command -label "animate last window-sequence" -command "::Hdf::animate"
	    $w add command -label "set animation period" -command "set ::Hdf::delay \
		    \[get_entry {period per window (msec)} -parent $top -text \$::Hdf::delay \
		    -geometry $geometry\]"
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
	top
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
	    $w add command -label $label -command "::Hdf::draw_image $rank_image $type $top"
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
	handle_error $message
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
	top
	{geometry SW}
    } {
	if [read_nao $top] {
	    regsub -all {[^_a-zA-Z0-9]} [::Hdf::hdf_var_name $top] _ ::Hdf::nao_name
	    if [regexp {^[0-9]} $::Hdf::nao_name] {
		set ::Hdf::nao_name _$::Hdf::nao_name
	    }
	    set ::Hdf::nao_name [get_entry "NAO name: " -text $::Hdf::nao_name -width 40 \
		-parent $::Hdf::top -geometry $geometry]
	    if {[catch {uplevel {nap "$::Hdf::nao_name = ::Hdf::nao"}}]} {
		::Hdf::hdf_warn "Unable to create NAO"
	    } else {
		message_window "Created NAO $::Hdf::nao named '$::Hdf::nao_name'" \
		    -parent $top -geometry $geometry
	    }
	}
    }


    # read_nao --
    #
    # Read variable from HDF file into nao
    # Return 1 if OK, 0 for error

    proc read_nao {
	top
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
	    hdf_var_name $top
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

    proc hdf_help {
	top
	{geometry NW}
    } {
	global ::Hdf::hdf_netcdf
	switch $hdf_netcdf {
	    hdf		{set v SDS}
	    netcdf	{set v variable}
	}
	message_window \
	    "1. Press 'Open' to open the selected file.\
	    \n   You can change this selection in four ways:\
	    \n    - Use the spinbox arrows or the up/down arrow keys.\
	    \n    - Type a file name into the entry field.\
	    \n    - Press the 'GUI' button to use an alternative file selection widget.\
	    \n    - Press the 'GUI' button on this widget to change to yet another widget.\
	    \n   Once a file has been selected a 'file structure tree' will appear.\
	    \n\
	    \n2. Select an $v/attribute from the tree using the mouse.\
	    \n   Click '+' to display attributes. Spatial sampling widgets appear for\
	    \n   $v entries. An attribute name and size appears for attributes.\
	    \n   (A ':' is used as a separator in an attribute name. Attributes cannot be\
	    \n   spatially sampled.)\
	    \n\
	    \n3. Select 'Raw' mode if you want the following attributes to be ignored:\
	    \n   scale_factor, add_offset, valid_min, valid_max, valid_range.\
	    \n\
	    \n4. Change the spatial scaling values to your requirements.\
	    \n   Each dimension is represented by a row containing one or two lines.\
	    \n   The first line contains subscript values.\
	    \n   If a coordinate variable exists then its values appear on a second line.\
	    \n   You can change a subscript by:\
	    \n    - using the scale (slider)\
	    \n    - pressing up/down key/screen-arrows in either spinbox\
	    \n    - entering numbers into either entry field.\
	    \n\
	    \n   An arithmetic progression is set using the 'From', 'To' and 'Step' columns.\
	    \n   A scalar value can be set in the 'From' column (with 'Step' = 0).\
	    \n   Other values can be defined using the expression entry which appears in the\
	    \n   'To' column when 'Step' = 0. This expression is evaluated in the Global\
	    \n   namespace.\
	    \n\
	    \n   Thus there are three cases:\
	    \n    - 'Step' > 0: Arithmetic progression.\
	    \n    - 'Step' = 0 and expression defined: Use this expression.\
	    \n    - 'Step' = 0 but expression not defined: Use scalar value of 'From'.\
	    \n\
	    \n5. Use the buttons along the bottom to initiate the following actions.\
	    \n   'Range'   button: Display minimum and maximum value.\
	    \n   'Text'    button: Display start of data as text.\
	    \n   'Graph'   button: Display data as XY graph(s).\
	    \n   'Image'   button: Display data as image(s).\
	    \n   'Animate' button: Animate window-sequence produced by 'Graph' or 'Image'.\
	    \n   'NAO'     button: Create Numeric Array Object.\
	    \n   'Re-read' button: Force a read (e.g. after rewriting the file)." \
	    -parent $top -geometry $geometry -label "$hdf_netcdf help"
    }


    # draw_image --
    #
    # View HDF var using plot_nao

    proc draw_image {
	rank
	type
	top
	{geometry SW}
    } {
	global ::Hdf::nao
	if [read_nao $top] {
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
	    if {[catch {plot_nao $nao -geometry $geometry -parent $top \
		    -rank $rank -title $title -type $type} result]} {
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
	top
	{geometry SW}
    } {
	if [read_nao $top] {
	    if [catch {nap "r = range(::Hdf::nao)"} result] {
		::Hdf::hdf_warn "Error in nap command:\n $result"
	    } else {
		message_window \
			"File: $::Hdf::filename \
			\nVariable: $::Hdf::sds_name \
			\nRange: [$r]" \
			-parent $top -geometry $geometry -label range
	    }
	}
    }


    proc file_gui {
	file_type
	extension
	top
    } {
	set ::Hdf::new_filename [ChooseFile::choose_file $top *.$extension]
    }


    # hdf_text --
    #
    # Read variable from HDF file into nao & then use specified method for this nao

    proc hdf_text {
	top
	{method "all"}
	{c_format ""}
	{max_cols ""}
	{max_lines ""}
	{geometry NW}
    } {
	global ::Hdf::nao
	if [read_nao $top] {
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
		    -parent $top -geometry $geometry -label data
	}
    }


    # hdf_var_name --
    #
    # Return value of HDF::sds_name (which combines names of both sds/var & attribute)
    #
    # Usage:
    #   hdf_var_name

    proc hdf_var_name {
	top
    } {
	if {![winfo exists $top.tree.w]} {
	    ::Hdf::create_tree $top
	}
	if {${::Hdf::sds_name} eq ""} {
	    switch $::Hdf::hdf_netcdf {
		hdf	{error "You have not chosen an SDS!"}
		netcdf	{error "You have not chosen a variable!"}
	    }
	}
	return  ${::Hdf::sds_name}
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
    #
    # create_tree binds button_command to pressing mouse button 1 on sds/att

    proc button_command {
	top
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
	        create_index_widget $top
		create_do_buttons $top
            }
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
    # Set ::Hdf::index to "" or NAO ID of index (e.g. result of nap expression "5,0..9...1")

    proc setIndex {
    } {
	global ::Hdf::filename
	global ::Hdf::sds_rank
	global ::Hdf::sds_name
	set ::Hdf::index ""
	    # Check for attribute
	if {![string match "*:*" $::Hdf::sds_name]} {
	    set list ""
	    for {set i 0} {$i < $sds_rank} {incr i} {
		global ::Hdf::dim${i}::expr
		global ::Hdf::dim${i}::from
		global ::Hdf::dim${i}::n
		global ::Hdf::dim${i}::to
		global ::Hdf::dim${i}::step
		if {$step == 0} {
		    if {$expr eq ""} {
			lappend list $from
		    } else {
			lappend list $expr
		    }
		} elseif {$from == 0  &&  $to == $n-1  &&  $step == 1} {
		    lappend list ""
		} elseif {$from < $to} {
		    lappend list "($from .. $to ... $step)"
		} elseif {$from > $to} {
		    lappend list "($to .. $from ... $step)"
		} else {
		    lappend list $from
		}
	    }
	    set nap_expr [join $list ,]
	    if {![regexp {^,*$} $nap_expr]} {
		uplevel #0 "nap \"::Hdf::index = $nap_expr\""
	    }
	}
    }

    # createDimWidget --
    #
    # Create a widget for specified dimension to allow user to set <from>, <to> & <step>

    proc createDimWidget {
	parent
	dim_num
	dim_name
	dim_size
	cvNao
	unit
	relief
	ncols
	{wraplength 64}
    } {
	set dim_ns "::Hdf::dim$dim_num"
	namespace eval $dim_ns {
	    variable expr "";		# string containing nap expression
	    variable cv "";		# Main coordinate variable
	    variable cv_step "";	# Coordinate variable for 'step'
	    variable from;		# subscript  variable for 'from' spinbox
	    variable from_cv;		# coordinate variable for 'from' entry
	    variable n;			# = dim_size 
	    variable step;		# subscript  variable for 'step' spinbox
	    variable step_cv;		# coordinate variable for 'step' entry
	    variable to;		# subscript  variable for 'to' spinbox
	    variable to_cv;		# coordinate variable for 'to' entry
	}
	global ${dim_ns}::cv
	global ${dim_ns}::cv_step
	global ${dim_ns}::n
	set n $dim_size
	if {$cvNao ne ""} {
	    nap "cv = cvNao"
	    if {[$cv step] eq "AP"} {
		nap "cv_step = cv - cv(0)"
	    }
	}
	    # horizontal line
	set row [lindex [grid size $parent] 1]
	frame $parent.hor_line$dim_num -height 2 -relief $relief -bd 1
	grid $parent.hor_line$dim_num -sticky ew -row $row -columnspan $ncols
	    # main row
	incr row
	    # dim. name
	label $parent.dimname$dim_num -text $dim_name -anchor w -wraplength $wraplength
	grid $parent.dimname$dim_num -sticky news -row $row -column 0 -rowspan 2
	set col 1
	    # from, to, step
	set col [create_from_to_step from 0 $parent $dim_num $unit $relief $row $col $cv]
	set col [create_from_to_step to [expr $n - 1] $parent $dim_num $unit $relief $row $col $cv]
	set col [create_from_to_step step 1 $parent $dim_num $unit $relief $row $col $cv_step]
    }

    # list_max_length --
    #
    # max. no. chars in any element of list

    proc list_max_length {
	list
    } {
	set result 0
	foreach element $list {
	    set length [string length $element]
	    if {$length > $result} {
		set result $length
	    }
	}
	return $result
    }

    # create_from_to_step --
    #
    # Create widget for from, to or step
    # Return index of final column used
    #
    # var is "from", "to" or "step"
    # row & col are those of first (north-west) element of grid to be used
    # If cv is "" then there is no coord variable

    proc create_from_to_step {
	var
	init_value
	parent
	dim_num
	unit
	relief
	row
	col
	{cv ""}
	{scale_length 80}
	{wraplength 64}
    } {
	set dim_ns "::Hdf::dim$dim_num"; # namespace for this dimension
	set sub_var ${dim_ns}::${var};     # name of main (subscript) variable
	set cv_var  ${dim_ns}::${var}_cv;  # name of coordinate variable
	trace add variable $sub_var write ::Hdf::need_read
	set col1 [expr $col + 1]
	set n1 [expr [set ${dim_ns}::n] - 1]
	set expr_entry $parent.expr${dim_num}entry
	if {$var eq "step"} {
	    trace add variable $sub_var write \
		[list ::Hdf::raise_lower_expr_entry $expr_entry]
	}
	    # vertical line
	set vl $parent.$var${dim_num}vert_line
	frame $vl -width 2 -relief $relief -bd 1
	grid $vl -sticky ns -row $row -column $col -rowspan 2
	    # entry for nap expression (hidden at start)
	if {$var eq "to"} {
	    trace add variable ${dim_ns}::expr write ::Hdf::need_read
	    entry $expr_entry -textvariable ${dim_ns}::expr \
		-borderwidth 1 \
		-background white -highlightthickness 1 -width 0
	    grid $expr_entry -sticky news -row $row -column $col1
	    bind $expr_entry <Enter> "focus $expr_entry"
	}
	    # frame for upper row of from/to/step
	set sub_upper $parent.$var${dim_num}sub_upper
	set sub_lower $parent.$var${dim_num}sub_lower
	frame $sub_upper
	grid $sub_upper -sticky news -row $row  -column $col1
	    # spinbox for subscript
	set sub_spin $sub_upper.spin
	spinbox $sub_spin \
	    -from 0 -to $n1 -width [string length $n1] -textvariable $sub_var \
	    -validate key -validatecommand {regexp {^[0-9]*$} %P} \
	    -borderwidth 1 \
	    -justify right -background white -highlightthickness 1
	pack $sub_spin -side left
	bind $sub_spin <Enter> "focus $sub_spin"
	    # scale (slider) for subscript
	set sub_scale $sub_upper.scale
	scale $sub_scale -showvalue 0 -orient horizontal -from 0 -to $n1 -variable $sub_var \
	    -borderwidth 1 \
	    -highlightthickness 1 -digits [string length $n1] -length $scale_length
	pack $sub_scale -side left
	    # Default scale Up/Down bindings are reverse of what we want!
	bind $sub_scale <Up>   "[bind Scale <Down>]; break"
	bind $sub_scale <Down> "[bind Scale <Up>]  ; break"
	bind $sub_scale <Enter> "focus $sub_scale"
	    # coord. var
	if {$cv ne ""} {
		# frame for lower (cv) row of from/to/step
	    incr row
	    frame $sub_lower
	    grid $sub_lower -sticky news -row $row -column $col1
		# entry for coord. var
	    set cv_entry $sub_lower.entry
	    entry $cv_entry -justify right -background white -highlightthickness 1 \
		-width [list_max_length [[nap "cv(-9 .. 9)"] value]] \
		-borderwidth 1 -textvariable $cv_var
	    bind $sub_lower <Enter> "focus $cv_entry"
	    bind $cv_entry <Up>   "$sub_spin invoke buttonup"
	    bind $cv_entry <Down> "$sub_spin invoke buttondown"
	    bind $cv_entry <Leave>  [list ::Hdf::cv_entry_text $cv_var $sub_var $cv]
	    bind $cv_entry <Return> [list ::Hdf::cv_entry_text $cv_var $sub_var $cv]
	    trace add variable $sub_var write [list ::Hdf::set_cv_entry $cv_var $cv]
	    pack $cv_entry -side left
		# label for units of coord. var
	    set cv_unit $sub_lower.label
	    label $cv_unit -text $unit -anchor w -wraplength $wraplength
	    pack $cv_unit -side left
	}
	    # initialise subscript variable
	set $sub_var $init_value
	return [expr $col + 2]
    }

    # raise_lower_expr_entry --
    #
    # If subscript is 0 then raise expr entry, else lower it to reveal subscript-spinbox & scale

    proc raise_lower_expr_entry {
	win
	name1
	name2
	op
    } {
	if {[set $name1] == 0} {
	    raise $win
	} else {
	    lower $win
	}
    }

    # set_cv_entry --
    #
    # Keep cv entry in sync with subscript variable

    proc set_cv_entry {
	cv_var
	cv
	name1
	name2
	op
    } {
	set $cv_var [[nap "cv($name1)"]]
    }

    # cv_entry_text --
    #
    # Handle text typed into cv entry
    # Keeps subscript variable in sync with cv entry 
    # Use @@ to set subscript to that of nearest element in coord. var.
    # This causes text in entry to change to this value

    proc cv_entry_text {
	cv_var
	sub_var
	cv
    } {
	if {[string is double -strict [set $cv_var]]} {
	    set $sub_var [[nap "cv @@ $cv_var"]]
	}
    }

}
