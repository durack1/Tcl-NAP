# nap_proc_lib.tcl --
#
# Miscellaneous small procedures related to NAP (but not defining NAP functions)
#
# Copyright (c) 2001, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: nap_proc_lib.tcl,v 1.3 2001/11/15 23:27:14 dav480 Exp $


# compare --
#
# Compare array we got with expected array.
# Assume rank <= 3.
# Return OK if same rank, shape & value (within tolerance).
# Return max difference if > tolerance.
# got = name of array we got
# expect = ID of expected nao
# tol = string giving tolerance

proc compare {got expect tol} {
    if [is_nao_id $got] {
	nap "g = got"
    } else {
	upvar $got g
    }
    nap "e = expect"
    if {[[nap "rank(g) != rank(e)"]]} {
	return "different ranks"
    } elseif {[[nap "rank(g) > 3"]]} {
	return "rank > 3"
    } elseif {[[nap "prod(shape(g) == shape(e)) != 1"]]} {
	return "different shapes"
    } else {
        nap "maxDiff = max(max(max(abs(g-e))))"
	if {[[nap "maxDiff < tol"]]} {
	    return OK
	} else {
	    return [$maxDiff]
	}
    }
}


# is_nao_id --
#
# Is specified string a valid NAO ID?

proc is_nao_id {
    str
} {
    regexp {^::NAP::[0-9]+-[0-9]+$} $str
}


# l0 --
#
# List NAOs with count = 0
# Usage:
#   l0

proc l0 {
    {options id}
} {
    set result ""
    foreach id [list_naos] {
	if {[$id count -keep] < 1} {
	    if {$result != ""} {
		append result "\n"
	    }
	    append result [eval $id $options -keep]
	}
    }
    return $result
}


# list_naos --
#
# List of all NAOs in sequence number order

proc list_naos_compare {nao1 nao2} {expr "[$nao1 sequence -keep] - [$nao2 sequence -keep]"}
proc list_naos {} {
    lsort -command list_naos_compare [info commands {::NAP::*-*}]
}


# print_time --
#
# procedure "print_time" prints specified text, cpu time & wall time since
# previous call. also print number of bytes in naos.  save these times in
# variable named $name in caller's namespace.  if $name not defined (normal
# for 1st call) then nothing is printed.
# if $text has value "" (default) then define $name but do not print.
# if $name has value "" then do nothing (useful to suppress printing).
#
# example
#   print_time save_times  ;# nothing printed - defines variable "save_times"
#     various commands forming section 1
#   print_time save_times "section 1"
#     various commands forming section 2
#   print_time save_times "section 2"

proc print_time {name {text {}}} {
    upvar $name old_times
    set new_cpu [inform seconds]
    set new_wall [clock seconds]
    set fmt "%-20s %7.1f cpu-sec%5.f wall-clock-sec %7.0fk for %4.0f naos"
    if {[info exists old_times]} {
        if {[string length $old_times] == 0} {
            return
        } elseif {[string length $text] > 0} {
            set cpu  [expr $new_cpu  - [lindex $old_times 0]]
            set wall [expr $new_wall - [lindex $old_times 1]]
	    set kb [expr [lindex [nap_info bytes] 0] / 1024.0]
	    set nn [llength [list_naos]]
            puts "[format $fmt $text $cpu $wall $kb $nn]"
        }
    }
    set old_times "$new_cpu $new_wall"
    return
}


# rm_naos0 --
#
# Remove NAOs with count = 0
# Usage:
#   rm_naos0

proc rm_naos0 {
} {
    foreach id [l0] {
	$id set count 0
    }
}


# swap_naos --
#
# Swap NAOs corresponding to two Tcl variables.
#
# Usage:
#   swap_naos <name1> <name2>
#
# Example:
#   nap "a = 1"
#   nap "b = 2"
#   swap_naos a b
# Now a is 2 and b is 1.

proc swap_naos {name1 name2} {
    nap "nao1 = [uplevel set $name1]"
    nap "nao2 = [uplevel set $name2]"
    uplevel nap "$name1 = $nao2"
    uplevel nap "$name2 = $nao1"
    return
}


# Test --
#
# Like standard tcltest "test", but also (optionally) test for NAO mem. leaks.
#
# Usage:
#   Test name description script expectedAnswer leaks constraints
#     where:
#	name, description, script, expectedAnswer & constraints are as for
#		standard ::tcltest::test.
#	leaks is 1 (default) to test for NAO mem. leaks, 0 to not test.

proc Test {name description script expectedAnswer {leaks 1} {constraints ""}} {
    uplevel [list ::tcltest::test $name $description $constraints $script $expectedAnswer]
    set z [l0]
    if {$leaks  &&  $z != ""} {
	puts ""
	puts "NAO memory leak in $name $description"
	puts $z
	rm_naos0
    }
    return
}
