# browse_var.tcl --
#
# A simple example script to generate a GUI interface
# that displays Tcl variables and naos. The user
# selects a list of variable names using a glob
# pattern and can display the value of a variable
# by clicking on the name.
#
# Copyright (c) 1998, CSIRO Australia
# Author: P.J. Turner CSIRO Atmospheric Research August 1998
# $Id: browse_var.tcl,v 1.13 2003/05/20 15:14:13 dav480 Exp $

package require BWidget

# Usage
#   browse_var ?<PARENT>? ?<GEOMETRY>?
#       <PARENT>: widget in which to pack. If "." (default) or "" then toplevel.
#       <GEOMETRY>: Used if defined & <PARENT> is "." or ""
#
# Example
#   browse_var .

# browse_var --

proc browse_var {
    args
} {
    eval Browse_var::main $args
}

namespace eval Browse_var {
    variable namespace "::"
    variable pattern "*" ;# Set the default pattern as everything
    variable picked
    variable show_choice text

    # main --

    proc main {
	{parent .}
	{geometry ""}
    } {
	    # Create a new window called .lv
	destroy .lv
	if {$parent eq ""  ||  $parent eq "."} {
	    toplevel .lv
	    if {$geometry ne ""} {
		wm geometry .lv $geometry 
	    }
	} else {
	    frame .lv -relief raised -borderwidth 4
	    pack .lv -in $parent -side top -padx 2 -pady 2 -fill x
	}

	label .lv.heading -text "Tcl Variable Browser"

	    # frame for pattern, show radiobuttons, menu
	frame .lv.control

	    # Define a frame to place the entry box in.
	    # This contains grid to allow entry widget to expand
	frame .lv.control.pattern
	pack .lv.control.pattern \
	    -expand true -fill x -side top
	label .lv.control.pattern.namespace_l -text "namespace:"
	entry .lv.control.pattern.namespace_e \
	    -relief sunken \
	    -textvariable Browse_var::namespace
	label .lv.control.pattern.pattern_l -text "pattern:"
	entry .lv.control.pattern.pattern_e \
	    -relief sunken \
	    -textvariable Browse_var::pattern
	grid .lv.control.pattern.namespace_l .lv.control.pattern.namespace_e
	grid .lv.control.pattern.namespace_l -sticky e
	grid .lv.control.pattern.namespace_e -sticky w
	grid .lv.control.pattern.pattern_l .lv.control.pattern.pattern_e
	grid .lv.control.pattern.pattern_l -sticky e
	grid .lv.control.pattern.pattern_e -sticky w
	grid columnconfigure .lv.control.pattern 0 -weight 0
	grid columnconfigure .lv.control.pattern 1 -weight 1

	frame .lv.control.option
	label .lv.control.option.l -text "Display NAO as: "
	pack .lv.control.option.l -side left -anchor w
	foreach opt {text image} {
	    radiobutton .lv.control.option.$opt \
		-text $opt \
		-selectcolor orange \
		-variable Browse_var::show_choice \
		-value $opt \
		-anchor w \
		-pady 4 \
		-relief groove
	    pack .lv.control.option.$opt -side left
	}

	pack .lv.control.pattern .lv.control.option  -anchor w -expand true -fill x

	frame .lv.do
	button .lv.do.namespace \
		-text namespace \
		-command "Browse_var::create_namespace_treeview .lv"
	button  .lv.do.list \
	    -text list \
	    -command Browse_var::select
	button  .lv.do.help \
	    -text help \
	    -command Browse_var::lv_help
	button  .lv.do.cancel \
	    -text cancel \
	    -command "destroy .lv"
	pack .lv.do.namespace .lv.do.list .lv.do.help .lv.do.cancel -side left -expand 1 -fill x

    #
    # define a new frame for the variable name list and the
    # variable value.
    #
	pack .lv.heading .lv.do .lv.control -expand true -fill x

    #
    # Key bindings - When we hit return list all the names that
    # match the regular expression.
    #
    # Programming note: the parameters supplied to the
    # proceedure select must be defined at the time
    # the proceedure is initiated when the <CR> is hit.
    # Placing the "command in {}"s stops the $pattern from being evaluated
    # evaluated until the key is hit. Normally you would
    # enclose the ecommand in "" to force evaluation of 
    # $variables.
    #
	bind .lv.control.pattern.pattern_e <Return> Browse_var::select
	bind .lv.control.pattern.namespace_e <Return> Browse_var::select
	focus .lv.control.pattern.pattern_e
    }


    # warn --
    #
    # Warn user of error

    proc warn {
	message
    } {
	message_window $message -label "Error!" -wait 1
    }


    # select --
    #
    # Creates a listbox of all variable names matching the pattern
    #

    proc select {
    } {
	global Browse_var::namespace
	global Browse_var::pattern
	global Browse_var::picked

	set max_height 20;	# max no. lines in listbox
	set max_width 70;	# max no. columns in listbox
	set f .lv.list
	set r $f
	destroy $f
	pack forget $f
	frame $f
	pack $f -expand true -fill x
    #
    # Get a list of the variable names
    # sort it and find the maximum length.
    #
	set vars [lsort -ascii [info vars ::${namespace}::${pattern}]]
	set sdir ""
	foreach var $vars {
	    set value ""
	    if [uplevel [list array exists $var]] {
		set value [uplevel [list array get $var]]
	    } elseif [uplevel [list info exists $var]] {
		set value [uplevel [list set $var]]
	    }
	    if {$value != ""} {
		set line "[list [namespace tail $var]] $value"
		lappend sdir [string range $line 0 [expr $max_width - 1]]
	    }
	}
	set length 2
	foreach i $sdir {
	    if {[set nlength [string length $i]] > $length} {
		set length $nlength
	    }
	} 
    #
    # Now create the list box! attach scroll bars and pack
    # Only do this if $rb.lb doe not exist. If it does
    # exist we only need to clear resize and display new 
    # names.
    #
	set nels [llength $sdir]
	set height [expr $nels > $max_height ? $max_height : 0]
	set min_width 32
	set width [max $min_width $length]
	if {[string compare $r.lb [info commands $r.lb]] != 0} {
	    listbox $r.lb \
		-background white \
		-font {-family Helvetica -size 12} \
		-relief sunken \
		-selectmode single \
		-width $width \
		-height $height \
		-yscrollcommand "$r.scroll set" \
		-borderwidth 4
	    scrollbar $r.scroll \
		-command "$r.lb yview"
	    pack $r.lb -side left
	    pack $r.scroll -side left -fill y
    #
    # We can insert the items into the list
    #
	    eval {$r.lb insert end} $sdir
	    set picked ""
    #
    # Bind events are tricky things because they execute
    # their commands in global scope. Using braces
    # to group a series of commands to be executed when
    # the bind event occurs prevents the values of local
    # variables being expanded.
    #
	    $r.lb configure -selectmode single
	    bind $r.lb <ButtonRelease-1> "Browse_var::get_name $f.lb"
	} else {
	    $r.lb delete 0 end
	    $r.lb configure -width $length
	    $r.lb configure -height $height
	    eval {$r.lb insert end} $sdir
	    set picked ""
	}
    }

    # get_name --
    #
    # Get the value of the named list item and display it

    proc get_name {lb} {
	global Browse_var::namespace
	global Browse_var::picked
	global Browse_var::show_choice
	set i [$lb curselection]
	if {[llength $i] == 1} {
	    regsub { .*$} [$lb get $i] {} picked 
	    if {$namespace == "::"} {
		set picked ::$picked
	    } else {
		set picked ${namespace}::$picked
	    }
	    if [uplevel array exists $picked] {
		message_window [uplevel array get $picked] -label $picked
	    } else {
		set value [uplevel set $picked]
		if [is_nao_id $value] {
		    switch $show_choice {
			text {
			    if [regexp boxed|ragged|character [$value datatype]] {
				set str ""
			    } else {
				set str "Data Range: [[nap "range($value)"]]\n"
			    }
			    set str "$str[uplevel $value all -columns 50 -lines 100]"
			    message_window $str -label $picked
			}
			image {
			    uplevel plot_nao $picked
			}
			default {
			    warn "get_name: show_choice has illegal value $show_choice"
			}
		    }
		} else {
		    message_window $value -label $picked
		}
	    }
	}
    }

    # lv_help --
    #
    # Display help.

    proc lv_help {} {
	set text \
	"The Tcl Variable Browser displays the names and values of tcl variables (including \
	\narrays).\
	\n\
	\nThe menu buttons have the following functions:\
	\n\
	\n    'namespace': Use tree widget to set the namespace.\
	\n    'list': List tcl variables in the namespace matching the glob pattern.\
	\n    'help': Display this 'Help on Tcl Variable Browser'.\
	\n    'cancel': Remove 'Tcl Variable Browser' widget.\
	\n\
	\nThe above 'list' command displays a line for each matching tcl variable. This line \
	\ncontains the variable's name and value provided there is room. Otherwise the line is\
	\ntruncated.\
	\n\
	\nYou can click on a line to display\
	\n - full value of an ordinary tcl variable or array whose line is truncated as above\
	\n - a NAO as either text or graph/image as specified by the radio-button."
	message_window $text -label "Help on Tcl Variable Browser" -width 90
    }


    # create_namespace_treeview --

    proc create_namespace_treeview {
	parent
    } {
	set f $parent.frame
	pack forget $f
	destroy $f
	frame $f
	set t $f.treeview
	Tree $t -height 20 -padx 2
	$t configure -xscrollcommand "$f.xscroll set" -yscrollcommand "$f.yscroll set" 
	scrollbar $f.xscroll -orient horizontal -command "$t xview" 
	scrollbar $f.yscroll -orient vertical -command "$t yview" 
	$t insert end root / -data :: -text :: -open 1 -fill red
	grow_tree $t /
	grid $t $f.yscroll -sticky news
	grid $f.xscroll -sticky news
	grid rowconfigure $f 0 -weight 1
	grid columnconfigure $f 0 -weight 1
	$t bindText <ButtonPress-1> "Browse_var::button_command $t"
	pack $f -fill both -expand true -after .lv.heading
    }


    # button_command --

    proc button_command {
	t
	node
    } {
	global ::Browse_var::namespace
	set old [string map ":: /" $namespace]
	$t itemconfigure $old -fill black
	set namespace [$t itemcget $node -data]
	$t itemconfigure $node -fill red
	Browse_var::select
    }


    # grow_tree --

    proc grow_tree {
	t
	tree_parent
    } {
	set namespace_parent [$t itemcget $tree_parent -data]
	set children [lsort [namespace children $namespace_parent]]
	foreach child $children {
	    set tail [namespace tail $child]
	    set new [string map {:: /} $child]
	    $t insert end $tree_parent $new -data $child -text $tail
	    grow_tree $t $new
	}
    }

}
