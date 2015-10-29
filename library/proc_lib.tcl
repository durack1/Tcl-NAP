# proc_lib.tcl --
#
# Miscellaneous small procedures
#
# Copyright (c) 1998, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: proc_lib.tcl,v 1.97 2003/06/26 07:56:43 dav480 Exp $


# aeq --
#
# approximately equal
# a: absolute tolerance
# r: relative tolerance

proc aeq {
    x
    y
    {a 1e-9}
    {r 1e-5}
} {
    expr "abs($x-$y) <= [LargerOf $a [expr $r*[LargerOf [expr abs($x)] [expr abs($y)]]]]"
}


# commas --
#
# Usage
#   commas <n>
#     where <n> is expression
#
# Result is string consisting of <n> commas

proc commas args {
    set n [eval expr $args]
    set n [expr "int(0.5 + $n)"]
    string repeat , [expr "$n > 0 ? $n : 0"]
}


# create_window --
#
# Create toplevel window & return its name, which includes specified prefix.
# Geometry defaults to upper-left corner of parent (if any, else +0+0)

namespace eval Create_window {
    variable frame_id 0
}

proc create_window {
    {prefix tmp}
    {parent "."}
    {geometry ""}
    {label ""}
} {
    set parent [string trim $parent]
    set all .$prefix$Create_window::frame_id
    if {$parent != ""  &&  $parent != "."} {
	set all $parent$all
    }
    if {$geometry == ""} {
	if {$parent == ""} {
	    set geometry +0+0
	} else {
	    set geometry +[winfo rootx $parent]+[winfo rooty $parent]
	}
    }
    destroy $all
    toplevel $all
    eval wm geometry $all $geometry
    if {$label != ""} {
	wm title $all $label
    }
    incr Create_window::frame_id
    return $all
}


# date_time_now --
#
# Current date and time for specified time zone
# Default format corresponds to that specified by Australian/NZ standard

# Example for Australian Central Standard Time (9.5 hours ahead of UTC)
#   date_time_now 9.5

proc date_time_now {
    {hours_ahead ""}
    {format %Y-%m-%dT%H:%M:%S}
} {
    default hours_ahead [local_hours_ahead_UTC]
    if {$hours_ahead == 0} {
	set tz Z
    } else {
	if {$hours_ahead < 0} {
	    set sign -
	} else {
	    set sign +
	}
	set hours [expr abs($hours_ahead)]
	set whole_hours [expr int($hours)]
	set extra_minutes [expr int(60 * ($hours - $whole_hours))]
	set tz [format %s%02d $sign $whole_hours]
	if {$extra_minutes > 0} {
	    set tz [format %s:%02d $tz $extra_minutes]
	}
    }
    set seconds [expr int(3600 * $hours_ahead + [clock seconds])]
    clock format $seconds -format $format$tz -gmt 1
}


# default --
#
# If specified variable is undefined or "" then set it to specified value

# Usage
# default <VAR_NAME> <DEFAULT_VALUE>

proc default {name value} {
    upvar $name var
    if {![info exists var]  ||  $var == ""} {
	set var $value
    }
    return
}


# get_arg --
#
# Get value of command-line argument from global variable 'argv' or some other
# list such as the standard variable 'args'.

# It is mainly used with batch scripts run from tclsh as follows:
# tclsh <SCRIPT_FILENAME> <ARG0> <ARG1> <ARG2> ...

# But it is also possible to explicitly specify list, as in following:
#	get_arg 1 -90 "n14_15890.asda -20 -21 119 120"

# Usage
# get_arg ?<I>? ?<DEFAULT>? ?<LIST>?
#    where
#	<I> is argument number (0, 1, 2, ...) (default: 0) 
#	<DEFAULT> is value returned if no such argument (default: "")
#	<LIST> is argument list (default: argv)

proc get_arg {
    {i 0}
    {default ""}
    {list ""}
} {
    global argv
    if {$list == ""} {
	set list $argv
    }
    if {$i < [llength $list]} {
	return [lindex $list $i]
    } else {
	return $default
    }
}


# get_entry --
#
# Get text entry from user (single line only).
# Use window if tk exists.
# Return text.
#
# Usage:
#   get_entry <LABEL> ?options?
#     <LABEL>: text to be displayed on left of entry widget
# Options are:
#     -geometry <string>: If specified use to create new toplevel window
#     -parent <string>: parent window. "" for toplevel. (Default: ".")
#     -text <string>: initial text in entry widget (Default: "")
#     -width <number>: width of entry field (Default: 20)
#
# Example:
#   get_entry "filename" -g +0+0

namespace eval Get_entry {
    variable complete
    variable reply
}

proc get_entry {
    label
    args
} {
    set Get_entry::reply ""
    set geometry ""
    set parent "."
    set width 20
    set background white
    set font {-family Helvetica -size 12}
    set i [process_options {
            {-geometry {set geometry $option_value}}
            {-parent {set parent $option_value}}
            {-text {set Get_entry::reply $option_value}}
            {-width {set width $option_value}}
        } $args]
    if {$i != [llength $args]} {
        error "Illegal option"
    }
    if [info exists ::tk_version] {
	set save_focus [focus]
	set all [create_window get_entry $parent $geometry]
	set Get_entry::complete 0
	frame $all.input
	label $all.input.label -text $label
	entry $all.input.entry -width $width -textvariable Get_entry::reply \
	    -background $background \
	    -font $font
	$all.input.entry icursor end
	frame $all.buttons
	button $all.buttons.clear -text clear -command {set Get_entry::reply ""}
	button $all.buttons.accept -text accept \
		-command "set Get_entry::complete 1"
	pack $all.buttons.clear $all.buttons.accept \
		-side left -padx 1m -pady 1m
	pack $all.input $all.buttons
	focus $all.input.entry
	bind $all <Visibility> "raise $all"
	bind $all.input.entry <Return> "set Get_entry::complete 1"
	pack $all.input.label $all.input.entry -side left
	update idletasks
	grab set $all
	tkwait variable Get_entry::complete
	grab release $all
	if {[winfo exists $save_focus]} {
	    focus $save_focus
	}
	destroy $all
	update idletasks
    } else {
	puts -nonewline "$label: "
	flush stdout
	set Get_entry::reply [gets stdin]
    }
    return $Get_entry::reply
}


# gets_file --
#
# Result is text contents of file

proc gets_file file_name {
    if [catch {set f [open $file_name r]} message] {
        error $message
    }
    set in [read $f]
    close $f
    return $in
}


# h --
#
# alias for "history"

proc h args {
    eval history $args
}


# handle_error --
#
# Use window to display error message with trace-back

proc handle_error {
    message
} {
    append message "\n"
    set n [info level]
    for {set i 1} {$i < $n} {incr i} {
	append message "\nCalled by: [info level -$i]"
    }
    message_window $message -label "Error!" -wait 1
}


# lappend_unique --
#
# Similar to standard tcl list append command 'lappend', except that do
# nothing if value is already in list

proc lappend_unique {varName args} {
    upvar $varName v
    if {![info exists v]} {
	set v ""
    }
    foreach value $args {
	if {[lsearch -exact $v $value] < 0} {
	    lappend v $value
	}
    }
}


# LargerOf --
#
# Maximum of x and y

proc LargerOf {
    x
    y
} {
    expr $x > $y ? $x : $y
}


# lazy --
#
# Procedure "lazy" does nothing!

proc lazy args {
}


# list_vars --
#
# Sorted list of variables matching specified regular expression
# Note that regular expression argument (re) is changed to ^$re$
# This has same functionality as old command "inform vars"

proc list_vars {
    {re ""}
} {
    set re ^$re$
    set result ""
    foreach var [uplevel info vars] {
	if {[regexp -- $re $var]} {
	    append result " " $var
	}
    }
    return [lsort $result]
}


# list_remove_nulls --
#
# Remove null lists from a list of lists
#
# P.J. Turner CSIRO Atmospheric Research 2000
#
proc list_remove_nulls { list } {
    set out ""
    foreach el $list {
	if {[llength $el] > 0} {
	    lappend out $el
	}   
    }
    return $out
}


# list_subtract --
#
# Remove elements in list B from list A.
#
# P.J. Turner CSIRO Atmospheric Research 2000
#
proc list_subtract {listA listB} {
    set diffAB ""
    foreach elA $listA {
        set nomatch 1
        foreach elB $listB {
            if {[string compare $elA $elB] == 0} {
                set nomatch 0
                break
            }
        }
        if {$nomatch} {
            lappend diffAB $elA
        }
    }
    return $diffAB
}


# list_unique --
#
# Produce a list of unique elements
#
# P.J. Turner CSIRO Atmospheric Research 2000
#
proc list_unique {List} {
    set sorted_list [lsort -ascii $List]
    set prev [lindex $sorted_list 0]
    set newlist $prev
    foreach new $sorted_list {
       if {[string compare $prev $new] != 0} {
           lappend newlist $new
           set prev $new
       } 
 
    }   
    return $newlist
}


# local_hours_ahead_UTC --
#
# Determine how many hours local time zone is ahead of UTC
# Negative result corresponds to time zone behind UTC
#
# Usage:
#   local_hours_ahead_UTC

proc local_hours_ahead_UTC {} {
    set seconds [clock seconds]
    set iso_utc   [clock format $seconds -format {%Y-%m-%dT%H:%M} -gmt 1]
    set iso_local [clock format $seconds -format {%Y-%m-%dT%H:%M} -gmt 0]
    set mjdn_utc   [convert_date $iso_utc]
    set mjdn_local [convert_date $iso_local]
    set result [format {%g} [expr "24.0 * ($mjdn_local - $mjdn_utc)"]]
    return $result
}


# match_prefix --
#
# Attempt to match specified prefix with exactly one element of list of words.
# Begin by searching for exact match.  If not found then search for word
# begining with prefix.
#
# Usage:
#   match_prefix <LIST> <PREFIX>
#
# If exactly one match then return index of matching entry in <LIST>
# If no matches return -1
# If multiple matches return -nmatches

proc match_prefix {list prefix} {
    set result [lsearch -exact $list $prefix]
    if {$result < 0} {
	set nmatches 0
	for {set i 0} {$i < [llength $list]} {incr i} {
	    if {[string first $prefix [lindex $list $i]] == 0} {
		incr nmatches
		set result $i
	    }
	}
	if {$nmatches > 1} {
	    set result -$nmatches
	}
    }
    return $result
}


# max --
# maximum of arguments which can be expr expressions
# If no args then result is ""

proc max args {
    set n [llength $args]
    if {$n == 0} {
	set result ""
    } else {
	set result [expr [lindex $args 0]]
	for {set i 1} {$i < $n} {incr i} {
	    set e [expr [lindex $args $i]]
	    if {$e > $result} {
		set result $e
	    }
	}
    }
    return $result
}


# message_window --
#
# Display message in window.
# Use vertical scrollbar if > 40 lines.
# Use horizontal scrollbar if > 80 columns.
#
# Usage:
#   message_window <TEXT> ?options?
#     <TEXT>: text to be displayed
# Options are:
#     -geometry <string>: If specified use to create new toplevel window
#     -height <int>: max no. lines in window (default: 50)
#     -label <string>: title for window manager (default: none)
#     -parent <string>: parent window (Default: ".")
#     -title <string>: 1st line of text within window (default: none)
#     -wait <0 or 1>: If 1 then do not return until user destroys window
#     -width  <int>: max no. columns in window (default: 80)
#
# If not toplevel but -label specified then prepend this label to title

proc message_window {
    text
    args
} {
    set geometry ""
    set max_height 50
    set label ""
    set parent "."
    set title ""
    set max_width 80
    set wait 0
    set i [process_options {
            {-geometry {set geometry $option_value}}
            {-height {set max_height $option_value}}
            {-label {set label $option_value}}
            {-parent {set parent $option_value}}
            {-title {set title $option_value}}
            {-wait {set wait $option_value}}
            {-width {set max_width $option_value}}
        } $args]
    if {$i != [llength $args]} {
        error "illegal option"
    }
    set min_nlines 2
    set min_ncols 20
    set nlines [text_height $text]
    if {$nlines < $min_nlines} {
	set nlines $min_nlines
    }
    set ncols [text_width $text]
    if {$ncols < $min_ncols} {
	set ncols $min_ncols
    }
    set f [create_window message $parent $geometry $label]
    button $f.cancel -text cancel -command "destroy $f"
    pack $f.cancel
    if {$title != ""} {
	label $f.title \
	    -text $title \
	    -font {-family courier -size 15 -weight bold} \
	    -relief groove
	pack $f.title -fill x
    }
    set background white
    set font {-family courier -size 12}
    frame $f.msg
    if {$nlines <= $max_height  &&  $ncols <= $max_width} {
	text $f.msg.text \
	    -background $background \
	    -font $font \
	    -height $nlines \
	    -width $ncols \
	    -wrap none \
	    -relief flat
	$f.msg.text insert end $text
	pack $f.msg.text -side left -fill both -expand true
    } elseif {$nlines <= $max_height  &&  $ncols > $max_width} {
	text $f.msg.text \
	    -background $background \
	    -font $font \
	    -height $nlines \
	    -width $max_width \
	    -wrap none \
	    -xscrollcommand "$f.msg.sx set" \
	    -relief flat
	$f.msg.text insert end $text
	scrollbar $f.msg.sx \
	    -orient horizontal \
	    -command "$f.msg.text xview"
	pack $f.msg.sx -side bottom -fill x
	pack $f.msg.text -side left -fill both -expand true
    } elseif {$nlines > $max_height  &&  $ncols <= $max_width} {
	text $f.msg.text \
	    -background $background \
	    -font $font \
	    -height $max_height \
	    -width $ncols \
	    -wrap none \
	    -yscrollcommand "$f.msg.sy set" \
	    -relief flat
	$f.msg.text insert end $text
	scrollbar $f.msg.sy \
	    -orient vert \
	    -command "$f.msg.text yview"
	pack $f.msg.sy -side right -fill y
	pack $f.msg.text -side left -fill both -expand true
    } else {
	text $f.msg.text \
	    -background $background \
	    -font $font \
	    -height $max_height \
	    -width $max_width \
	    -wrap none \
	    -xscrollcommand "$f.msg.sx set" \
	    -yscrollcommand "$f.msg.sy set" \
	    -relief flat
	$f.msg.text insert end $text
	scrollbar $f.msg.sx \
	    -orient horizontal \
	    -command "$f.msg.text xview"
	scrollbar $f.msg.sy \
	    -orient vert \
	    -command "$f.msg.text yview"
	pack $f.msg.sx -side bottom -fill x
	pack $f.msg.sy -side right -fill y
	pack $f.msg.text -side left -fill both -expand true
    }
    pack $f.msg -fill x
    if {$wait} {
	update idletasks
	grab set $f
	tkwait window $f
    }
}


# min --
# minimum of arguments which can be expr expressions
# if no args then result is ""

proc min args {
    set n [llength $args]
    if {$n == 0} {
	set result ""
    } else {
	set result [expr [lindex $args 0]]
	for {set i 1} {$i < $n} {incr i} {
	    set e [expr [lindex $args $i]]
	    if {$e < $result} {
		set result $e
	    }
	}
    }
    return $result
}


# open_input_file --
#
# usage:
#   open_input_file ?<filename>? ?<extensions>?
#
# example:
#   open_input_file "" ".hdf .nc"
#
# if filename specified then return same value provided it is readable.
# if filename not specified then return filename obtained using tk_getOpenFile.

proc open_input_file {
    {filename ""}
    {extensions ""}
} {
    if {$filename == ""} {
        if {[info commands tk_getOpenFile] == "tk_getOpenFile"} {
	    if {$extensions == ""} {
		set filename [tk_getOpenFile -initialdir [pwd]]
	    } else {
		set types "{{$extensions} {$extensions}}"
		set filename [tk_getOpenFile -initialdir [pwd] -filetypes $types]
	    }
        } else {
            return -code error "open_input_file: filename is ''"
        }
    }
    if {$filename == ""} {
	if {![file readable $filename]} {
	    handle_error "open_input_file: cannot open file $filename for input"
	}
    }
    return $filename
}

# paste --
#
# Join text horizontally
#
# usage:
#   paste string0 string1 string2 ...
#
# example:
#   paste "cat\nhorse\ndog" " Bill\n Jan\n Mary"
# which produces
# cat   Bill
# horse Jan
# dog   Mary
# 

proc paste {
    args
} {
    set nargs [llength $args]
    set nl 0
    for {set j 0} {$j < $nargs} {incr j} {
	set arg [lindex $args $j]
	set a($j) [split $arg "\n"]
	set tmp [llength $a($j)]
	set nl [expr "$tmp > $nl ? $tmp : $nl"]
	set nc($j) 0
	foreach el $a($j) {
	    set tmp [string length $el]
	    set nc($j) [expr "$tmp > $nc($j) ? $tmp : $nc($j)"]
	}
    }
    set result ""
    for {set i 0} {$i < $nl} {incr i} {
	for {set j 0} {$j < $nargs} {incr j} {
	    set arg [lindex $args $j]
	    set el [lindex $a($j) $i]
	    set nspaces [expr "$nc($j) - [string length $el]"]
	    append result $el [string repeat " " $nspaces]
	}
	if {$i < $nl - 1} {
	    append result "\n"
	}
    }
    return $result
}


# plotz --
# 
# Print z values at positions (x,y)
# x, y, z are lists with same number of elements

proc plotz {
    x
    y
    z
    args
} {
    set geometry ""
    set pad_right 80
    set parent "."
    set title ""
    set i [process_options {
	    {-geometry {set geometry $option_value}}
	    {-pad_right {set pad_right $option_value}}
	    {-parent {set parent $option_value}}
	    {-title {set title $option_value}}
	} $args]
    package require BLT
    set all [create_window plotz $parent $geometry]
    set graph $all.plotz
    blt::graph $graph -title $title -plotpadx "10 $pad_right" -plotpady "10 10"
    $graph element create xy -xdata $x -ydata $y -linewidth 0 -label "" -symbol splus
    foreach xx $x yy $y zz $z {
	$graph marker create text -coords "$xx $yy" -text $zz -anchor w -xoffset 4
    }
    pack $graph
}


# process_options --
#
# process an argument list which may include flags, value options and "--".
# return index of first argument which is not flag or option.
# if no such argument then return total number of arguments.
# keywords may be abbreviated to a unique prefix.
# the special keyword "--help" causes <options> to be written to stdout.
#
# usage
# process_options <options> <arg_list>
# where
#   <options> is list of lists, each of which contains keyword & command.
#	the special variable '$option_value' can be used in commands.  it has
#	the value of the argument following the keyword.  there is a trace on
#	option_value which causes the argument index (i) to increment every
#	time option_value is read.
#   <arg_list> is list of all arguments including flags & value options.
#
# example
# set args {-ver -in a.txt "non-option argument"}
# set i [process_options {
#		{-verbose {set verbose 1}}
#		{-input   {set input_filename $option_value}}
#	      } $args]
# set rest [lindex $args $i]
#
# this sets the following variables:
#
# name		 value
#
# verbose	 "1"
# input_filename "a.txt"
# rest		 "non-option argument"

proc process_options {
    {options ""}
    {arg_list ""}
} {
    proc process_option_value_trace {name element op} {uplevel incr i}
    trace variable option_value r process_option_value_trace
    set n_options [llength $options]
    set name_list --help
    for {set i 0} {$i < $n_options} {incr i} {
	lappend name_list [lindex [lindex $options $i] 0]
    }
    set n_args [llength $arg_list]
    for {set i 0} {$i < $n_args} {incr i} {
	set arg [lindex $arg_list $i]
	if {$arg == "--"} {
	    return [incr i]
	} else {
	    set j [match_prefix $name_list $arg]
	    if {$j == 0} {
		puts $options
	    } elseif {$j > 0} {
		set option_value [lindex $arg_list [expr $i + 1]]
		uplevel [eval list [lindex [lindex $options [expr "$j - 1"]] 1]]
	    } elseif {$j == -1} {
		return $i
	    } else {
		return -code error "process_options: ambiguous option"
	    }
	}
    }
    return $i
}


# prompt --
#
# Display prompt.  Useful in tk scripts to indicate end of output.

proc prompt {} {
    if {[info procs tcl_prompt1] == ""} {
	puts -nonewline "% "
	flush stdout
    } else {
	tcl_prompt1
    }
    return
}


# put --
#
# procedure "put" does puts of arguments separated by spaces.
# if global variable log_files defined then write to these files (default:
# stdout)
#
# if first arg starts with "-n" then treat as option -nonewline.
# e.g. put -nonewline hello world

proc put args {
    global log_files
    if {[info exists log_files]} {
	set files $log_files
    } else {
	set files stdout
    }
    if [regexp {^-n} [lindex $args 0]] {
	set str [join [lreplace $args 0 0]]
	foreach file $files {
	    puts -nonewline $file $str
	    flush $file
	}
    } else {
	set str [join $args]
	foreach file $files {
	    puts $file $str
	    flush $file
	}
    }
}


# puts_file --
#
# Write text to file

proc puts_file {
    file_name
    text
} {
    if [catch {set f [open $file_name w]} message] {
        error $message
    }
    puts $f $text
    close $f
}


# r --
#
# Redo specified command/s
#
# Usage:
#   r;			# Repeat previous command (-1)
#   r N;		# Repeat command number N
#   r ?FROM? ?TO?;	# Repeat all commands from FROM to TO

proc r {
    {from -1}
    {to ""}
} {
    if {"$to" eq ""} {
	set to $from
    }
    for {set i $from} {$i <= $to} {incr i} {
	history redo $i
    }
}


# reg_expr_sub --
#
# Regular expression substitution.
# Like standard tcl 'regsub' except return new string rather than storing in
# a variable.

proc reg_expr_sub args {
    eval regsub $args var
    return $var
}


# src --
#
# Similar to standard "source".
# However additional arguments are allowed & these define argv and argc.
# Also argv0 is set to filename.

proc src {filename args} {
    global argv argv0 argc
    set argv0 $filename
    set argv $args
    set argc [llength $argv]
    uplevel source $filename
}


# text_height --
#
# Number of lines in string

proc text_height text {
    llength [split $text \n]
}


# text_width --
#
# Maximum number of characters in any line in string

proc text_width text {
    set max_line_length 0
    foreach line [split $text \n] {
        set line_length [string length $line]
        if {$line_length > $max_line_length} {
            set max_line_length $line_length
        }
    }
    return $max_line_length
}


# unset_re --
#
# Similar to standard tcl list command 'unset', except that args are
# regular expressions. Note that this means that it is not an error to
# specify a non-existent variable - this is simply an regular expression which
# does not match any variable.

proc unset_re {args} {
    foreach var [uplevel info vars] {
	foreach re $args {
	    if {[regexp -- ^$re$ $var]} {
		uplevel unset $var
		break
	    }
	}
    }
    return
}

# yes_no --
#
# Display question and get answer of yes or no.
# Use window if tk exists.
# Return 1 for yes, 0 for no.
#
# Usage:
#   yes_no <TEXT> ?options?
#     <TEXT>: text to be displayed
# Options are:
#     -geometry <string>: If specified use to create new toplevel window 
#     -parent <string>: parent window (Default: "" i.e. main window)
#
# Example:
#   yes_no "File abc.txt already exists!\nDelete it?" -g +0+0

namespace eval Yes_no {
    variable reply
}

proc yes_no {
    text
    args
} {
    set geometry ""
    set parent ""
    set i [process_options {
            {-geometry {set geometry $option_value}}
            {-parent {set parent $option_value}}
        } $args]
    if {$i != [llength $args]} {
        error "Illegal option"
    }
    if [info exists ::tk_version] {
	if {$geometry == ""} {
	    set all $parent.yes_no
	    frame $all -relief ridge -borderwidth 4
	    pack $all
	} else {
	    set all .yes_no
	    destroy $all
	    toplevel $all
	    wm geometry $all $geometry
	}
	label $all.label -text $text -justify left
	button $all.yes -text Yes -command {set Yes_no::reply 1}
	button $all.no  -text No  -command {set Yes_no::reply 0}
	frame $all.reply
	pack $all.label $all.reply -side left
	pack $all.yes $all.no -side left -expand 1
	grab set $all
	tkwait variable Yes_no::reply
	destroy $all
	update idletasks
    } else {
	puts -nonewline "$text (y/n) "
	flush stdout
	switch -regexp [gets stdin] {
	    {^[^a-zA-Z]*[yY]} {
		set Yes_no::reply 1
	    }
	    {^[^a-zA-Z]*[nN]} {
		set Yes_no::reply 0
	    }
	    default {
		puts "Illegal reply! Press letter 'y' or 'n'."
		set Yes_no::reply [yes_no $text]
	    }
	}
    }
    return $Yes_no::reply
}
