# choose_file.tcl --
#
# GUI for user to choose input file
# Use by calling either choose_file or choose_file_gui 
#
# Copyright (c) 2003, CSIRO Australia
#
# Harvey Davies, CSIRO Atmospheric Research
#
# $Id: choose_file.tcl,v 1.6 2004/07/07 08:33:20 dav480 Exp $

namespace eval ChooseFile {
    variable count 0;		# Increment each time choose_file_gui is called 

    # choose_file --
    #
    # Create a new temporary GUI window & return pathname of input file.
    #
    # Usage:
    #   choose_file ?<PARENT>? ?<FILTER>? ?<GEOMETRY>?
    #	    <PARENT>: See create_window (default ".")
    #	    <FILTER>: Initial glob filter (default "*")
    #	    <GEOMETRY>: See create_window (default NW)

    proc choose_file {
	{parent "."}
	{filter "*"}
	{geometry NW}
    } {
	set win [create_window choose_file $parent $geometry]
	set cf $win.cf
	set ns ::ChooseFile::ns${::ChooseFile::count};	# new namespace
	choose_file_gui $cf "destroy $win; set ${ns}::result" \
            "::Hdf::hdf_help $top_ns $top" "destroy $win" $filter
#	pack $cf -expand 1 -fill x
	pack $cf -fill x
	tkwait window $win
	trace remove variable ::ChooseFile::dir    write "::ChooseFile::trace_dir $ns"
	trace remove variable ::ChooseFile::filter write "::ChooseFile::set_tail_values $ns"
	trace remove variable ::ChooseFile::tail   write "::ChooseFile::trace_tail $ns"
	return [set ${ns}::result]
    }

    # choose_file_gui --
    #
    # Create GUI to allow user to choose input file.
    #
    # Usage:
    #   choose_file_gui <pathName> <openCommand> ?<cancelCommand>? ?<filter>?
    #	    <pathName>: Name of new GUI window
    #	    <openCommand>: Start of command executed when user presses "Open" button
    #	    <cancelCommand>: Command executed when user presses "Cancel" button (Default: no button)
    #	    <filter>: Initial glob filter (default "*")

    proc choose_file_gui {
	pathName
	openCommand
        {helpCommand ""}
	{cancelCommand ""}
	{filter "*"}
    } {
	set ns ::ChooseFile::ns${::ChooseFile::count};	# new namespace
	incr ::ChooseFile::count
	namespace eval $ns {
	    variable dir "";		# directory
	    variable filter "";		# glob expression
	    variable result "";		# filename to be returned
	    variable tail "";		# filename within directory
	    variable top "";		# topmost window
	}
	global ${ns}::top
	set e $pathName
        set top $e
	frame $e -bd 2
	set open_command [list ::ChooseFile::open_file $ns $openCommand]
        #
        # Button look parameters
        set rl raised
        set px 1
        set py 0
	#
        # File Entry
	button $e.b_file -text File -relief $rl -padx $px -pady $py \
            -command [list ::ChooseFile::tail_gui $ns $openCommand]
	spinbox $e.e_spin \
            -relief sunken -bd 2 -background white -wrap 1 \
            -textvariable ${ns}::tail
	bind $e.e_spin <Key-Return> $open_command
        button $e.b_open -text Open -relief $rl -padx $px -pady $py \
            -command $open_command
        grid $e.b_file -row 0 -column 0 -sticky news
        grid $e.e_spin -row 0 -column 1 -columnspan 2 -sticky news
        grid $e.b_open -row 0 -column 3 -sticky news
        #
        # Path entry
	button $e.b_path -text Path -relief $rl -padx $px -pady $py \
            -command "::ChooseFile::dir_gui $ns"
	entry $e.e_path \
	    -relief sunken -bd 2 -background white \
	    -textvariable ${ns}::dir 
        grid $e.b_path -row 1 -column 0 -sticky news
        grid $e.e_path -row 1 -column 1 -columnspan 2 -sticky news
	#
        # Filter Entry
	label $e.l_filter -text "Filter"
	entry $e.e_filter \
	    -relief sunken -bd 2 -background white \
	    -textvariable ${ns}::filter
        grid $e.l_filter -row 2 -column 0 -sticky news
        grid $e.e_filter -row 2 -column 1 -sticky new
        #
        # help command
	if {$helpCommand ne ""} {
            button $e.b_help -text Help -relief $rl -padx $px -pady $py \
                -command $helpCommand
            grid $e.b_help -row 2 -column 2 -sticky nw -padx 2 -pady 2
	}

        #
        # Cancel command
	if {$cancelCommand ne ""} {
            button $e.b_cancel -text Cancel -relief $rl \
                -padx $px -pady $py \
                -command $cancelCommand
            grid $e.b_cancel -row 2 -column 3 -sticky nw -padx 2 -pady 2
	}
        #
        # Make the entry widgets expand
        grid columnconfigure $e 0 -weight 0
        grid columnconfigure $e 1 -weight 1
        grid columnconfigure $e 2 -weight 0
	#
	trace add variable ${ns}::dir \
            write "::ChooseFile::trace_dir $ns"
	trace add variable ${ns}::filter \
            write "::ChooseFile::set_tail_values $ns"
	trace add variable ${ns}::tail \
            write "::ChooseFile::trace_tail $ns"
	set ${ns}::dir "[pwd]"
	set ${ns}::filter $filter
	return $top
    }

    # dir_gui --
    #
    # Called by pressing directory Dialog button

    proc dir_gui {
	ns
    } {
	global ${ns}::top
	set path [tk_chooseDirectory -parent $top -mustexist 1]
	if {$path ne ""} {
	    set ${ns}::dir "$path"
	}
    }

    # tail_gui --
    #
    # Called by pressing tail ('File') Dialog button

    proc tail_gui {
	ns
	openCommand
    } {
	global ${ns}::top
	set types [list "Filter [set ${ns}::filter]" {{All Files} *}]
	set path [tk_getOpenFile -parent $top -filetypes $types \
            -initialdir [set ${ns}::dir]]
	if {$path ne ""} {
	    set ${ns}::dir  [rel_filename [file dirname $path]]
	    set ${ns}::tail [rel_filename [file tail    $path]]
	    open_file $ns $openCommand
	}
    }

    # set_tail_values --
    #
    # Set tail spinbox values to names of all ordinary files & links matching filter

    proc set_tail_values {
	ns
	args
    } {
	global ${ns}::top
	global ${ns}::dir
	global ${ns}::filter
	if {[file isdirectory $dir]} {
	    set tails [lsort [glob -nocomplain -tails -types {f l} \
                -directory $dir $filter]]
	    $top.e_spin configure -values $tails
	    set ${ns}::tail [lindex $tails 0]
	}
    }

    # rel_filename --
    #
    # Convert file name to standard relative form

    proc rel_filename {
	name
    } {
	set pwd "[pwd]"
	set name [file normalize $name]
	if {$name eq $pwd} {
	    set name .
	} elseif {[string match "$pwd/*" $name]} {
	    set name [string range $name [string length "$pwd/"] end]
	}
	return $name
    }

    # trace_dir --
    #
    # Called whenever ${ns}::dir changes

    proc trace_dir {
	ns
	args
    } {
	global ${ns}::dir
	global ${ns}::top
	if {[file isdirectory $dir]} {
	    $top.e_path configure -foreground black
	} else {
	    $top.e_path configure -foreground red
	    $top.e_spin configure -foreground red
	}
	set_tail_values $ns
    }

    # trace_tail --
    #
    # Called whenever ${ns}::tail changes

    proc trace_tail {
	ns
	args
    } {
	global ${ns}::top
	set file [file join [set ${ns}::dir] [set ${ns}::tail]]
	if {[file isfile $file]} {
	    $top.e_spin configure -foreground black
	} else {
	    $top.e_spin configure -foreground red
	}
    }

    # open_file --
    #
    # Called by pressing Open button.

    proc open_file {
	ns
	openCommand
    } {
	eval $openCommand [list [rel_filename [file join [set ${ns}::dir] [set ${ns}::tail]]]]
    }

}
