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
# $Id: hdf.tcl,v 1.106 2004/07/08 04:32:50 dav480 Exp $


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

namespace eval ::Hdf {

    # main --
    #
    # Create window with HDF menu, etc.

    proc main {
	{hdf_or_netcdf hdf}
	{parent .}
	{geometry sw}
	{min_width 400}
    } {
        set top [create_window $hdf_or_netcdf $parent $geometry $hdf_or_netcdf flat 2]
	switch $hdf_or_netcdf {
	    hdf		{set extension hdf; set file_type HDF}
	    netcdf	{set extension nc ; set file_type netCDF}
	}
        if {$hdf_or_netcdf == "hdf"} {
            wm title $top "HDF Browser" 
        } else {
            wm title $top "netCDF Browser"
        }
	set top_ns ::Hdf::t[string map {. _} $top]; # top namespace
	namespace eval $top_ns {
	    variable delay 500;		# time (msec) between windows (frames) of animation
	    variable filename ""
	    variable hdf_netcdf;	# "hdf" or "netcdf"
	    variable index "";		# subscript of NAO
	    variable is_current 0;	# 1 means nao is up-to-date
	    variable nao "";		# points to NAO
	    variable nao_name "";	# name specified by user
	    variable raw 0;		# 1 means want raw data (ignoring scale_factor, etc.)
	    variable sds_name "";	# sds-name : attribute-name
	    variable sds_rank ""
	    variable windows "";	# list of windows for animation
            variable area_select "";	# Area selection set externally 
	}
	set ${top_ns}::hdf_netcdf $hdf_or_netcdf
	grid columnconfigure $top 0 -weight 1 -minsize $min_width
	create_head     $top_ns $top $extension $file_type
	create_file_gui $top_ns $top $extension
	trace add variable ${top_ns}::sds_name  write "::Hdf::need_read $top_ns"
	trace add variable ${top_ns}::index     write "::Hdf::need_read $top_ns"
	trace add variable ${top_ns}::raw       write "::Hdf::need_read $top_ns"
        trace add variable ${top_ns}::area_select write "::Hdf::adjust_area $top_ns"
    }


    # create_head --
    #
    # Create the row at the top containing: heading, help-button, cancel-button-button-button

    proc create_head {
	top_ns
	top
	extension
	file_type
    } {
        destroy $top.head
        frame $top.head
#
# Removed all the works here and shoved into choose file!
#	label $top.head.heading -text "$file_type Browser" -font {Helvetica -12 bold}
#        set px 0
#        set py 1
#        button $top.head.help -text "Help" -relief groove -padx $px -pady $py \
#            -command "::Hdf::hdf_help $top_ns $top"
#	button $top.head.cancel -text Cancel -relief groove -padx $px -pady $py \
#            -command "destroy $top"
#        pack $top.head.heading -side left
#        pack $top.head.cancel $top.head.help -side right
	grid $top.head -sticky ew 
    }


    # create_file_gui --
    #
    # Create the GUI for the filename

    proc create_file_gui {
	top_ns
	top
	extension
    } {
	set all $top.file
	destroy $all
	::ChooseFile::choose_file_gui $all \
            "::Hdf::open_file $top_ns $top" \
            "::Hdf::hdf_help $top_ns $top" \
            "destroy $top" \
            *.$extension
	grid $all -sticky news
    }


    # create_tree --
    #
    # Create a tree structure for an HDF file

    proc create_tree {
	top_ns
	top
    } {
	global ${top_ns}::filename
	global ${top_ns}::hdf_netcdf
	set hdfContents [nap_get $hdf_netcdf -list "$filename"]
	. config -bd 3 -relief flat
	set all $top.tree
	destroy $top.tree $top.att_heading $top.sds_heading $top.index $top.do
	frame $all -background white; # HDF file tree
	set row [lindex [grid size $top] 1] 
	grid $all -sticky news
	grid rowconfigure $top $row -weight 1
	set tree $all.w
	set sbar $all.sb
	destroy $tree $sbar
	set hdfList [split $hdfContents "\n"]
        #
        # Adjust the tree window size according to the number of SDS/Variables in the file
        set number_items [llength $hdfList]
        set number_att 0
        foreach item $hdfList {
            if [string match {*:*} $item] {
                incr number_att
            }
        } 
        set number_sds [expr $number_items - $number_att]
        #
        # Set the height of the tree window
	set height [expr $number_sds > 20 ? 22 : \
            ($number_sds < 5 ? 5 : [expr $number_sds + 2])]
	Tree $tree -height $height -background white -padx 2 -yscrollcommand "$sbar set"
	scrollbar $sbar -orient vertical -command "$tree yview"
	pack $sbar -side right -fill y
	pack $tree -expand true -fill both -anchor w
	set max_nels 0
	set default_item ""
        set dup 0
        set i 0
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
		    set shape [hdf_info $top_ns -shape "$filename" "$sds"]
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
	$tree bindText <ButtonPress-1> "::Hdf::button_command $top_ns $top $tree"
	if {$default_item ne ""} {
	    set ${top_ns}::sds_name $default_item
	    button_command $top_ns $top $tree [encode $default_item]
	}
        update idletasks
    }


    # create_index_widget --
    #
    # Create the index widget

    proc create_index_widget {
	top_ns
	top
	{ncols 7}
	{relief ridge}
    } {
	global ${top_ns}::filename
	global ${top_ns}::hdf_netcdf
	global ${top_ns}::sds_name
	global ${top_ns}::index
	global ${top_ns}::sds_rank
	set sds_rank [hdf_info $top_ns -rank $filename $sds_name]
	set shp [hdf_info $top_ns -shape $filename $sds_name]
	foreach name [namespace children ${top_ns}] {
	    eval namespace delete $name
	}
	    # Define new index grid "$win" (which is row of parent grid)
	set win $top.index
	frame $win -relief ridge -borderwidth 2
	grid $win -sticky ew
	grid columnconfigure $win 0 -weight 1
	grid columnconfigure $win 2 -weight 1
	grid columnconfigure $win 4 -weight 1
	grid columnconfigure $win 6 -weight 1
	    # From/To/Step headings
	set row [lindex [grid size $win] 1]
	set col 0
	label $win.dim -text Dimension -anchor w
	grid $win.dim -sticky w -row $row -column $col
	set str(from) From
	set str(to) "To (or expression)"
	set str(step) "Step (0 = none)"
	foreach var {from to step} {
	    frame $win.${var}_vert_line -width 2 -relief $relief -bd 1
	    grid $win.${var}_vert_line -sticky ns -row $row -column [incr col]
	    label $win.$var -text $str($var) -anchor w
	    grid $win.$var -sticky nsew -row $row -column [incr col]
	}
	    # 2 rows for each dimension
	for {set i 0} {$i < $sds_rank} {incr i} {
	    set cv [nap_get $hdf_netcdf -coordinate "$filename" $sds_name $i]
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
	set dim_names [hdf_info $top_ns -dimension "$filename" $sds_name]
	for {set i 0} {$i < $sds_rank} {incr i} {
	    ::Hdf::createDimWidget \
		    $top_ns \
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


    # create_do_buttons --
    #
    # Create the 'do' buttons along the bottom

    proc create_do_buttons {
	top_ns
	top
    } {
	frame $top.do
        set px 0
        set py 1
        set rl raised
	checkbutton $top.do.raw -text Raw -variable ${top_ns}::raw -anchor w
	button $top.do.range -text "Range" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_range $top_ns $top"
	button $top.do.text -text "Text" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_text $top_ns $top"
	button $top.do.graph -text "Graph" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_graph $top_ns $top"
	button $top.do.image -text "Image" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_image $top_ns $top" 
	button $top.do.animate -text "Animate" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_animate $top_ns $top"
	button $top.do.nao -text "NAO" -relief $rl -padx $px -pady $py \
            -command "::Hdf::hdf_create_nao $top_ns $top"
	button $top.do.reread -text Re-read -relief $rl -padx $px -pady $py \
            -command "::Hdf::need_read $top_ns"
	pack \
	    $top.do.raw \
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
	grid $top.do -sticky ew
    }


    # need_read --
    #
    # Called by write trace on top namespace variables sds_name, index, raw
    # If any of these change we need to read variable again from file

    proc need_read {
	top_ns
	args
    } {
	set ${top_ns}::is_current 0
    }


    # open_file --

    proc open_file {
	top_ns
	top
	{new_filename ""}
    } {
	global ${top_ns}::filename
	if {"$new_filename" eq ""  ||  "$new_filename" eq "."} {
	    ::Hdf::hdf_warn "Filename is blank"
	} else {
	    if {[file readable "$new_filename"] && ![file isdirectory "$new_filename"]} {
		set filename "$new_filename"
		create_tree $top_ns $top
	    } else {
		::Hdf::hdf_warn "Unable to read file $new_filename"
	    }
	}
    }


    # hdf_graph --

    proc hdf_graph {
	top_ns
	top
    } {
	global ${top_ns}::nao
	set parent $top.do.graph
	set w $parent.menu
	destroy $w
	if [read_nao $top_ns $top] {
	    if {[$nao rank] > 1} {
		menu $w
		menu_entry $top_ns $top $w "graph" 1 xy
		menu_entry $top_ns $top $w "overlaid graph" 2 xy
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } else {
		draw_image $top_ns 1 xy $top
	    }
	}
    }

    # hdf_image --

    proc hdf_image {
	top_ns
	top
    } {
	global ${top_ns}::nao
	set parent $top.do.image
	set w $parent.menu
	destroy $w
	if [read_nao $top_ns $top] {
	    if {[$nao rank] > 2} {
		menu $w
		menu_entry $top_ns $top $w "pseudo-colour image" 2 z
		menu_entry $top_ns $top $w "tiled pseudo-colour image" 3 tile
		menu_entry $top_ns $top $w "RGB image" 3 z
		$w add command -label cancel -command "destroy $w"
		$w post [winfo rootx $parent] [expr [winfo rooty $parent] + [winfo height $parent]]
	    } elseif {[$nao rank] > 1} {
		draw_image $top_ns 2 z $top
	    } else {
		::Hdf::hdf_warn "rank < 2"
	    }
	}
    }

    # hdf_animate --

    proc hdf_animate {
	top_ns
	top
	{geometry SW}
    } {
	global ${top_ns}::windows
	set parent $top.do.animate
	set w $parent.menu
	destroy $w
	if {[llength $windows] > 1} {
	    menu $w
	    $w add command -label "animate last window-sequence" -command "::Hdf::animate $top_ns"
	    $w add command -label "set animation period" -command "set ${top_ns}::delay \
		    \[get_entry {period per window (msec)} -parent $top -text \$${top_ns}::delay \
		    -geometry $geometry\]"
	    $w add command -label "delete last window-sequence" \
		    -command "eval destroy \$${top_ns}::windows; set ${top_ns}::windows {}"
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
	top_ns
	top
	w
	label
	rank_image
	type
    } {
	global ${top_ns}::nao
	nap "i = rank(nao) - rank_image"
	set n [[nap "i < 0 ? 0 : prod((shape(nao))(0 .. (i-1) ... 1))"]]
	if {$n > 1} {
	    set label "$n ${label}s"
	}
	if {$n > 0} {
	    $w add command -label $label -command "::Hdf::draw_image $top_ns $rank_image $type $top"
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
	top_ns
	flag
	filename
	var_name
    } {
	global ${top_ns}::hdf_netcdf
	set command [list nap_get $hdf_netcdf $flag "$filename" $var_name]
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
	top_ns
	top
	{geometry SW}
    } {
	global ${top_ns}::nao
	global ${top_ns}::nao_name
	if [read_nao $top_ns $top] {
	    set str [::Hdf::hdf_var_name $top_ns $top]
	    if [regexp {^:} $str] {
		set str [string range $str 1 end]
	    }
	    regsub -all {[^_a-zA-Z0-9]} $str _ nao_name
	    if [regexp {^[0-9]} $nao_name] {
		set ::Hdf::nao_name _$nao_name
	    }
	    set nao_name [get_entry "NAO name: " -text $nao_name -width 40 \
		-parent $top -geometry $geometry]
	    if {[catch {uplevel "nap $nao_name = $nao"}]} {
		::Hdf::hdf_warn "Unable to create NAO"
	    } else {
                # Do not do this it is a pain
		# message_window "Created NAO $nao named '$nao_name'" \
		#    -parent $top -geometry $geometry
	    }
	}
    }


    # read_nao --
    #
    # Read variable from HDF file into nao
    # Return 1 if OK, 0 for error

    proc read_nao {
	top_ns
	top
    } {
	global ${top_ns}::filename
	global ${top_ns}::hdf_netcdf 
	global ${top_ns}::index
	global ${top_ns}::nao
	global ${top_ns}::sds_name
	global ${top_ns}::is_current
	global ${top_ns}::raw
	set status 0
	if {$is_current} {
	    set status 1
	} elseif {$filename ne ""} {
	    hdf_var_name $top_ns $top
	    setIndex $top_ns
	    if {[catch {nap "nao = [nap_get $hdf_netcdf $filename $sds_name $index $raw]"}]} {
		::Hdf::hdf_warn "Unable to read NAO"
	    } else {
	        set status 1
	        set is_current 1
                #
                # If the SDS has no CV and we index into it we want to add
                # the index as a CV so we do not loose the relationship with the
                # original SDS index. 
                #
                # Look at the CVs only if there is indexing defined
                # Note that index is a boxed nao. index contains a list of
                # slot numbers for naos indexing each dimension
                #
                # Summary
                # If the SDS has been read using an index and the SDS
                # had no CV for a dimension then attach the index for
                # that dimension as a CV for the retrieved nao (called nao)
                # In this way we retain the relational information
                # in the resampled nao and the original SDS. This addition
                # only applies where there is no CV in the first place.
                # If CVs are present the relationship is automatically retained. 
                # The benefit it that large images can be displayed in sub sampled
                # mode and the spatial scale displayed still relates to the
                # spatial scale in the original SDS. This makes it easier
                # to select a further subset. 
                # Peter J Turner CSIRO Marine Research Nov 2004
                if {[string length $index] > 0} {
                    # Get the coordinate variables associated with nao
                    #
                    set cv [$nao coordinate]
                    # cv contains nao ids or (NULL)
                    set dn 0
                    set aindex [$index]
                    #
                    # We need to preprocess the boxed index array. If
                    # any of the indices are scalar it means that the
                    # related dimension has been removed from the NAO!
                    # Note that we should be able to do 
                    # isPresent(index(dn)) but there appears to be a bug in nap
                    set dn 0
                    set cvi 0
                    # aindex will always have >= number of elements to
                    # cv. However some elments in aindex maybe scalar
                    # indicating a collapsed dimension.
                    foreach bindx $aindex {
                       set dim [lindex $cv $cvi]
                       if {$bindx == "_"} {
                           if {$dim == "(NULL)"} { 
                               lappend newcv ""
                           } else {
                               lappend newcv $dim
                           }
                           incr cvi
                       } else {
                           nap ncv = open_box(index(dn))
                           if {[$ncv rank]} {
                               if {$dim == "(NULL)"} { 
                                   lappend newcv $ncv
                               } else {
                                   lappend newcv $dim
                               }
                               incr cvi
                           }
                       }
                       incr dn
                    } 
                    # Attach the new and old CVs
                    eval $nao set coord $newcv
                }
	    }
	}
	return $status
    }


    # hdf_help --
    #
    # Display help.

    proc hdf_help {
	top_ns
	top
	{geometry NW}
    } {
	global ${top_ns}::hdf_netcdf 
	switch $hdf_netcdf {
	    hdf		{set v SDS}
	    netcdf	{set v variable}
	}
	message_window \
	    "1. Select an input file using any of the following:\
	    \n   - Type into any of the three entry fields.\
	    \n   - Press the 'Dialog' buttons to display new widgets.\
	    \n   - Click on the spinbox arrows.\
	    \n   - Press the keyboard up/down keys.\
	    \n   If any field is too narrow then resize the window by dragging its edge.\
	    \n\
	    \n2. Press 'Open' and a file structure tree should appear.\
	    \n\
	    \n3. Use this tree as follows:\
	    \n   Click on a '+' to display attribute names.\
	    \n   Click on a $v to display the spatial sampling widget.\
	    \n   Click on an attribute to display its value.\
	    \n\
	    \n4. The spatial sampling widget allows you to select part of a $v.\
	    \n   (The entire $v is selected by default.)\
	    \n\
	    \n   Each dimension is represented by a row containing one or two lines.\
	    \n   The first line represents subscript values.\
	    \n   If a coordinate variable exists then it is represented on a second line.\
	    \n\
	    \n   Change a subscript using any of the following:\
	    \n   - Drag the scale (slider). This is convenient for coarse adjustment.\
	    \n   - Click on the spinbox arrows or scale troughs.\
	    \n   - Press keyboard up/down keys.\
	    \n   - Use keyboard to enter numbers.\
	    \n\
	    \n   The values selected along a dimension are defined as follows:\
	    \n   If 'Step' > 0 then 'From', 'To' and 'Step' define arithmetic progression.\
	    \n   If 'Step' = 0 and expression is blank then use single value 'From'.\
	    \n   If 'Step' = 0 and expression is not blank then use this expression.\
	    \n\
	    \n5. Use the buttons along the bottom to do the following:\
	    \n   'Range':   Display minimum and maximum value.\
	    \n   'Text':    Display start of data as text.\
	    \n   'Graph':   Display data as XY graph(s).\
	    \n   'Image':   Display data as image(s).\
	    \n   'Animate': Animate window-sequence produced by 'Graph' or 'Image'.\
	    \n   'NAO':     Create Numeric Array Object.\
	    \n   'Re-read': Force a read (e.g. after rewriting the file). \
	    \n\
	    \n   Select 'Raw' mode if you want the following attributes to be ignored:\
	    \n   scale_factor, add_offset, valid_min, valid_max, valid_range."\
	    -parent $top -geometry $geometry -label "$hdf_netcdf help"
    }


    # draw_image --
    #
    # View HDF var using plot_nao

    proc draw_image {
	top_ns
	rank
	type
	top
	{geometry -0+0}
    } {
	global ${top_ns}::nao 
	global ${top_ns}::sds_name
	global ${top_ns}::windows
	if [read_nao $top_ns $top] {
	    set label [string trim [$nao label]]
	    set unit  [string trim [$nao unit]]
	    if {[string equal $unit (NULL)]} {
		set unit ""
	    }
	    set title $sds_name
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
		    set windows $result
		    raise .
		}
	    }
	}
    }


    # animate --

    proc animate {
	top_ns
    } {
	global ${top_ns}::delay 
	global ${top_ns}::windows 
	set ms 0
	foreach win "$windows ." {
	    after $ms "raise $win; update idletasks"
	    incr ms $delay
	}
    }
    

    # hdf_range --
    #
    # Display range

    proc hdf_range {
	top_ns
	top
	{geometry SW}
    } {
	global ${top_ns}::filename
	global ${top_ns}::nao 
	global ${top_ns}::sds_name
	if [read_nao $top_ns $top] {
	    if [catch {nap "r = range(nao)"} result] {
		::Hdf::hdf_warn "Error in nap command:\n $result"
	    } else {
		message_window \
			"File: $filename \
			\nVariable: $sds_name \
			\nRange: [$r]" \
			-parent $top -geometry $geometry -label range
	    }
	}
    }


    # hdf_text --
    #
    # Read variable from HDF file into nao & then use specified method for this nao

    proc hdf_text {
	top_ns
	top
	{method "all"}
	{c_format ""}
	{max_cols ""}
	{max_lines ""}
	{geometry NW}
    } {
	global ${top_ns}::filename
	global ${top_ns}::nao 
	global ${top_ns}::sds_name
	if [read_nao $top_ns $top] {
	    if [regexp c8 [$nao datatype]] {
		default max_cols -1
		default max_lines -1
	    } else {
		default max_cols 50
		default max_lines 100
	    }
	    message_window \
		    "File: $filename \
		    \nVariable: $sds_name \
		    \n[$nao $method -format $c_format -columns $max_cols -lines $max_lines]" \
		    -parent $top -geometry $geometry -label data
	}
    }


    # hdf_var_name --
    #
    # Return value of sds_name (which combines names of both sds/var & attribute)
    #
    # Usage:
    #   hdf_var_name

    proc hdf_var_name {
	top_ns
	top
    } {
	global ${top_ns}::hdf_netcdf
	global ${top_ns}::sds_name
	if {![winfo exists $top.tree.w]} {
	    ::Hdf::create_tree $top_ns $top
	}
	if {$sds_name eq ""} {
	    switch $hdf_netcdf {
		hdf	{error "You have not chosen an SDS!"}
		netcdf	{error "You have not chosen a variable!"}
	    }
	}
	return  $sds_name
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


    # create_att_heading_widget --
    #
    # Create widget containing:
    #   name of SDS/variable
    #   name of attribute
    #   value of attribute

    proc create_att_heading_widget {
	top_ns
	top
    } {
	global ${top_ns}::filename
	global ${top_ns}::hdf_netcdf
	global ${top_ns}::sds_name
        #
        # Check string lengths and make sure nothing exceeds 64 characters
        set too_long 64
	set f $top.att_heading
	frame $f -relief flat -borderwidth 2
	set type(hdf) SDS
	set type(netcdf) Variable
	grid $f -sticky nw -pady 2
	set sds_att [split $sds_name :]
        set sds [lindex $sds_att 0]
	set att [lindex $sds_att 1]
        #
        # Get the attribute value
        set aval [[nap_get $hdf_netcdf $filename $sds_name]]
        #
        # If the value is too long truncate and add ... at the end!
        if {[string length $aval] > $too_long} {
            set aval "[string range $aval 0 [expr $too_long - 4]] ..."
        }
        set row 0
        set col 0
        #
        # Treat these two cases separately because it gets too messy otherwise
	if {$sds eq ""} {
	    set att_name {Global attribute}
            set att_string "$att_name $att Value $aval"
            #
            # Global Attribute and name
            label $f.att -text $att_name -font {fixed 10 bold}
            label $f.att_val -text $att -font {fixed 10 normal}
            grid $f.att -row $row -column 0 -sticky sw
            grid $f.att_val -row $row -column 1 -sticky sw -padx 8
            #
            # See if the value will fit too!
            set row0 "$att_name $att Value $aval"    
            set col 2
            if {[string length $row0] > $too_long} {
                incr row
                set col 0
            }
            #
	    # Write the attribute value
	    label $f.value -text Value -font {Helvetica -12 bold}
	    label $f.value_val -text $aval -font {Helvetica -12 normal}
            grid $f.value -row $row -column [expr 0 + $col] -sticky nw
            grid $f.value_val -row $row -column [expr 1 + $col] -sticky sw -padx 8
	} else {
            set att_name {Attribute}
            set att_string "$att_name $att Value $aval"
            #
            # Write the SDS name
            label $f.sds -text $type($hdf_netcdf) -font {Helvetica -12 bold}
            label $f.sds_val -text $sds -font {Helvetica -12 normal} 
            grid $f.sds -row $row -column 0 -sticky sw
	    grid $f.sds_val -row $row -column 1 -sticky sw -padx 8
            set row0 "$type($hdf_netcdf) $sds"
            set col 2
            #
            # Check that we are not going to be too long
            # Write the attribute header and name
            set row0 "$row0 $att_name $att"
            if {[string length $row0] > $too_long} {
                incr row
                set col 0
            }
            label $f.att -text $att_name -font {Helvetica -12 bold}
            label $f.att_val -text $att -font {Helvetica -12 normal}
            grid $f.att -row $row -column [expr 0 + $col] -sticky sw
            grid $f.att_val -row $row -column [expr 1 + $col] -sticky sw -padx 8
            incr row
            #
            # Write the attribute value
            label $f.value -text Value -font {Helvetica -12 bold}
            label $f.value_val -text $aval -font {Helvetica -12 normal} 
            grid $f.value -row $row -column 0 -sticky sw
            grid $f.value_val -row $row -column 1 -sticky sw -padx 8
        }
    }


    # create_sds_heading_widget --
    #
    # Create widget containing name of SDS/variable, long_name, units

    proc create_sds_heading_widget {
	top_ns
	top
	{max_width 70}
    } {
	global ${top_ns}::filename
	global ${top_ns}::hdf_netcdf
	global ${top_ns}::sds_name
        #
        # Check string lengths do not exceed 64 characters
        set too_long 64

	set f $top.sds_heading
	frame $f -relief flat -bd 2
	grid $f -sticky w -pady 2
	set type(hdf) SDS
	set type(netcdf) Variable
        set row 0
        #
        # SDS/Variable Name
        label $f.sds -text $type($hdf_netcdf) -font {Helvetica -12 bold}
        label $f.sds_val -text $sds_name -font {Helvetica -12 normal}
        grid $f.sds -row $row -column 0 -sticky sw
        grid $f.sds_val -row $row -column 1 -sticky sw -padx 8
        #
        # Units
	if {[catch {[nap_get $hdf_netcdf $filename ${sds_name}:units]} text]} {
	} else {
            label $f.units -text "Units" -font {Helvetica -12 bold}
            label $f.units_val -text $text -font {Helvetica -12 normal}
            grid $f.units -row $row -column 2 -sticky sw -padx 16
            grid $f.units_val -row $row -column 3 -sticky sw -padx 8
	}
        #
        # long Name
	if {[catch {[nap_get $hdf_netcdf $filename ${sds_name}:long_name]} text]} {
	} else {
            incr row
            label $f.ln -text "Long Name" -font {Helvetica -12 bold}
            label $f.ln_val -text $text -font {Helvetica -12 normal}
            grid $f.ln -row $row -column 0 -sticky sw
            grid $f.ln_val -row $row -column 1 -columnspan 3 -sticky sw -padx 8
	}
    }


    # button_command --
    #
    # create_tree binds button_command to pressing mouse button 1 on sds/att

    proc button_command {
	top_ns
	top
	tree
	eitem
	{max_width 450}
    } {
	global ${top_ns}::sds_name
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
	        $tree itemconfigure $eitem -fill blue
	        set sds_name [decode $eitem]
		if {$sds_name ne ""} {
		    destroy $top.att_heading $top.sds_heading $top.index $top.do
		    if {[string match "*:*" $sds_name]} {
			create_att_heading_widget $top_ns $top
		    } else {
			create_sds_heading_widget $top_ns $top
			create_index_widget $top_ns $top
		    }
		    create_do_buttons $top_ns $top
		}
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
    # Set index to "" or NAO ID of index (e.g. result of nap expression "5,0..9...1")

    proc setIndex {
	top_ns
    } {
	global ${top_ns}::sds_rank
	global ${top_ns}::sds_name
	set ${top_ns}::index ""
	    # Check for attribute
	if {![string match "*:*" $sds_name]} {
	    set list ""
	    for {set i 0} {$i < $sds_rank} {incr i} {
		set dim_ns "${top_ns}::dim$i"
		global ${dim_ns}::expr
		global ${dim_ns}::from
		global ${dim_ns}::n
		global ${dim_ns}::to
		global ${dim_ns}::step
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
		uplevel #0 "nap \"${top_ns}::index = $nap_expr\""
	    }
	}
    }

    # createDimWidget --
    #
    # Create a widget for specified dimension to allow user to set <from>, <to> & <step>

    proc createDimWidget {
	top_ns
	parent
	dim_num
	dim_name
	dim_size
	cvNao
	unit
	relief
	ncols
    } {
	set dim_ns "${top_ns}::dim$dim_num"
	namespace eval $dim_ns {
	    variable expr "";		# string containing nap expression
	    variable cv "";		# Main coordinate variable
	    variable cvs "";		# Coordinate variable for 'step'
	    variable from;		# subscript  variable for 'from' spinbox
	    variable from_cv;		# coordinate variable for 'from' entry
	    variable n;			# = dim_size 
	    variable step;		# subscript  variable for 'step' spinbox
	    variable step_cv;		# coordinate variable for 'step' entry
	    variable step_slider;	# slider value
	    variable step_sindex;	# slider index cv
	    variable to;		# subscript  variable for 'to' spinbox
	    variable to_cv;		# coordinate variable for 'to' entry
	}
	global ${dim_ns}::cv
	global ${dim_ns}::cvs
	set ${dim_ns}::n $dim_size
	set n1 [expr $dim_size - 1]
	if {$cvNao ne ""} {
	    nap "cv = cvNao"
	    if {[$cv step] eq "AP"} {
		nap "cvs = cv - cv(0)"
	    }
	}
	    # horizontal line
	set row [lindex [grid size $parent] 1]
	frame $parent.hor_line$dim_num -height 2 -relief $relief -bd 1
	grid $parent.hor_line$dim_num -sticky ew -row $row -columnspan $ncols
	    # main row
	incr row
	    # dim. name
	label $parent.dimname$dim_num -text $dim_name -anchor w
	grid $parent.dimname$dim_num -sticky news -row $row -column 0 -rowspan 2
	set col 1
	    # from, to, step
	set col [create_from_to_step $top_ns from 0 $parent $dim_num $unit $relief $row $col $cv]
	set col [create_from_to_step $top_ns to $n1 $parent $dim_num $unit $relief $row $col $cv]
	set col [create_from_to_step $top_ns step 1 $parent $dim_num $unit $relief $row $col $cvs]
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
	top_ns
	var
	init_value
	parent
	dim_num
	unit
	relief
	row
	col
	{cv ""}
    } {
	set dim_ns "${top_ns}::dim$dim_num"
	set sub_var ${dim_ns}::${var};     # name of main (subscript) variable
	set cv_var  ${dim_ns}::${var}_cv;  # name of coordinate variable
	trace add variable $sub_var write "::Hdf::need_read $top_ns"
	set col1 [expr $col + 1]
	set n1 [expr [set ${dim_ns}::n] - 1]
	set expr_entry $parent.expr${dim_num}entry
        #
        # Entry space
        set entsp [string length $n1]
        set nonlinear 0
	if {$var eq "step"} {
	    trace add variable $sub_var write \
		[list ::Hdf::raise_lower_expr_entry $expr_entry]
            # 
            # Treat step slider as a special case if there
            # are more than 64 index values!
            # 
            if {$n1 > 64} {
	        set step_slider  ${dim_ns}::${var}_slider; # slider index value 
	        set step_sindex  ${dim_ns}::${var}_sindex; # slider index cv 
                set $step_slider 1 
                nap sstp = (n1 - 16)/48f32
                nap $step_sindex = 0..15 // nint(ap(16,n1-sstp,sstp)) // n1
                set nmx 64
                set nonlinear 1
            }
            if {$entsp < 3} {
                set entsp 3
            }
	}
	    # vertical line
	set vl $parent.$var${dim_num}vert_line
	frame $vl -width 2 -relief $relief -bd 1
	grid $vl -sticky ns -row $row -column $col -rowspan 2
	    # entry for nap expression (hidden at start)
	if {$var eq "to"} {
	    trace add variable ${dim_ns}::expr write "::Hdf::need_read $top_ns"
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
	    -from 0 -to $n1 -width $entsp -textvariable $sub_var \
	    -validate key -validatecommand {regexp {^[0-9.]*$} %P} \
	    -borderwidth 1 \
	    -justify right -background white -highlightthickness 1
	pack $sub_spin -side left
	bind $sub_spin <Enter> "focus $sub_spin"
	    # scale (slider) for subscript
	set sub_scale $sub_upper.scale
        #
        # Define the sliders
        # Nonlinear case always associated with step slider
        if {$nonlinear} {
	    scale $sub_scale -showvalue 0 -orient horizontal -from 0 -to $nmx \
            -variable $step_slider \
	    -borderwidth 1 \
	    -highlightthickness 1 -digits [string length $n1] \
            -command "::Hdf::nonlinear_slider $step_sindex $sub_var" 
            trace add variable $sub_var write \
                "::Hdf::move_slider $sub_var $step_sindex $step_slider" 
        } else {
	    scale $sub_scale -showvalue 0 -orient horizontal -from 0 -to $n1 \
            -variable $sub_var \
	    -borderwidth 1 \
	    -highlightthickness 1 -digits [string length $n1] 
        }
	pack $sub_scale -side left -expand 1 -fill x
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
	    label $cv_unit -text $unit -anchor w
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
    
    #
    # adjust_area--
    #
    # Peter J Turner CSIRO Marine November 2004
    #
    # Called when the value of  area_select is changed. The area_select
    # contains dimension names and  CV values. These values are decoded
    # and used to reset the appropriate slider
    # slider values. This allows another proceedure like plot_nao to change the
    # slider values "remotely" based on say a dragged box.

    proc adjust_area {
        top_ns
        args
    } {
        # slider values are of the form from and to
        # set dim_ns "${top_ns}::dim$dim_num"
	global ${top_ns}::filename
	global ${top_ns}::sds_name
	global ${top_ns}::hdf_netcdf
        #
        # Get the dimension names
        # nap_get with dimension flag does not manage dimension names
        # with spaces! Have to read a small part of the file as a work around!
	# set dim_names [hdf_info $top_ns -dimension "$filename" $sds_name]
        #
        ##########################
        # Work around for dimension names
	set shp [hdf_info $top_ns -shape "$filename" $sds_name]
        # Create and index 0,0,.. for each dimension
        # indx values must be a vector
        set not_first 0
        foreach v $shp {
            if {$not_first} {
                append idx ","
            }
            append idx "{0}"
            set not_first 1
        }
        # Create a boxed nao
        nap indx = "$idx"
        nap tnao = [nap_get $hdf_netcdf "$filename" $sds_name $indx]
        set n 0
        foreach v $shp {
            lappend dim_names [$tnao dimension $n]
            incr n
        }
        ###########################
        set value [subst $${top_ns}::area_select]
        set cv [$tnao coordinate]
        unset tnao
        foreach {pname x1 x2} $value {
            set dim_num 0
            set found 0
            foreach name $dim_names {
                if {[string compare $name $pname] == 0} {
                    # x1 and x2 could be coordinates or indices
                    # Decide which on the basis of the data nao
                    if {[lindex $cv $dim_num] == "(NULL)"} {
                        set ${top_ns}::dim${dim_num}::from $x1
                        set ${top_ns}::dim${dim_num}::to $x2
                    } else {
#                        set ${top_ns}::dim${dim_num}::from_cv $x1
#                        set ${top_ns}::dim${dim_num}::to_cv $x2
	                set ${top_ns}::dim${dim_num}::from [[nap "${top_ns}::dim${dim_num}::cv @@ $x1"]]
	                set ${top_ns}::dim${dim_num}::to [[nap "${top_ns}::dim${dim_num}::cv @@ $x2"]]

                    }
                    set found 1
                } 
                incr dim_num
            }
            #
            # If there was no match then let the user know. Probably
            # selected another SDS/Variable
            if {!$found} {
                if {$hdf_netcdf == "hdf"} {
                    tk_messageBox -type ok -icon warning -message \
			"No match for dimension $pname! \nRight SDS selected?"
                } else {
                    tk_messageBox -type ok -icon warning -message \
			"No match for dimension $pname! \nRight Variable selected?"
                }
            }
        } 

    }

    # I have some reservations about doing this in case there is a nasty loop
    # setup.
    # When the entry value is changed move slider is called to change the
    # position of the slider.
    # When the slider moves the entry value is changed .....
    # Might need a flag to stop nonlinear slider doing anything if move_slider
    # was called!
    # Seems to work OK at present so why fight it!

    #
    # nonlinear_slider--
    #
    proc nonlinear_slider {
        slider_index
        varname
        index
    } {
        nap val = slider_index(index)
        set $varname [$val]
    }

    #
    # move_slider--
    #
    # Moves a nonlinear slider
    #
    proc move_slider {
        value
        slider_index
        slider_value
        args
    } {
        nap index = slider_index@@value
#        puts "index = [$index] $value  $slider_index $slider_value" 
        set $slider_value [$index]

    }
}
