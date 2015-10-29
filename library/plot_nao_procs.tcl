# plot_nao_procs.tcl --
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: plot_nao_procs.tcl,v 1.39 2002/08/07 08:19:28 dav480 Exp $
#
# Produce xy-graph, barchart (histogram) or z-plot (image).
# Uses BLT graph or barchart command. A z-plot is produced using the graph image marker facility.
#
# Usage
#   See variable help_usage below

namespace eval Plot_nao {

	# Following variables do not need namespace for each graph window
    variable frame_id 0;	# Number of previous graphs created
    variable help_usage \
	    "Produce xy-graph, barchart (histogram) or z-plot (image).\
	    \n\
	    \nUses BLT graph or barchart command. A z-plot is produced using the graph\
	    \nimage marker facility.\
	    \n\
	    \nUsage\
	    \n  plot_nao <NAP expression> ?options?\
	    \nOptions are:\
	    \n  -barwidth <float>: (bar chart only) width of bars in x-coordinate units.\
	    \n     (Default: 1.0)\
	    \n  -buttonCommand <script>: executed when button pressed with z-plots (Default:\
	    \n     \"lappend Plot_nao::\${window_id}::save \[set Plot_nao::\${window_id}::xyz]\")\
	    \n  -colors <list>: Colors of graph elements (lines). (Default: black red\
	    \n     green blue yellow orange purple grey aquamarine beige)\
	    \n  -configure <script>: Prefix graph-name to each line & execute after graph created\
	    \n  -filename <string>: Name of output PostScript file.\
	    \n  -fill <0 or 1>: 1 = Scale PostScript to fill page. (Default: 0)\
	    \n  -gap_height <int>: height (pixels) of horizontal white gaps (Default: 20)\
	    \n  -gap_width  <int>: width  (pixels) of  vertical  white gaps (Default: 20)\
	    \n  -geometry <string>: If specified then use to create new toplevel window.\
	    \n  -height <int>: Desired height (screen units)\
	    \n     Type xy/bar: Height of whole window (Default: automatic)\
	    \n     Type z: Image height (can be \"min max\") (Default: NAO dim if within limits)\
	    \n  -help: Display this help page\
	    \n  -key <int>: width (pixels) of image-key. No key if 0 or blank. (Default: 30)\
	    \n  -labels <list>: Labels of graph elements (lines). (Default: Use element\
	    \n     names i.e. y0, y1, y2, ...)\
	    \n  -menu <0 or 1>: 0 = Start with menu bar at top hidden. (Default: 1)\
	    \n  -orientation <P, L or A>: P = portrait, L = landscape, A = automatic (Default: A)\
	    \n  -overlay <C, L, S, N or \"E <nap expression>\">: Define overlay.\
	    \n     C = coast, L = land, S = sea, N = none, E = expr (Default: N)\
	    \n  -ovpal <NAP expression>: Overlay palette in same form as main palette\
	    \n      (Default: black white red green blue)\
	    \n  -palette <NAP expression>: Main palette defining color map for 2D image. This is\
	    \n      matrix with 3 or 4 columns & up to 256 rows.  If there are 4 columns then the\
	    \n      first gives color indices in range 0 to 255.  Values can be whole numbers in\
	    \n      range 0 to 255 or fractional values from 0.0 to 1.0.\
	    \n      \"\" = black-to-white.  (Default: blue-to-red)\
	    \n  -paperheight <distance>: E.g. '11i' =  11 inch (Default: '297m' = 297 mm (A4))\
	    \n  -paperwidth <distance>: E.g. '8.5i' = 8.5 inch (Default: '210m' = 210 mm (A4))\
	    \n  -parent <string>: parent window (Default: \"\" i.e. create toplevel window)\
	    \n  -print <0 or 1>: 1 = automatic printing (for batch processing) (Default: 0)\
	    \n  -printer <string>: name (Default: env(PRINTER) if defined, else any printer)\
	    \n  -range <NAP expression>: defines scaling (Default: auto scaling)\
	    \n  -rank <1, 2 or 3>: rank of sub-arrays to be displayed (Default: 3 <<< rank(data))\
	    \n  -scaling <0 or 1>: 0 = Start with scaling widget hidden. (Default: 1)\
	    \n  -symbols <list>: One for each element. Draw at points. Can be plus, square,\
	    \n     circle, cross, splus, scross, triangle (Default: \"\" i.e. none)\
	    \n  -title <string>: title (Default: NAO label (if any) else <NAP expression>)\
	    \n  -type <string> plot-type (\"bar\", \"xy\" or \"z\")\
	    \n     If rank is 1 then default type is \"xy\".\
	    \n     If rank is 2 and n_rows <= 8 then default type is \"xy\".\
	    \n     If rank is 2 and n_rows  > 8 then default type is \"z\".\
	    \n     If rank is 3 then type is \"z\" regardless of this option.\
	    \n  -width <int>: Desired width (screen units)\
	    \n     Type xy/bar: Width of whole window (Default: automatic)\
	    \n     Type z: Image width (can be \"min max\") (Default: NAO dim if within limits)\
	    \n  -xflip <0, 1>: Flip left-right?  0 = no, 1 = yes.  (Default: 0)\
	    \n  -xlabel <string>: x-axis label (Default: name of last dimension)\
	    \n  -yflip <0, 1, ascending or geog>: Flip upside down?  0 = no, 1 = yes,\
	    \n      ascending = \"if y ascending\", geog = \"if ascending & (y_dim_name = latitude\
	    \n      or y_unit = degrees_north (or equivalent))\" (Default: geog)\
	    \n  -ylabel <string>: y-axis label (Default: name of 2nd-last dimension)\
	    \n\
	    \nThe height and width used are limited by the screen dimensions\
	    \n\
	    \nExamples\
	    \n  plot_nao \"reshape(0 .. 199, {200 200})\" -geometry +0+0\
	    \n  nap \"sales = {{2 5 1}{1 3 8}}\"\
	    \n  nap \"month = 3 .. 5\"\
	    \n  \$sales set coord \"\" month\
	    \n  plot_nao sales -colors \"blue red\" -symbols \"plus cross\" -type xy\
	    \n  \$sales set label \"Car sales\"\
	    \n  set windowID \[plot_nao sales -labels \"Joe Mary\" -type bar]\
	    \n  set pathName \$windowID.graph\
	    \n  \$pathName element configure Joe -foreground blue"
    variable overlay_nao "";	# overlay (e.g. coastline)
    variable overlay_palette;	# NAO defining color mapping for overlay (e.g. coastline)
    variable x "";		# Current x coord under crosshairs
    variable y "";		# Current y coord under crosshairs
    variable z "";		# Current z values under crosshairs
    variable xyz "";		# "$x $y $z" (for user convenience)

    proc plot_nao {
	{nao_expr ""}
	args
    } {
	if {![info exists ::tk_version]} {
	    error "No tk! You should be running wish not tclsh!"
	}
	if [catch "uplevel 2 nap \"$nao_expr\"" nao] {
	    if {$nao_expr == ""  ||  [regexp -nocase {^-h} $nao_expr]} {
		puts $::Plot_nao::help_usage
	    } else {
		handle_error $nao
	    }
	    return
	}
	::Print_gui::init
	nap "nao = pad(nao)"
	nap "shape_nao = shape(nao)"
	if [[nap "rank(nao) == 3  &&  shape_nao(0) == 1"]] {
	    nap "nao = nao(0,,)"
	    nap "shape_nao = shape(nao)"
	}
	foreach cv [$nao coord] {
	    if {![string equal $cv (NULL)]} {
		if {[string equal [$cv step] +-]} {
		    handle_error "Illegal coordinate variable"
		    return
		}
	    }
	}
	set window_id "win$Plot_nao::frame_id"
	    # Following variables exist in namespace for each graph window
	namespace eval ${window_id} {
	    variable call_level "#[expr [info level]-3]"; # stack level from which plot_nao called
	    variable gap_height 20;	# height (pixels) of horizontal white space between tiles
	    variable gap_width  20;	# width (pixels) of vertical white space
	    variable histograms "";	# List of histogram IDs (so can destroy at end)
	    variable image_nao "";	# Image NAO after any inversion
	    variable key_width 30;	# width (pixels) of image key
	    variable magnification "";	# magnification factor (relative to original NAO)
	    variable new_height -1;	# current image height
	    variable new_width -1;	# current image width
	    variable orientation "A";	# P = portrait, L = landscape, A = automatic
	    variable main_palette "";	# NAO defining color mapping for 2D images
	    variable print_command "";	# 
	    variable save "";		# Used to save crosshair data
	    variable save_nao_ids "";	# List of nao ids to be saved until end.
	    variable scalingFrom;	# Used to scale z plots (array)
	    variable scalingFromIsNext;	# 0: scalingTo next, 1: scalingFrom next (array)
	    variable scalingFromTitle;	# Histogram title when scalingFromIsNext == 1
	    variable scalingTo;		# Used to scale z plots (array)
	    variable scalingToTitle;	# Histogram title when scalingFromIsNext == 0
	    for {set layer 0} {$layer < 3} {incr layer} {
		set scalingFrom($layer) ""
		set scalingFromIsNext($layer) 1
		set scalingTo($layer) ""
	    }
	    variable want_menu_bar 1;	# Display menu bar at top?
	    variable want_scaling_widget 1;	# Display scaling widget?
	    variable xflip 0;		# 1 = flip image left-right
	    variable xlabel "";
	    variable yflip 0;		# 1 = flip image upside down
	    variable ylabel "";
		# set default overlay_palette  to {black white red green blue}
	    nap "overlay_palette = f32{{3#0}{3#1}{1 0 0}{0 1 0}{0 0 1}}";
	}
	    # set default main_palette to "blue to red"
	Plot_nao::palette_interpolate main_palette $window_id 240 0
	set auto_print 0;		# automatic printing? Useful for batch processing
	set barwidth 1.0
	set buttonCommand "lappend Plot_nao::$window_id\::save \$Plot_nao::xyz"
	set colors "black red green blue yellow orange purple grey aquamarine beige"
	set configure ""
	set geometry ""
	set height "";			# height (in pixels) of image (can be "min max" for image)
	set labels ""
	set ncols ""
	set overlay_option none
	set parent ""
	set range_nao ""
	set rank_nao 3
	set symbols ""
	set type ""
	set want_yflip geog; # Reverse row dimension? 0 = no, 1 = yes, ascending = "if y ascending",
			    # geog = "if ascending & (dimname = latitude or unit = degrees_north")
	set width "";			# width (in pixels) of image (can be "min max" for image)
	set dim_names [$nao dim]
	set sub_title [[nap "coordinate_variable(nao, -3)"] value]
	set title [$nao label]
	if {$title == ""} {
	    set title "$nao_expr"
	}
	if {![string equal [$nao unit] (NULL)]} {
	    set title "$title ([$nao unit])"
	}
	if {[$nao nels] == 0} {
	    handle_error "Data array is empty!"
	    return
	}
	proc set_in_namespace {var_name value} "set Plot_nao::${window_id}::\$var_name \$value"
	proc palette_option {name expr} "Plot_nao::set_palette \$name $window_id \$expr"
	set str [lindex $dim_names end]
	if {$str != "(NULL)"} {
	    set_in_namespace xlabel $str
	}
	set str [lindex $dim_names end-1]
	if {$str != "(NULL)"} {
	    set_in_namespace ylabel $str
	}
	unset str
	set i [process_options {
		{-barwidth {set barwidth $option_value}}
		{-buttonCommand {set buttonCommand $option_value}}
		{-colors {set colors $option_value}}
		{-columns	{set ncols $option_value}}
		{-configure {set configure $option_value}}
		{-filename {set ::Print_gui::filename $option_value}}
		{-fill {set ::Print_gui::maxpect $option_value}}
		{-gap_height {set_in_namespace gap_height $option_value}}
		{-gap_width  {set_in_namespace gap_width  $option_value}}
		{-geometry {set geometry $option_value}}
		{-height {set height $option_value}}
		{-help {puts $::Plot_nao::help_usage}}
		{-key {set_in_namespace key_width $option_value}}
		{-labels {set labels $option_value}}
		{-menu {set_in_namespace want_menu_bar $option_value}}
		{-orientation {set_in_namespace orientation $option_value}}
		{-overlay {set overlay_option $option_value}}
		{-ovpal   {palette_option overlay_palette $option_value}}
		{-palette {palette_option main_palette    $option_value}}
		{-paperheight {set ::Print_gui::paperheight $option_value}}
		{-paperwidth {set ::Print_gui::paperwidth $option_value}}
		{-parent {set parent $option_value}}
		{-print {set auto_print $option_value}}
		{-printer {set ::Print_gui::printer_name $option_value}}
		{-range {nap "range_nao = [uplevel 3 "nap \"$option_value\""]"}}
		{-rank  {nap "rank_nao  = [uplevel 3 "nap \"$option_value\""]"}}
		{-scaling {set_in_namespace want_scaling_widget $option_value}}
		{-sub_title {set sub_title $option_value}}
		{-symbols {set symbols $option_value}}
		{-title {set title $option_value}}
		{-type {set type $option_value}}
		{-width {set width $option_value}}
		{-xflip {set_in_namespace xflip $option_value}}
		{-xlabel {set_in_namespace xlabel $option_value}}
		{-yflip {set want_yflip $option_value}}
		{-ylabel {set_in_namespace ylabel $option_value}}
	    } $args]
	if {$i != [llength $args]} {
	    handle_error "Illegal option"
	    return
	}
	Plot_nao::incrRefCount $window_id $nao
	set rank_nao [[nap "i32(rank_nao <<< rank(nao))"]]
	nap "shape_frame = (shape(nao))(0 .. (rank(nao) - rank_nao - 1) ... 1)"
	eval set_overlay $window_id $nao $overlay_option
	set nplots [[nap "prod(shape_frame)"]]
	if {$nplots > 1} {
	    if {$geometry == ""} {
		set geometry "+[winfo rootx .]+[winfo rooty .]"
	    }
	    if {$range_nao == ""} {
		nap "range_nao = range(nao)"
	    }
	    set all ""
	    for {set i 0} {$i < $nplots} {incr i} {
		nap "tmp = (mixed_base(i, shape_frame))(1 .. nels(shape_frame) ... 1)"
		set cell_subscript "[$tmp value -format "%g,"][commas "$rank_nao-1"]"
		unset tmp
		nap "cell = nao(cell_subscript)"
		set cell_title "{$title\n($cell_subscript)}"
		lappend all [eval Plot_nao::plot_nao $cell $args \
			-geometry $geometry \
			-range $range_nao \
			-title $cell_title]
	    }
	} else {
	    if {$type == ""} {
		switch $rank_nao {
		    1 {set type xy}
		    2 {set type [lindex "xy z" [[nap "shape_nao(-2) > 8"]]]}
		    3 {set type z}
		    default {handle_error "rank_nao has value other than 1, 2 or 3!"; return}
		}
	    }
	    set all [Plot_nao::create_window $geometry $parent]
	    incr Plot_nao::frame_id
	    set graph $all.graph
	    set_in_namespace print_command "::Plot_nao::graph2ps $window_id $graph"
	    switch -glob $type {
		b* {
		    Plot_nao::draw_barchart $all $window_id $graph $nao $title \
			    $range_nao $height $width $configure $colors $labels $barwidth
		    bind $graph <Leave> "$graph crosshairs off; destroy $all.xyz"
		}
		t* {
		    Plot_nao::draw_tiles   $all $window_id $graph $nao $title \
			    $ncols $sub_title $range_nao $want_yflip
		}
		x* {
		    Plot_nao::draw_xy       $all $window_id $graph $nao $title \
			    $range_nao $height $width $configure $colors $labels $symbols
		    bind $graph <Leave> "$graph crosshairs off; destroy $all.xyz"
		}
		z  {
		    Plot_nao::draw_z        $all $window_id $graph $nao $title \
			    $height $width $configure $range_nao $buttonCommand $want_yflip
		    bind $graph <Leave> "$graph crosshairs off; destroy $all.xyz"
		}
		default {
		    handle_error "Illegal graph-type"; return
		}
	    }
	    bind $graph <Destroy> "Plot_nao::close_window $window_id"
	    bind $graph <ButtonPress-1> $buttonCommand
	    bind $all <ButtonPress-3> "tk_popup $all.popup %X %Y"
	    update idletasks
	    if {$auto_print} {
		print_write $window_id
		destroy $all
	    }
	}
	return $all
    }

    # print_write --

    proc print_write {
	window_id
    } {
	global Plot_nao::${window_id}::print_command
	if {$::Print_gui::filename == ""} {
	    ::Print_gui::print $print_command
	} else {
	    ::Print_gui::write $print_command
	}
    }


    # create_window --
    #
    # Return path-name of highest-level window

    proc create_window {
	geometry 
	parent
    } {
	set all ".win$Plot_nao::frame_id"
	set parent [string trim $parent]
	if {$parent != ""  &&  $parent != "."} {
	    set all $parent$all
	}
	destroy $all
	if {$parent == ""} {
	    toplevel $all
            update idletasks
	    wm geometry $all $geometry
	    wm title $all "plot_nao  $all"
	} else {
	    frame $all
	    pack $all
	}
	return $all
    }


    # close_window --
    #
    # Do things needed at end

    proc close_window {
	window_id
    } {
	global Plot_nao::${window_id}::histograms
	global Plot_nao::${window_id}::save_nao_ids
	foreach nao $save_nao_ids {
	    $nao set count -1
	}
	eval destroy $histograms
	namespace delete ::Plot_nao::$window_id
    }


    # create_main_menu --
    #
    # Create main menu as menu bar at top if wanted.
    # Also create similar pop-up menu (since main menu may not exist)
    #
    # Create "options", "cancel" and "help" buttons.
    # If argument "redraw_command" is defined then also create "redraw" button.
    # Argument "redraw_command" is defined when called from draw_z & draw_tiles.

    proc create_main_menu {
	all
	window_id
	graph
	{redraw_command ""}
	{nao ""}
    } {
	    # main menu
	global Plot_nao::${window_id}::want_menu_bar
	set m $all.main_menu
	frame $m
	if {$redraw_command != ""} {
	    button $m.redraw -text redraw -command $redraw_command
	    pack $m.redraw -side left -expand 1 -fill both
	}
	menubutton $m.options -text options -menu $m.options.options_menu -relief raised
	button $m.cancel -text cancel -command "destroy $all"
	menubutton $m.help -text help -menu $m.help.help_menu -relief raised
	pack $m.options $m.cancel $m.help -side left -expand 1 -fill both
	pack $m -expand 1 -fill x
	if {!$want_menu_bar} {
	    pack forget $m
	}
	create_options_menu $all $m.options $window_id $graph $redraw_command $nao
	create_help_menu $m.help
	    # pop-up menu
	set m $all.popup
	menu $m
	if {$redraw_command != ""} {
	    $m add command -label redraw -command $redraw_command
	}
	$m add cascade -label options -menu $m.options_menu
	$m add command -label "raise window" -command "raise $all"
	$m add command -label "move window" -command "Plot_nao::move_window $all $m"
	$m add command -label cancel -command "destroy $all"
	$m add cascade -label help -menu $m.help_menu
	create_options_menu $all $m $window_id $graph $redraw_command
	create_help_menu $m
    }


    # create_options_menu --

    proc create_options_menu {
	all
	parent
	window_id
	graph
	{redraw_command ""}
	{nao ""}
    } {
	set options_menu $parent.options_menu
	menu $options_menu
	$options_menu add checkbutton -label "display menu-bar?" \
		-variable Plot_nao::${window_id}::want_menu_bar \
		-command [list Plot_nao::toggle_menu_bar $all $window_id]
	if {$redraw_command != ""} {
	    $options_menu add checkbutton -label "display scaling widget?" \
		    -variable Plot_nao::${window_id}::want_scaling_widget \
		    -command [list Plot_nao::toggle_scaling $all $window_id]
	    $options_menu add checkbutton -label "flip left-right?" \
		    -variable Plot_nao::${window_id}::xflip \
		    -command $redraw_command
	    $options_menu add checkbutton -label "flip upside down?" \
		    -variable Plot_nao::${window_id}::yflip \
		    -command $redraw_command
	    #
	    $options_menu add cascade -label "adjust various sizes" -menu $options_menu.size
	    create_size_menu $all $options_menu $window_id $redraw_command
	    #
	    $options_menu add cascade -label "define main palette" \
		    -menu $options_menu.main_palette
	    create_palette_menu main_palette $all $options_menu $window_id $redraw_command
	    #
	    $options_menu add cascade -label "define overlay (eg coasts)" \
		    -menu $options_menu.overlay
	    create_overlay_menu $all $options_menu $window_id $redraw_command $nao
	    #
	    $options_menu add cascade -label "page orientation" -menu $options_menu.orientation
	    create_orientation_menu $all $options_menu $window_id
	}
	$options_menu add command -label print \
		-command [list Print_gui::widget \$Plot_nao::${window_id}::print_command $all]
	$options_menu add command -label "tcl command" -command "Plot_nao::tcl_command $all $graph"
    }

 
    # move_window --

    proc move_window {
	all
	menu
    } {
	set x [winfo rootx $menu]
	set y [winfo rooty $menu]
	set label {geometry (e.g. '+0+0' for top left corner)}
	wm geometry $all [get_entry $label -geometry +$x+$y -text +0+0]
    }


    # create_size_menu --

    proc create_size_menu {
	all
	options_menu
	window_id
	redraw_command
    } {
	set m $options_menu.size
	menu $m
	set command "set Plot_nao::${window_id}::new_width"
	append command { [get_entry "width of image in pixels"}
	append command " -parent $all -text \$Plot_nao::${window_id}::new_width]"
	append command "; $redraw_command"
	$m add command -label "adjust width of image" -command $command
	#
	set command "set Plot_nao::${window_id}::new_height"
	append command { [get_entry "height of image in pixels"}
	append command " -parent $all -text \$Plot_nao::${window_id}::new_height]"
	append command "; $redraw_command"
	$m add command -label "adjust height of image" -command $command
	#
	set command "set Plot_nao::${window_id}::magnification"
	append command { [get_entry "magnification factor (relative to original NAO)"}
	append command " -parent $all -text 1.0]"
	append command "; $redraw_command"
	$m add command -label "adjust height & width of image" -command $command
	#
	set command "set Plot_nao::${window_id}::key_width"
	append command { [get_entry "width of key in pixels (no key if blank)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::key_width]"
	append command "; $redraw_command"
	$m add command -label "adjust width of key" -command $command
	#
	set command "set Plot_nao::${window_id}::gap_width"
	append command { [get_entry "width of vertical gaps (pixels)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::gap_width]"
	append command "; $redraw_command"
	$m add command -label "adjust width of vertical gaps" -command $command
	#
	set command "set Plot_nao::${window_id}::gap_height"
	append command { [get_entry "height of horizontal gaps (pixels)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::gap_height]"
	append command "; $redraw_command"
	$m add command -label "adjust height of horizontal gaps" -command $command
    }


    # create_palette_menu --

    proc create_palette_menu {
	name
	all
	parent
	window_id
	redraw_command
    } {
	set palette_menu $parent.$name
	menu $palette_menu
	$palette_menu add command -label "black to white" \
		-command "Plot_nao::set_palette $name $window_id {}; $redraw_command"
	$palette_menu add command -label "white to black" \
		-command "Plot_nao::set_palette $name $window_id \
			\"transpose(reshape(255 .. 0 ... -1, 3 // 256))\"; $redraw_command"
	$palette_menu add command -label "blue to red (white = missing)" \
		-command "Plot_nao::palette_interpolate $name $window_id 240 0; $redraw_command"
	$palette_menu add command -label "red to blue (white = missing)" \
		-command "Plot_nao::palette_interpolate $name $window_id 0 240; $redraw_command"
	$palette_menu add command -label "green to red (white = missing)" \
		-command "Plot_nao::palette_interpolate $name $window_id -240 0; $redraw_command"
	$palette_menu add command -label "red to green (white = missing)" \
		-command "Plot_nao::palette_interpolate $name $window_id 0 -240; $redraw_command"
	$palette_menu add command \
		-label "default overlay palette: 0=black, 1=white, 2=red, 3=green, 4=blue" \
		-command "nap \"::Plot_nao::${window_id}::overlay_palette =
			f32{{3#0}{3#1}{1 0 0}{0 1 0}{0 0 1}}\"; $redraw_command"
	$palette_menu add command -label "define palette using 'pal' GUI" \
		-command [list pal ::Plot_nao::${window_id}::$name $redraw_command]
	$palette_menu add command -label "define palette using NAP expression" \
		-command "Plot_nao::palette_nap $name $all $window_id; $redraw_command"
	$palette_menu add command -label "read palette from text file" \
		-command "Plot_nao::palette_file $name $all $window_id; $redraw_command"
    }


    # create_orientation_menu --

    proc create_orientation_menu {
	all
	parent
	window_id
    } {
	set m $parent.orientation
	menu $m
	$m add radiobutton -label portrait  -variable ::Plot_nao::${window_id}::orientation -value P
	$m add radiobutton -label landscape -variable ::Plot_nao::${window_id}::orientation -value L
	$m add radiobutton -label automatic -variable ::Plot_nao::${window_id}::orientation -value A
    }


    # create_overlay_menu --

    proc create_overlay_menu {
	all
	parent
	window_id
	redraw_command
	nao
    } {
	set m $parent.overlay
	menu $m
	$m add command -label "set overlay NAO coast values to 0" \
		-command "::Plot_nao::set_overlay $window_id $nao coast; $redraw_command"
	#
	$m add command -label "set overlay NAO land values to 2" \
		-command "::Plot_nao::set_overlay $window_id $nao land; $redraw_command"
	#
	$m add command -label "set overlay NAO sea values to 4" \
		-command "::Plot_nao::set_overlay $window_id $nao sea; $redraw_command"
	#
	$m add command -label "set overlay NAO using NAP expression" \
		-command "::Plot_nao::overlay_nap $all $window_id; $redraw_command"
	#
	$m add command -label "clear overlay NAO" \
		-command "::Plot_nao::set_overlay $window_id $nao none; $redraw_command"
	#
	$m add separator
	#
	$m add cascade -label "define overlay palette" -menu $m.overlay_palette
	create_palette_menu overlay_palette $all $m $window_id $redraw_command
    }


    # overlay_land_flag --

    proc overlay_land_flag {
	func
	value
	nao
    } {
	global Plot_nao::overlay_nao
	nap "longitude = coordinate_variable(nao, -1)"
	nap "latitude  = coordinate_variable(nao, -2)"
	if {$overlay_nao == ""} {
	    nap "overlay_nao = 255u8"
	    $overlay_nao set missing 255
	}
	nap "overlay_nao = ${func}(latitude, longitude) ? u8(value) : overlay_nao"
	$overlay_nao set missing 255
	$overlay_nao set coo latitude longitude
    }


    # create_help_menu --

    proc create_help_menu {
	parent
    } {
	set help_menu $parent.help_menu
	menu $help_menu -tearoff 0
	$help_menu add command -label introduction -command "Plot_nao::help_intro"
	$help_menu add command -label usage -command \
		{message_window $::Plot_nao::help_usage -geometry +0+0 -parent ""}
	$help_menu add command -label "BLT graph manual" \
		-command "Plot_nao::help_www_car caps/CAPS_BLT_Graph.html"
	$help_menu add command -label "BLT barchart manual" \
		-command "Plot_nao::help_www_car caps/CAPS_BLT_Barchart.html"
    }


    # help_intro --
    #
    # Display introduction to plot_nao

    proc help_intro {
    } {
	set text \
	    "Produce xy-graph, barchart (histogram) or z-plot (image).\
	    \n\
	    \nUses BLT graph or barchart command. A z-plot is produced using the graph\
	    \nimage marker facility.\
	    \n\
	    "
	message_window $text -geometry +0+0 -parent ""
    }


    # help_www_car --
    #
    # Run www browser to access help at CAR

    proc help_www_car {
	filename
    } {
	exec $::caps_www_browser http://www.dar.csiro.au/rs/$filename &
    }


    # toggle_menu_bar --
    #
    # Make menu-bar visible or invisible

    proc toggle_menu_bar {
	all
	window_id
    } {
	global Plot_nao::${window_id}::want_menu_bar
	set m $all.main_menu
	if {$want_menu_bar} {
	    pack $m -before [lindex [pack slaves $all] 0] -expand 1 -fill x
	} else {
	    pack forget $m
	}
	update idletasks
    }


    # toggle_scaling --
    #
    # Make scaling_range widget visible or invisible

    proc toggle_scaling {
	all
	window_id
    } {
	global Plot_nao::${window_id}::want_scaling_widget
	if {$want_scaling_widget} {
	    pack $all.scaling_range -before $all.graph -anchor w
	} else {
	    pack forget $all.scaling_range
	}
	update idletasks
    }


    # create_scaling_range --
    #
    # Create "histogram" button & entry widgets for min & max values defining scaling for z plots

    proc create_scaling_range {
	all
	window_id
	frame
	nao
	layer
	color
    } {
	destroy $frame
	frame $frame -relief ridge -borderwidth 3
	button $frame.histogram -text histogram -pady 0.3m\
		-command "Plot_nao::plot_histogram $all $window_id $nao $layer"
	label $frame.from -text "Scale from"
	entry $frame.from_entry -relief sunken -width 10 \
		-textvariable Plot_nao::${window_id}::scalingFrom($layer)
	label $frame.to -text "to"
	entry $frame.to_entry -relief sunken -width 10 \
		-textvariable Plot_nao::${window_id}::scalingTo($layer)
	pack $frame.histogram $frame.from $frame.from_entry $frame.to $frame.to_entry \
		-side left -anchor w -fill y
	if {$color != "black"} {
	    $frame configure -background $color
	}
	pack $frame -anchor w
    }


    # overlay_nap --
    #
    # Get NAP expression from user & use it to define overlay_nao

    proc overlay_nap {
	all
	window_id
    } {
	set Plot_nao::${window_id}::call_level #0
	set expr [get_entry expression -parent $all -width 40]
	set_overlay $window_id "" expr $expr
    }


    # palette_file --
    #
    # Read palette from file

    proc palette_file {
	name 
	all
	window_id
    } {
	set filename [tk_getOpenFile \
		-defaultextension .pal \
		-filetypes {{{Palette Files} {.pal}}} \
		-parent $all \
		-title "palette file" \
	]
	set_palette $name $window_id "gets_matrix('$filename')"
    }


    # palette_nap --
    #
    # Get NAP expression from user & use it to define palette

    proc palette_nap {
	name 
	all
	window_id
    } {
	set expr [get_entry expression -parent $all -width 40]
	set_palette $name $window_id $expr
    }


    # set_palette --
    #
    # Define either main_palette or overlay_palette using specified NAP expression, which
    # is evaluated in caller's namespace
    # If expr is "" then set palette to ""

    proc set_palette {
	name 
	window_id
	expr
    } {
	global ::Plot_nao::${window_id}::call_level
	switch $name {
	    main_palette	{set n ::Plot_nao::${window_id}::$name}
	    overlay_palette	{set n ::Plot_nao::$name}
	}
	if {$expr == ""} {
	    set $n ""
	} else {
	    if [catch "uplevel $call_level nap \"$n = u8($expr)\"" result] {
		handle_error $result
	    }
	}
    }


    # palette_interpolate --
    #
    # Define palette by interpolating round colour wheel (with s = v = 1)
    # from & to are angles in degrees (Red = 0, green = -240, blue = 240)

    proc palette_interpolate {
	name
	window_id
	from
	to
    } {
	nap "n = 255"
	nap "h = ap_n(f32(from), f32(to), n)"
	nap "s = v = n # 1f32"
	nap "mat = transpose(hsv2rgb(h /// s /// v))"
	nap "white = 3 # 1f32"
	nap "::Plot_nao::${window_id}::$name = u8(255.999f32 * (mat // white))"
    }


    # set_overlay --
    #
    # Define overlay_nao.
    # If mode is "none" then set overlay_nao to "".
    # If mode is "coast", "land" or "sea" then set overlay_nao using "land_flag", using
    #   coordinate vars of <nao> for latitude & longitude.
    # If mode is "expr" then set overlay_nao using NAP expression specified by <args>. This
    #   expression is evaluated in caller's namespace.
    # mode can be abbreviated to 1st letter.

    proc set_overlay {
	window_id
	nao
	mode
	args
    } {
	global Plot_nao::${window_id}::call_level
	switch [string toupper [string index $mode 0]] {
	    N	{set ::Plot_nao::overlay_nao ""}
	    C	{overlay_land_flag is_coast 0 $nao}
	    L	{overlay_land_flag is_land  2 $nao}
	    S	{overlay_land_flag !is_land 4 $nao}
	    E	{
		if [catch "uplevel $call_level nap \"::Plot_nao::overlay_nao = $args\"" result] {
		    handle_error $result
		}
	    }
	}
    }


    # plot_histogram --
    #
    # Plot histogram (frequencies)

    proc plot_histogram {
	all
	window_id
	nao
	layer
	{n 100}
	{height 250}
	{width  300}
    } {
	global Plot_nao::${window_id}::histograms
	global Plot_nao::${window_id}::scalingFromTitle
	global Plot_nao::${window_id}::scalingToTitle
	set graph $all.graph
	set geometry +[winfo rootx $graph]+[winfo rooty $graph]
	if [[nap "rank(nao) == 3"]] {
	    set text "Histogram of layer $layer"
	    nap "data = f32(nao(layer,,))"
	} else {
	    set text "Histogram"
	    nap "data = f32(nao)"
	}
	set scalingFromTitle "$text\nLeft click to set 'from' value"
	set scalingToTitle "$text\nLeft click to set 'to' value"
	set color [color_of_layer $nao $layer]
	nap "r = range(data)"
	nap "delta = (r(1) - r(0)) / f32(n)"
	if [[nap "delta > 0"]] {
	    nap "f = frequency(data, n, r(0), delta)"
	    $f set coo "0.5 * delta + cv(f)"
	} else {
	    nap "delta = 1"
	    nap "f = n # 0"
	}
	set buttonCommand \
		"Plot_nao::histogram_button_command $window_id $layer [llength $histograms]"
	set histogram [::Plot_nao::plot_nao $f \
		-barwidth [$delta] \
		-buttonCommand $buttonCommand \
		-colors $color \
		-configure "configure -font {-family helvetica}" \
		-geometry $geometry \
		-height $height \
		-title $scalingFromTitle \
		-type bar \
		-width $width \
	]
	lappend histograms $histogram
    }

    # histogram_button_command --
    #
    # This is executed when mouse button in pressed when cross-hairs are over histogram.
    # The x position of cross-hairs alternately defines scalingFrom & scalingTo.

    proc histogram_button_command {
	window_id
	layer
	index
    } {
	global Plot_nao::${window_id}::histograms
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingFromIsNext
	global Plot_nao::${window_id}::scalingFromTitle
	global Plot_nao::${window_id}::scalingTo
	global Plot_nao::${window_id}::scalingToTitle
	global Plot_nao::x
	if {$scalingFromIsNext($layer)} {
	    set scalingFrom($layer) $x
	    set scalingFromIsNext($layer) 0
	} else {
	    set scalingTo($layer) $x
	    set scalingFromIsNext($layer) 1
	}
	set histogram [lindex $histograms $index]
	if {$scalingFromIsNext($layer)} {
	    $histogram.graph configure -title $scalingFromTitle
	} else {
	    $histogram.graph configure -title $scalingToTitle
	}
    }


    # tcl_command --
    #
    # Called using "tcl command" button

    proc tcl_command {
	all
	graph
    } {
	set command [get_entry "tcl command" -width 80 -text $graph -parent $all]
	if {$command != ""} {
	    puts $command
	    set result [history add $command exec]
	    if {$result != ""} {
		puts $result
		if [info exists ::tcl_prompt1] {
		    $::tcl_prompt1
		} else {
		    puts -nonewline "% "
		    flush stdout
		}
	    }
	}
    }


    # create_xyz --
    #
    # Create widget $all.xyz to display x, y and z values defined by crosshairs
    # Only get z values if $want_z

    proc create_xyz {
	all
	window_id
	graph
	want_z
    } {
        global Plot_nao::${window_id}::xlabel
        global Plot_nao::${window_id}::ylabel
	set w $all.xyz
	frame $w -relief raised -borderwidth 4
	    # 20 is default height of label (need to specify since using placer not packer)
	frame $w.xy -height 20
	frame $w.xy.x
	frame $w.xy.y
	if {$xlabel == ""} {
	    label $w.xy.x.label -text x
	} else {
	    label $w.xy.x.label -text $xlabel
	}
	label $w.xy.x.value -textvariable Plot_nao::x \
		-anchor w -relief sunken -background white
	if {$ylabel == ""} {
	    label $w.xy.y.label -text y
	} else {
	    label $w.xy.y.label -text $ylabel
	}
	label $w.xy.y.value -textvariable Plot_nao::y \
		-anchor w -relief sunken -background white
	pack $w.xy.x.label -side left -anchor w
	pack $w.xy.x.value -side left -expand 1 -fill x
	pack $w.xy.y.label -side left -anchor w
	pack $w.xy.y.value -side left -expand 1 -fill x
	place $w.xy.x -relwidth 0.5 -relx 0 -rely 0 -anchor nw
	place $w.xy.y -relwidth 0.5 -relx 1 -rely 0 -anchor ne
	pack $w.xy -expand 1 -fill x
	if {$want_z} {
	    label $w.z -textvariable Plot_nao::z \
		    -anchor w -relief sunken -background white
	    pack $w.z -expand 1 -fill x
	}
	place $w -x 0 -y 0 -relwidth 1
	$graph crosshairs on
    }


    # draw_barchart --
    #
    # Draw bar-chart (histogram) defined by 1D or 2D NAO.
    # Delete points whose x or y value is missing.

    proc draw_barchart {
	all
	window_id
	graph
	nao
	title
	range_nao
	height
	width
	configure
	colors
	labels
	barwidth
    } {
        global Plot_nao::${window_id}::xlabel
        global Plot_nao::${window_id}::ylabel
	package require BLT
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	create_main_menu $all $window_id $graph
	nap "cvx = coordinate_variable(nao, -1)"
	blt::barchart $graph -title $title -barmode aligned -barwidth $barwidth \
		-plotrelief flat -background white
	configure_graph $graph $configure
	$graph grid off
	$graph axis configure x -title $xlabel
	if {$range_nao == ""} {
	    $graph axis configure y -loose 1
	} else {
	    nap "range_nao = range(range_nao)"
	    nap "axis = scaleAxisSpan(range_nao(0), range_nao(1), 10)"
	    $graph axis configure y -min [[nap "axis(0)"]]
	    $graph axis configure y -max [[nap "axis(-1)"]]
	    $graph axis configure y -stepsize [[nap "axis(1) - axis(0)"]]
	}
	if {$height != ""} {
	    $graph configure -height $height
	}
	if {$width != ""} {
	    $graph configure -width $width
	}
	switch [$nao rank] {
	    1 {
		nap "mask = count(cvx,0) && count(nao,0)"
		nap "xnao = f64(mask # cvx)"
		nap "ynao = f64(mask # nao)"
		set xcommand ::Plot_nao::${window_id}::blt_vector_x
		set ycommand ::Plot_nao::${window_id}::blt_vector_y
		set xname ::Plot_nao::${window_id}::xdata
		set yname ::Plot_nao::${window_id}::ydata
		blt::vector create $xname -variable "" -command $xcommand
		blt::vector create $yname -variable "" -command $ycommand
		$xnao blt_vector $xname 
		$ynao blt_vector $yname 
		nap "xstart = min(xnao) - 0.5 * barwidth"
		nap "xend   = max(xnao) + 0.5 * barwidth"
		nap "majorticks = scaleAxisSpan(xstart, xend)"
		$graph axis configure x -min [[nap "majorticks(0)"]]
		$graph axis configure x -max [[nap "majorticks(-1)"]]
		$graph axis configure x -majorticks [$majorticks value]
		$graph legend configure -hide yes
		$graph element create y0 \
			-foreground [lindex $colors 0] \
			-borderwidth 0 \
			-xdata $xname \
			-ydata $yname
	    }
	    2 {
		set nrows [[nap "(shape(nao))(0)"]]
		$graph legend configure -hide [expr $nrows < 2]
		for {set i  0} {$i < $nrows} {incr i} {
		    set label [lindex $labels $i]
		    if {$label == ""} {
			set label y$i
		    }
		    nap "mask = count(cvx,0) && count(nao(i,),0)"
		    nap "xnao = f64(mask # cvx)"
		    nap "ynao = f64(mask # nao(i,))"
		    set xcommand ::Plot_nao::${window_id}::blt_vector_x_$i
		    set ycommand ::Plot_nao::${window_id}::blt_vector_y_$i
		    set xname ::Plot_nao::${window_id}::xdata_$i
		    set yname ::Plot_nao::${window_id}::ydata_$i
		    blt::vector create $xname -variable "" -command $xcommand
		    blt::vector create $yname -variable "" -command $ycommand
		    $xnao blt_vector $xname 
		    $ynao blt_vector $yname 
		    $graph element create $label \
			    -foreground [lindex $colors $i] \
			    -borderwidth 0 \
			    -xdata $xname \
			    -ydata $yname
		}
	    }
	    default {
		handle_error "Illegal rank"
		return
	    }
	}
	bind $graph <Motion> \
		"Plot_nao::crosshairs_xy [list $all $window_id $nao $graph %x %y]"
	pack $graph -anchor w -padx 2
    }


    # draw_xy --
    #
    # Draw XY graph defined by 1D or 2D NAO.
    # Delete points whose x or y value is missing.

    proc draw_xy {
	all
	window_id
	graph
	nao
	title
	range_nao
	height
	width
	configure
	colors
	labels
	symbols
    } {
        global Plot_nao::${window_id}::xlabel
        global Plot_nao::${window_id}::ylabel
	package require BLT
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	create_main_menu $all $window_id $graph
	nap "cvx = coordinate_variable(nao, -1)"
	blt::graph $graph -title $title -plotpadx 0 -plotpady 0 -plotrelief flat -background white
	configure_graph $graph $configure
	$graph axis configure x -title $xlabel
	$graph axis configure x -loose 1
	if {$range_nao == ""} {
	    $graph axis configure y -loose 1
	} else {
	    nap "range_nao = range(range_nao)"
	    nap "axis = scaleAxisSpan(range_nao(0), range_nao(1), 10)"
	    $graph axis configure y -min [[nap "axis(0)"]]
	    $graph axis configure y -max [[nap "axis(-1)"]]
	    $graph axis configure y -stepsize [[nap "axis(1) - axis(0)"]]
	}
	if {$height != ""} {
	    $graph configure -height $height
	}
	if {$width != ""} {
	    $graph configure -width $width
	}
	switch [$nao rank] {
	    1 {
		nap "mask = count(cvx,0) && count(nao,0)"
		nap "xnao = f64(mask # cvx)"
		nap "ynao = f64(mask # nao)"
		set xcommand ::Plot_nao::${window_id}::blt_vector_x
		set ycommand ::Plot_nao::${window_id}::blt_vector_y
		set xname ::Plot_nao::${window_id}::xdata
		set yname ::Plot_nao::${window_id}::ydata
		blt::vector create $xname -variable "" -command $xcommand
		blt::vector create $yname -variable "" -command $ycommand
		$xnao blt_vector $xname 
		$ynao blt_vector $yname 
		$graph legend configure -hide yes
		$graph element create y0 \
			-color [lindex $colors 0] \
			-symbol [lindex $symbols 0] \
			-xdata $xname \
			-ydata $yname
	    }
	    2 {
		set nrows [[nap "(shape(nao))(0)"]]
		set ncolors [llength $colors]
		$graph legend configure -hide [expr $nrows < 2  ||  $nrows > $ncolors]
		for {set i  0} {$i < $nrows} {incr i} {
		    set label [lindex $labels $i]
		    if {$label == ""} {
			set label y$i
		    }
		    nap "mask = count(cvx,0) && count(nao(i,),0)"
		    nap "xnao = f64(mask # cvx)"
		    nap "ynao = f64(mask # nao(i,))"
		    set xcommand ::Plot_nao::${window_id}::blt_vector_x_$i
		    set ycommand ::Plot_nao::${window_id}::blt_vector_y_$i
		    set xname ::Plot_nao::${window_id}::xdata_$i
		    set yname ::Plot_nao::${window_id}::ydata_$i
		    blt::vector create $xname -variable "" -command $xcommand
		    blt::vector create $yname -variable "" -command $ycommand
		    $xnao blt_vector $xname 
		    $ynao blt_vector $yname 
		    $graph element create $label \
			    -color [lindex $colors [expr $i % $ncolors]] \
			    -symbol [lindex $symbols $i] \
			    -xdata $xname \
			    -ydata $yname
		}
	    }
	    default {
		handle_error "Illegal rank"
		return
	    }
	}
	bind $graph <Motion> "Plot_nao::crosshairs_xy [list $all $window_id $nao $graph %x %y]"
	pack $graph -anchor w -padx 2
    }


    # draw_z --
    #
    # Draw grey-scale or color image defined by 2D or 3D NAO.
    #
    # Image is grey-scale if 2D and no palette.
    # 3D NAO can have any number of layers. Only 1st three layers affect image
    # but values of others are displayed using cross-hairs.

    proc draw_z {
	all
	window_id
	graph
	nao
	title
	height
	width
	configure
	range_nao
	buttonCommand
	want_yflip
	{min_factor 0.05}
	{max_factor 0.8}
    } {
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
        global Plot_nao::overlay_nao
        global Plot_nao::${window_id}::main_palette
        global Plot_nao::${window_id}::want_scaling_widget
        global Plot_nao::${window_id}::xlabel
        global Plot_nao::${window_id}::ylabel
	package require BLT
	nap "old_nao = nao"
	if {[[nap "rank(nao) < 2"]]} {
	    handle_error "Illegal rank"
	    return
	}
	set screen_height [winfo screenheight $all]
	switch [llength $height] {
	    0 {
		set min_height [expr "int($screen_height * $min_factor)"]
		set max_height [expr "int($screen_height * $max_factor)"]
	    }
	    1 {
		set min_height $height
		set max_height $height
	    }
	    2 {
		set min_height [lindex $height 0]
		set max_height [lindex $height 1]
	    }
	    default {
		handle_error "height has > 2 elements"
		return
	    }
	}
	set screen_width  [winfo screenwidth  $all]
	switch [llength $width] {
	    0 {
		set min_width [expr "int($screen_width * $min_factor)"]
		set max_width [expr "int($screen_width * $max_factor)"]
	    }
	    1 {
		set min_width $width
		set max_width $width
	    }
	    2 {
		set min_width [lindex $width 0]
		set max_width [lindex $width 1]
	    }
	    default {
		handle_error "width has > 2 elements"
		return
	    }
	}
	set_yflip $window_id $want_yflip $nao
	if {$overlay_nao != ""} {
	    if {[$overlay_nao datatype] != "boxed"} {
		nap "cvx = coordinate_variable(overlay_nao,-1)"
		nap "cvy = coordinate_variable(overlay_nao,-2)"
		if {[geog_unit [$cvx unit]] == "degrees_east"} {
		    nap "cvx = fix_longitude(cvx)"
		}
		$overlay_nao set coord $cvy $cvx
	    }
	}
	nap "cvx = coordinate_variable(nao,-1)"
	nap "cvy = coordinate_variable(nao,-2)"
	if {[geog_unit [$cvx unit]] == "degrees_east"} {
	    nap "cvx = fix_longitude(cvx)"
	}
	switch [$nao rank] {
	    2 {$nao set coord $cvy $cvx}
	    3 {$nao set coord "coordinate_variable(nao,0)" $cvy $cvx}
	}
	set nx [$cvx nels]
	set ny [$cvy nels]
	if {$min_width <= $nx && $nx <= $max_width && $min_height <= $ny && $ny <= $max_height} {
	    set new_height $ny
	    set new_width  $nx
	} else {
	    set min_sfx [expr "double($min_width) / double($nx)"]
	    set min_sfx [expr "$min_sfx > 1.0 ? ceil($min_sfx) : 1.0 / floor(1.0 / $min_sfx)"]
	    set max_sfx [expr "double($max_width) / double($nx)"]
	    set max_sfx [expr "$max_sfx > 1.0 ? floor($max_sfx) : 1.0 / ceil(1.0 / $max_sfx)"]
	    if {$min_sfx > $max_sfx } {
		set max_sfx $min_sfx
	    }
	    set min_sfy [expr "double($min_height) / double($ny)"]
	    set min_sfy [expr "$min_sfy > 1.0 ? ceil($min_sfy) : 1.0 / floor(1.0 / $min_sfy)"]
	    set max_sfy [expr "double($max_height) / double($ny)"]
	    set max_sfy [expr "$max_sfy > 1.0 ? floor($max_sfy) : 1.0 / ceil(1.0 / $max_sfy)"]
	    if {$min_sfy > $max_sfy } {
		set max_sfy $min_sfy
	    }
	    if {$max_sfx < $min_sfy} {
		set sfx $max_sfx
		set sfy $min_sfy
	    } elseif {$max_sfy < $min_sfx} {
		set sfy $max_sfy
		set sfx $min_sfx
	    } else {
		set max_mins [expr "$min_sfx > $min_sfy ? $min_sfx : $min_sfy"]
		set min_maxs [expr "$max_sfx < $max_sfy ? $max_sfx : $max_sfy"]
		set sfx [expr "$max_mins > 1.0 ? ceil($max_mins) : 1.0 / ceil(1.0 / $min_maxs)"]
		set sfy $sfx
	    }
	    set new_height [expr "round($sfy * $ny)"]
	    set new_width  [expr "round($sfx * $nx)"]
	    nap "old_cvx = cvx"
	    nap "old_cvy = cvy"
	    if {$sfx > 1} {
		nap "step = (cvx(1 .. (nx-1)) - cvx(0 .. (nx-2))) / f32(sfx)"
		nap "n = i32(nint(sfx))"
		nap "step = (n/2) # step(0) // n # step // ((n+1)/2) # step(-1)"
		nap "cvx = psum((cvx(0) - 0.5 * (cvx(1) - cvx(0))) // step)"
	    } else {
		nap "step = i32(nint(1.0/sfx))"
		nap "cvx = cvx(0 .. ((nx-1)/step*step) ... step)"
	    }
	    if {$sfy > 1} {
		nap "step = (cvy(1 .. (ny-1)) - cvy(0 .. (ny-2))) / f32(sfy)"
		nap "n = i32(nint(sfy))"
		nap "step = (n/2) # step(0) // n # step // ((n+1)/2) # step(-1)"
		nap "cvy = psum((cvy(0) - 0.5 * (cvy(1) - cvy(0))) // step)"
	    } else {
		nap "step = i32(nint(1.0/sfy))"
		nap "cvy = cvy(0 .. ((ny-1)/step*step) ... step)"
	    }
	    $cvx set unit [$old_cvx unit]
	    $cvy set unit [$old_cvy unit]
	    nap "nx = nels(cvx)"
	    nap "ny = nels(cvy)"
	    switch [$nao rank] {
		2 {nap "nao = nao(old_cvy@@cvy, old_cvx@@cvx)"}
		3 {nap "nao = nao(, old_cvy@@cvy, old_cvx@@cvx)"}
	    }
	    unset old_cvx old_cvy
	}
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	Plot_nao::incrRefCount $window_id $cvx
	Plot_nao::incrRefCount $window_id $cvy
	set x0 0
	set xend [[nap "nx - 1"]]
	set y0   [[nap "ny - 1"]]
	set yend 0
	    # If overlay_nao is boxed (polyline) then convert to overlay matrix
	if {$overlay_nao != ""} {
	    if {[$overlay_nao datatype] == "boxed"} {
		nap "box = $overlay_nao"
		nap "overlay_nao = reshape(f32(_), (shape(nao)){-2 -1})"
		$overlay_nao set coord [$nao coord]
		set n [$box nels]
		for {set i 0} {$i < $n} {incr i} {
		    nap "p = open_box(box, i)"
		    nap "px = cvx @@ p(,0)"
		    nap "py = cvy @@ p(,1)"
		    nap "pxy = px /// py"
		    $overlay_nao draw $pxy 1f32
		}
	    }
	}
	set redraw_command [list Plot_nao::draw_image $all $window_id $graph $nao $range_nao \
		$x0 $y0 $xend $yend $cvx $cvy $old_nao]
	create_main_menu $all $window_id $graph $redraw_command $nao
	blt::graph $graph -title $title -plotpadx 0 -plotpady 0 -plotborder 0 -background white
	configure_graph $graph $configure
	$graph legend configure -hide yes
	$graph axis configure x -min $x0 -max $xend -ticklength 5
	$graph axis configure y -max $y0 -min $yend -descending 1 -ticklength 5
	set_axis_label $graph x $xlabel $cvx
	set_axis_label $graph y $ylabel $cvy
	$graph element create dummy -hide 1 -symbol {} -xdata "$x0 $xend" -ydata "$y0 $yend"
	frame $all.scaling_range
	if {$want_scaling_widget} {
	    pack $all.scaling_range -anchor w
	}
	pack $graph -anchor w
	set nlayers [[nap "rank(nao) == 2 ? 1 : (3 <<< (shape(nao))(0))"]]
	for {set layer 0} {$layer < $nlayers} {incr layer} {
	    set color [color_of_layer $nao $layer]
	    set frame $all.scaling_range.$color
	    create_scaling_range $all $window_id $frame $nao $layer $color
	}
	draw_image $all $window_id $graph $nao $range_nao $x0 $y0 $xend $yend \
		$cvx $cvy $old_nao
	bind $graph <Motion> "Plot_nao::crosshairs_xyz [list $all $window_id %x %y]"
    }


    # set_axis_label --

    proc set_axis_label {
	graph
	axisName
	label
	cv
	{bottom_margin 60}
    } {
	set label [string trim $label]
	set unit [string trim [$cv unit]]
	if {$label != ""} {
	    if {![regexp {^$|^\(NULL\)$|^degrees_(east|north)$} [geog_unit $unit]]} {
		append label " ($unit)"
	    }
	    $graph axis configure $axisName -title $label
	    if {$axisName == "x"} {
		$graph configure -bottommargin $bottom_margin
	    }
	}
    }


    # set_yflip --
    #
    # set Plot_nao::${window_id}::yflip

    proc set_yflip {
	window_id
	want_yflip
	nao
    } {
	global Plot_nao::${window_id}::yflip
	set row_cv [$nao coord -2]
	if {$row_cv == "(NULL)"} {
	    set ascending 0
	    set unit (NULL)
	} else {
	    set ascending [[nap "row_cv(0) < row_cv(-1)"]]
	    set unit [geog_unit [$row_cv unit]]
	}
	switch [string tolower [string index $want_yflip 0]] {
	    a {
		set yflip $ascending
	    }
	    g {
		set dimname [$nao dim -2]
		if {$ascending  &&  ($dimname == "latitude"  ||  $unit == "degrees_north")} {
		    set yflip 1
		} else {
		    set yflip 0
		}
	    }
	    default {
		set yflip $want_yflip
	    }
	}
    }


    # configure_ticks --
    #
    # Configure tick values for axis treating both major & minor as major.
    # (Procedure tick_label suppresses label if minor.)
    #
    # Configure command (calling tick_label) to produce text for axis tick label.
    #
    # Label is minor one if step is 5*10**n (for some integer n) & label/step is odd

    proc configure_ticks {
	graph
	axisName
	cv
	length
	{delta_min 40}
	{nmin 4}
	{nice "{1 2 5}"}
    } {
	nap "nmax = nmin >>> (length / delta_min)"
	nap "labels = scaleAxis(cv(0), cv(-1), nmax, nice)"
	nap "step = labels(1) - labels(0)"
	nap "abs_step = abs(step)"
	if {[$abs_step] > 10  &&  [regexp {^degrees_(east|north)$} [geog_unit [$cv unit]]]} {
	    nap "cv_min = cv(0) <<< cv(-1)"
	    nap "cv_max = cv(0) >>> cv(-1)"
	    nap "trial_nice = {15 30 45 90 180 360}"
	    nap "trial_step = trial_nice(trial_nice @@ abs_step)"
	    nap "label_min = trial_step * ceil(cv_min/trial_step)"
	    nap "label_max = trial_step * floor(cv_max/trial_step)"
	    nap "trial_labels = label_min ..  label_max ... trial_step"
	    if [[nap "nels(trial_labels) > 1"]] {
		nap "step = trial_step"
		nap "abs_step = abs(step)"
		nap "labels = step > 0.0 ? trial_labels : reverse(trial_labels)"
	    }
	}
	nap "n = nels(labels)"
	nap "i = cv @ labels"
	nap "normalisedStep = 10.0 ** (log10(abs_step) % 1.0)"
	nap "wantMinors = abs(normalisedStep - 5.0) < 1e-3"
	nap "isMajor = wantMinors ? nint(labels/abs_step) % 2 == 0 : n # 1"
	nap "isMajor = sum(isMajor) < 2 ? n # 1 : isMajor"
	$graph axis configure $axisName \
		-majorticks [$i value] \
		-command "Plot_nao::tick_label $cv {{{[$labels value]}{[$isMajor value]}}}"
    }


    # tick_label --
    #
    # Format tick label for axis
    # See comments above for proc configure_ticks re major & minor ticks.

    proc tick_label {
	cv
	labels
	path
	i
    } {
	set result ""
	nap "matrix = labels"
	nap "j = matrix(0,) @@ cv(i)"
	nap "x = matrix(0,j)"
	if [[nap "matrix(1,j)"]] {
	    set result [geog_format $x [$cv unit]]
	}
	return $result
    }


    # geog_format --
    #
    # Format a scalar nao with special treatment of latitudes & longitudes

    proc geog_format {
	nao
	unit
	{geog_format_spec ""}
    } {
	nap "degree = c8(0260)"; # ISO-8859 code for degree symbol
	switch [geog_unit $unit] {
	    degrees_north {
		nap "suffix = degree // (' NS'(sign(nao)))"
		nap "a = abs(nao)"
		set result "[$a -format $geog_format_spec][$suffix]"
	    }
	    degrees_east {
		nap "nao = (nao + 180f32) % 360f32 - 180f32"
		nap "a = abs(nao)"
		nap "suffix = degree // (' EW'(a < 180f32 ? sign(nao) : 0f32))"
		set result "[$a -format $geog_format_spec][$suffix]"
	    }
	    default {
		set result [$nao]
	    }
	}
	return $result
    }


    # geog_unit --
    #
    # Return "degrees_east"  if arg is anything equivalent to this e.g. "degreeE"
    # Return "degrees_north" if arg is anything equivalent to this e.g. "degreeN"
    # Otherwise just return arg

    proc geog_unit {
	unit
    } {
	switch -regexp [string tolower $unit] {
	    ^degree.*e	{return degrees_east}
	    ^degree.*n	{return degrees_north}
	    default	{return $unit}
	}
    }


    # color_of_layer --
    #
    # Return color of specified layer of 3D-plot

    proc color_of_layer {
	nao layer
    } {
	set color black
	if {[$nao rank] == 3} {
	    set nlayers [[nap "(shape(nao))(0)"]]
	    if {$layer < $nlayers} {
		switch $nlayers {
		    1		{}
		    2		{set color [lindex "yellow    blue" $layer]}
		    default	{set color [lindex "red green blue" $layer]}
		}
	    }
	}
	return $color
    }


    # draw_image --
    #
    # Draw grey-scale or color image
    # Called by draw_z, "redraw" button, etc.

    proc draw_image {
	all
	window_id
	graph
	nao
	range_nao
	x0
	y0
	xend
	yend
	cvx
	cvy
	old_nao
	{right_margin_without_key 10}
	{right_margin_with_key 60}
    } {
	global Plot_nao::${window_id}::gap_width
	global Plot_nao::${window_id}::key_width
        global Plot_nao::${window_id}::magnification
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
        global Plot_nao::overlay_nao
        global Plot_nao::${window_id}::overlay_palette
        global Plot_nao::${window_id}::main_palette
        global Plot_nao::${window_id}::image_nao
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	global Plot_nao::${window_id}::xflip
	global Plot_nao::${window_id}::yflip

	set nx [[nap "(shape(nao))(-1)"]]
	set ny [[nap "(shape(nao))(-2)"]]
	set nx_old [[nap "(shape(old_nao))(-1)"]]
	set ny_old [[nap "(shape(old_nao))(-2)"]]
	if {$magnification != ""} {
	    set new_width  [expr int($magnification * $nx_old)]
	    set new_height [expr int($magnification * $ny_old)]
	}
	set rank_nao [$nao rank]
	if {$xflip || $yflip} {
	    nap "j = 0 // (nels(cvx) - 1)"
	    nap "j = j(xflip) .. j(!xflip)"
	    set unit [$cvx unit]
	    nap "cvx = cvx(j)"
	    $cvx set unit $unit
	    nap "i = 0 // (nels(cvy) - 1)"
	    nap "i = i(yflip) .. i(!yflip)"
	    set unit [$cvy unit]
	    nap "cvy = cvy(i)"
	    $cvy set unit $unit
	    Plot_nao::incrRefCount $window_id $cvx
	    Plot_nao::incrRefCount $window_id $cvy
	    switch $rank_nao {
		2 {nap "nao = nao(i,j)"}
		3 {nap "nao = nao(,i,j)"}
	    }
	}
	if {$overlay_nao == ""} {
	    set ov ""
	} else {
	    nap "ov = overlay_nao(@@cvy, @@cvx)"
	}
	nap "image_nao = nao"
	$graph axis configure x -max $xend
	$graph axis configure y2 -hide 1
	eval $graph marker delete [$graph marker names]
	set_scaling $window_id $nao $range_nao intercept slope y_0 y_1
	if [[nap "rank_nao == 3  &&  (shape(nao))(0) > 3"]] {
	    nap "nao = nao(0 .. 2, , )"
	}
	configure_ticks $graph x $cvx $new_width
	configure_ticks $graph y $cvy $new_height
	nao2image u $window_id $nao $y_0 $y_1 $slope $intercept $ov
	if {$key_width != ""  &&  $key_width > 0  &&  $rank_nao == 2} {
	    set ncols [[nap "(shape(nao))(1)"]]
	    set x2 [expr "$xend + $gap_width * $ncols / $new_width"]
	    set x3 [expr "$x2   + $key_width * $ncols / $new_width"]
	    $graph axis configure x -max $x3
	    $graph configure -rightmargin $right_margin_with_key
	    configure_width_height $graph [expr $new_width + $gap_width + $key_width] $new_height
	} else {
	    $graph configure -rightmargin $right_margin_without_key
	    configure_width_height $graph $new_width $new_height
	}
	update
	set imageName [image create photo -format NAO -data $u]
	$graph marker create image -image $imageName -coords "$x0 $y0 $xend $yend"
	if {$key_width != ""  &&  $key_width > 0  &&  $rank_nao == 2} {
	    set nrows [[nap "(shape(nao))(0)"]]
	    if {$scalingFrom(0) == ""} {
		set ymin 0
	    } else {
		set ymin [string map {Inf 1nf32} $scalingFrom(0)]
	    }
	    if {$scalingTo(0) == ""} {
		set ymax 255
	    } else {
		set ymax [string map {Inf 1nf32} $scalingTo(0)]
	    }
	    nap "delta = (ymin - ymax) / (nrows - 1f32)"
	    if [[nap "!isnan(delta)  &&  delta != 0"]] {
		nap "cvy2 = ymax .. ymin ... delta"
		Plot_nao::incrRefCount $window_id $cvy2
		nap "key_nao = transpose(reshape(cvy2, key_width // nrows))"
		nao2image u $window_id $key_nao $y_0 $y_1 $slope $intercept
		$graph axis configure y2 -min $yend -max $y0 -ticklength 5 -descending 1 -hide 0
		configure_ticks $graph y2 $cvy2 $new_height
		set imageName [image create photo -format NAO -data $u]
		$graph marker create image -image $imageName -coords "$x2 $y0 $x3 $yend"
	    }
	}
	raise $all
	update
    }


    # configure_width_height --
    #
    # Configure total height & width to give desired screen axis lengths
    # Note that these are pixel counts so height of matrix with 3 rows is 3 not 2.

    proc configure_width_height {
	graph
	xlength
	ylength
    } {
	set xlength [expr int($xlength)]
	set ylength [expr int($ylength)]
	update
	set width_of_screen  [winfo screenwidth  $graph]
	set height_of_screen [winfo screenheight  $graph]
	set borders [expr 2 * ([$graph cget -borderwidth] + [$graph cget -plotborderwidth])]
	#
	set xerror 1; # reasonable 1st estimate
	set plotpadx [$graph cget -plotpadx]
	set plotpadx [expr [lindex $plotpadx 0] + [lindex $plotpadx 1]]
	set margins [expr [$graph extents leftmargin] + [$graph extents rightmargin]]
	set width [expr $xlength + $xerror + $borders + $plotpadx + $margins]
	#
	set yerror 1; # reasonable 1st estimate
	set plotpady [$graph cget -plotpady]
	set plotpady [expr [lindex $plotpady 0] + [lindex $plotpady 1]]
	set margins [expr [$graph extents topmargin] + [$graph extents bottommargin]]
	set height [expr $ylength + $yerror + $borders + $plotpady + $margins]
	#
	# Following iterative process normally converges in loop 0 or loop 1
	for {set count 0} {$count < 9  &&  ($xerror != 0  ||  $yerror != 0)} {incr count} {
	    set width  [expr $width  > $width_of_screen  ? $width_of_screen  : $width]
	    set height [expr $height > $height_of_screen ? $height_of_screen : $height]
	    $graph configure -width $width -height $height
	    update
	    set xerror [expr $xlength - [$graph extents plotwidth]  + $plotpadx]
	    set yerror [expr $ylength - [$graph extents plotheight] + $plotpady]
	    incr width  $xerror
	    incr height $yerror
	}
    }


    # crosshairs_xy --
    #
    # called when pointer moves within xy-plot or barchart

    proc crosshairs_xy {
	all
	window_id
	nao
	graph
	screen_x
	screen_y
    } {
	global Plot_nao::x
	global Plot_nao::y
	global Plot_nao::xyz
        global Plot_nao::${window_id}::xlabel
        global Plot_nao::${window_id}::ylabel
	$graph crosshairs configure -position @$screen_x,$screen_y
	set x [format %0.6g [$graph axis invtransform x $screen_x]]
	set y [format %0.6g [$graph axis invtransform y $screen_y]]
	set xyz "$x $y"
	nap "xlimits = {[$graph axis limits x]}"
	nap "ylimits = {[$graph axis limits y]}"
	if [[nap "prod(x - xlimits) > 0  ||  prod(y - ylimits) > 0"]] {
	    destroy $all.xyz
	} elseif {![winfo exists $all.xyz]} {
	    Plot_nao::create_xyz $all $window_id $graph 0
	}
    }


    # crosshairs_xyz --
    #
    # called when pointer moves within z-plot (image plot)

    proc crosshairs_xyz {
	all
	window_id
	screen_x
	screen_y
    } {
	global Plot_nao::x
	global Plot_nao::y
	global Plot_nao::z
	global Plot_nao::xyz
	global Plot_nao::${window_id}::gap_width
        global Plot_nao::${window_id}::image_nao
	$all.graph crosshairs configure -position @$screen_x,$screen_y
	nap "cvx = coordinate_variable(image_nao,-1)"
	nap "cvy = coordinate_variable(image_nao,-2)"
	nap "xend = nels(cvx) - 1"
	nap "y0   = nels(cvy) - 1"
	nap "j = nint([$all.graph axis invtransform x $screen_x])"
	nap "i = nint([$all.graph axis invtransform y $screen_y])"
	nap "xmax = [$all.graph axis cget x -max]"
	set x [[nap "cvx(j <<< xend)"] -format %0.6g]
	set y [[nap "cvy(i)"] -format %0.6g]
	if [[nap "i < 0  ||  j < 0  ||  i > y0  ||  j > xmax"]] {
	    destroy $all.xyz
	} elseif {![winfo exists $all.xyz]} {
	    Plot_nao::create_xyz $all $window_id $all.graph 1
	}
	if {[$image_nao rank] == 3} {
	    set z [[nap "image_nao(, i, j <<< xend)"] -format %0.6g]
	} else {
	    if [[nap "j < xend + 0.5 * gap_width"]] {
		set z [[nap "image_nao(i, j <<< xend)"] -format %0.6g]
	    } else {
		global Plot_nao::${window_id}::scalingFrom
		global Plot_nao::${window_id}::scalingTo
		if {$scalingFrom(0) == ""} {
		    set zmin 0
		} else {
		    set zmin [string map {Inf 1nf32} $scalingFrom(0)]
		}
		if {$scalingTo(0) == ""} {
		    set zmax 255
		} else {
		    set zmax [string map {Inf 1nf32} $scalingTo(0)]
		}
		set z [[nap "zmax - i * (zmax - zmin) / y0"] -format %0.6g]
	    }
	}
	set xyz "$x $y $z"
    }


    # set_scaling --
    #
    # Set scalingFrom, scalingTo, slope, intercept

    proc set_scaling {
	window_id nao range_nao name_intercept name_slope name_y0 name_y1
    } {
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	upvar $name_intercept intercept
	upvar $name_slope slope
	upvar $name_y0 y0
	upvar $name_y1 y1
	set nlayers [[nap "rank(nao) == 2 ? 1 : (3 <<< (shape(nao))(0))"]]
	nap "tol = 0.01f32";	# tolerance for rounding error
	nap "y0 = tol"
	if {[$nao datatype] == "u8"  &&  [$nao missing] == "(NULL)"} {
	    nap "y1 = 256f32 - tol"
	    if {$range_nao == ""} {
		for {set layer 0} {$layer < $nlayers} {incr layer} {
		    if {$scalingFrom($layer) == ""} {
			set scalingFrom($layer) 0
		    }
		    if {$scalingTo($layer) == ""} {
			set scalingTo($layer) 255
		    }
		}
	    }
	} else {
	    nap "y1 = 255f32 - tol"
	}
	if {$range_nao == ""} {
	    nap "range_nao = reshape(0f32, {0 2})"
	    for {set layer 0} {$range_nao != ""  &&  $layer < $nlayers} {incr layer} {
		if {$scalingFrom($layer) == ""  ||  $scalingTo($layer) == ""} {
		    set range_nao ""
		} else {
		    nap "range_nao = range_nao /// ($scalingFrom($layer) // $scalingTo($layer))"
		}
	    }
	}
	if {$range_nao == ""} {
	    nap "range_nao = nao"
	}
	if [[nap "rank(range_nao) == 0"]] {
	    handle_error "range array is scalar!"
	    return
	}
	nap "same_shape = rank(nao) == rank(range_nao)"
	if [$same_shape] {
	    nap "same_shape = prod(shape(nao) == shape(range_nao))"
	}
	if [[nap "same_shape  &&  rank(nao) == 3"]] {
	    nap "minValue = f32(min(min(range_nao, 2), 1))"
	    nap "maxValue = f32(max(max(range_nao, 2), 1))"
	} elseif [[nap "rank(nao) == 3  &&  rank(range_nao) == 2
		&&  (3 <<< (shape(nao))(0)) == (shape(range_nao))(0)"]] {
	    nap "minValue = f32(min(range_nao, 1))"
	    nap "maxValue = f32(max(range_nao, 1))"
	} elseif [[nap "rank(nao) == 2"]] {
	    nap "range_vector = f32(range(range_nao))"
	    nap "minValue = range_vector(0)"
	    nap "maxValue = range_vector(1)"
	} else {
	    nap "range_vector = f32(range(range_nao))"
	    nap "minValue = (shape(nao))(0) # range_vector(0)"
	    nap "maxValue = (shape(nao))(0) # range_vector(1)"
	}
	set nlayers [$minValue nels]
	if {$nlayers > 3} {
	    set nlayers 3
	    nap "minValue = reshape(minValue, 3)"
	    nap "maxValue = reshape(maxValue, 3)"
	}
	nap "span = maxValue - minValue"
	nap "slope = span == 0f32 ? 1f32 : (y1 - y0) / span"
	nap "slope = min(slope) < max(slope) ? slope : min(slope)"
	nap "intercept = y0 - slope * minValue"
	nap "intercept = min(intercept) < max(intercept) ? intercept : min(intercept)"
	if {[$slope rank] > 0} {
	    nap "s = (shape(nao)){-2 -1}"
	    nap "n = prod(s)"
	    nap "s = nlayers // s"
	    nap "slope = reshape(n # slope, s)"
	    nap "intercept = reshape(n # intercept, s)"
	}
	nap "minValue = reshape(minValue)"
	nap "maxValue = reshape(maxValue)"
	for {set layer 0} {$layer < $nlayers} {incr layer} {
	    set scalingFrom($layer) [[nap "minValue(layer)"]]
	    set scalingTo($layer) [[nap "maxValue(layer)"]]
	}
    }

    # configure_graph --

    proc configure_graph {
	graph
	configure
    } {
	foreach line [split $configure "\n"] {
	    eval "$graph $line"
	}
    }

    # incrRefCount --

    proc incrRefCount {
	window_id
	nao
    } {
	global Plot_nao::${window_id}::save_nao_ids
	$nao set count +1
	lappend save_nao_ids $nao
    }

    # graph2ps --
    #
    # Create postScript

    proc graph2ps {
	window_id
	graph
	paperheight
	paperwidth
	maxpect
    } {
	global Plot_nao::${window_id}::orientation
	switch [string toupper $orientation] {
	    A {set isLandscape [expr [$graph cget -width] > [$graph cget -height]]}
	    P {set isLandscape 0}
	    L {set isLandscape 1}
	}
        $graph postscript output \
                -landscape $isLandscape \
                -maxpect $maxpect  \
                -paperwidth $paperwidth  \
                -paperheight $paperheight 
    }

    # palette3 --
    #
    # nap function to convert palette to standard form with 3 columns
    # If argument has 4 columns then column 0 contains colour index (0 to 255)
    # The three RGB columns normally have values in range 0 to 255.  But if the argument is
    # of type f32 or f64 & the RGB values do not exceed 1.0 then they will be multiplied by 256.
    # Result has type u8 & shape {256 3}. Values range from 0 to 255.
    # Undefined rows are set to {255 255 255}.
    # If error return matrix with shape {0 3}

    proc palette3 {
	palette
    } {
	nap "s = shape(palette)"
	if {[[nap "rank(palette) == 2  &&  s(0) <= 256  &&  s(1) >= 3  &&  s(1) <= 4"]]} {
	    nap "index = (s(1) == 4 ? i32(palette(,0)) : (0 .. (s(0) - 1))) >>> 0 <<< 255"
	    nap "rgb   = palette(,-3 .. -1)"
		# range01 is true (1) if have fractional values from 0.0 to 1.0 rather than whole
		# numbers from 0 to 255
	    nap "range01 = max(max(rgb)) <= 1  &&  [string match f* [$palette datatype]]"
	    nap "rgb = u8(range01 ? (256.0 * rgb >>> 0.0 <<< 255.0) : rgb)"
	    nap "result = {256 # {3 # 255u8}}"
	    $result set value rgb index,
	} else {
	    nap "result = reshape(0u8, {0 3})"
	}
	nap "result"
    }

    # draw_tiles --
    #
    # Plot 3-D NAO as grid of coloured 'tiles' corresponding to levels

    proc draw_tiles {
	all
	window_id
	graph
	nao
	title
	ncols
	sub_title
	range_nao
	want_yflip
    } {
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
        global Plot_nao::${window_id}::want_scaling_widget
	catch "package require Img"
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	frame $graph
	Plot_nao::incrRefCount $window_id $nao
	set nlevels [[nap "(shape(nao))(0)"]]
	set ny [[nap "(shape(nao))(1)"]]
	set nx [[nap "(shape(nao))(2)"]]
	set new_height $ny
	set new_width  $nx
	set_yflip $window_id $want_yflip $nao
	frame $all.scaling_range
	if {$want_scaling_widget} {
	    pack $all.scaling_range -anchor w
	}
	nap "nao2d = reshape(nao, (nlevels * ny) // nx)"
	Plot_nao::incrRefCount $window_id $nao2d
	set color black
	set frame $all.scaling_range.$color
	create_scaling_range $all $window_id $frame $nao2d 0 $color
	set redraw_command [list Plot_nao::redraw_tiles $all $window_id $graph $nao \
		$nlevels $ny $nx $nao2d $title $ncols $sub_title $range_nao]
	create_main_menu $all $window_id $graph $redraw_command $nao
	pack $graph
	eval $redraw_command
    }

    # redraw_tiles --

    proc redraw_tiles {
	all
	window_id
	graph
	nao
	nlevels
	ny
	nx
	nao2d
	title
	ncols
	sub_title
	range_nao
	{tick_length 5}
	{title_height 40}
	{standard_font courier}
	{title_font helvetica}
    } {
	global Plot_nao::${window_id}::gap_height
	global Plot_nao::${window_id}::gap_width
	global Plot_nao::${window_id}::key_width
	global Plot_nao::${window_id}::orientation
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
        global Plot_nao::overlay_nao
	global Plot_nao::${window_id}::print_command
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	global Plot_nao::${window_id}::xflip
	global Plot_nao::${window_id}::yflip
	global Print_gui::paperheight 
	global Print_gui::paperwidth
	set can $graph.can
	destroy $can
	set standard_font "-family $standard_font -size [expr -$gap_height / 2]"
	set title_font "-family $title_font -weight bold -size [expr -$title_height / 3]"
	set_scaling $window_id $nao2d $range_nao intercept slope y0 y1
	nap "axis = scaleAxis($scalingFrom(0), $scalingTo(0), 10)"
	set n_ticks [$axis nels]
	set tmp [split [[nap "reshape(axis, n_ticks // 1)"] value] "\n"]
	for {set k 0} {$k < $n_ticks} {incr k} {
	    lappend axis_text " [lindex $tmp $k] "
	}
	unset tmp
	set axis_text_width [font measure $standard_font [lindex $axis_text 0]]
	nap "j = 0 // (nx - 1)"
	nap "j = i32(nint(ap_n(j(xflip), j(!xflip), nint(new_width))))"
	nap "i = 0 // (ny - 1)"
	nap "i = i32(nint(ap_n(i(yflip), i(!yflip), nint(new_height))))"
	if {$overlay_nao == ""} {
	    set ov ""
	} else {
	    nap "cvy = (coordinate_variable(overlay_nao, 0))(i)"
	    nap "cvx = (coordinate_variable(overlay_nao, 1))(j)"
	    nap "ov = overlay_nao(@@cvy, @@cvx)"
	}
	for {set level 0} {$level < $nlevels} {incr level} {
	    nap "mat = nao(level,i,j)"
	    nao2image u $window_id $mat $y0 $y1 $slope $intercept $ov
	    set img [image create photo -format NAO -data $u]
	    if {$level == 0} {
		# Create canvas & key
		set image_width  "[image width $img]"
		set image_height "[image height $img]"
		if {$ncols == ""} {
		    set paper_ratio [expr double([winfo fpixels . $paperheight]) \
					/ double([winfo fpixels . $paperwidth])]
		    switch [string toupper $orientation] {
			L {set paper_ratio [expr 1.0 / $paper_ratio]}
		    }
		    set dmin 1e9
		    for {set ncols 1} {$ncols <= $nlevels} {incr ncols} {
			set nrows [expr ($nlevels + $ncols - 1) / $ncols]
			set can_height [expr $title_height + $nrows * ($image_height + $gap_height)]
			set can_width  [expr $ncols * ($image_width + $gap_width) + $gap_width]
			if {$key_width > 0} {
			    incr can_width [expr $key_width + $tick_length + $axis_text_width]
			}
			set d [expr abs($paper_ratio - double($can_height) / double($can_width))]
			if {$d < $dmin} {
			    set dmin $d
			    set ncols_min $ncols
			}
		    }
		    set ncols $ncols_min
		}
		set nrows [expr ($nlevels + $ncols - 1) / $ncols]
		set can_height [expr $title_height + $nrows * ($image_height + $gap_height)]
		set can_width  [expr $ncols * ($image_width + $gap_width) + $gap_width]
		if {$key_width > 0} {
		    incr can_width [expr $key_width + $tick_length + $axis_text_width]
		}
		canvas $can -background white -width  $can_width -height $can_height
		if {$key_width > 0} {
		    set key_height [expr ($can_height - $title_height) / 2]
		    nap "key_y = ap_n($scalingTo(0), $scalingFrom(0), key_height)"
		    nap "key = transpose(reshape(key_y, key_width // key_height))"
		    nao2image u $window_id $key $y0 $y1 $slope $intercept
		    set key_img [image create photo -format NAO -data $u]
		    set x [expr $can_width - $tick_length - $axis_text_width]
		    set y [expr $title_height + ($can_height - $title_height - $key_height) / 2]
		    $can create image $x $y -image $key_img -anchor ne
		    set xx [expr $x + $tick_length]
		    for {set k 0} {$k < $n_ticks} {incr k} {
			set yy [[nap "y + (key_y @@ axis(k))"]]
			$can create line $x $yy $xx $yy
			$can create text $can_width $yy -text [lindex $axis_text $k] -anchor e \
				-font $standard_font
		    }
		}
	    }
	    set row [expr $level / $ncols]
	    set col [expr $level % $ncols]
	    set x [expr $gap_width + ($image_width + $gap_width) * $col]
	    set y [expr $title_height + ($image_height + $gap_height) * $row]
	    $can create image $x $y -image $img -anchor nw
	    set x [expr $x + $image_width / 2]
	    set y [expr $y + $image_height + $gap_height * 5 / 12]
	    $can create text $x $y -text [lindex $sub_title $level] -font $standard_font 
	}
	set x [expr $can_width / 2]
	set y [expr $title_height / 2]
	$can create text $x $y -text $title -font $title_font -justify center
	pack $can
	set print_command "::Print_gui::canvas2ps $can 0 $can_height $can_width"
    }

    # nao2image --
    #
    # Produce 3D image NAO from:
    #   - 2D or 3D data NAO (nao) with main palette NAO (main_palette)
    #   - overlay_NAO with overlay_palette

    proc nao2image {
	name_result
	window_id
	nao
	y0
	y1
	slope
	intercept
	{overlay_nao ""}
    } {
        global Plot_nao::${window_id}::main_palette
        global Plot_nao::${window_id}::overlay_palette
	upvar $name_result u
	nap "u = u8((slope * nao + intercept) >>> y0 <<< y1)"
	if {$main_palette != ""  &&  [$nao rank] == 2} {
	    nap "rgb_mat = palette3(main_palette)"
	    if {[$rgb_mat nels] == 0} {
		handle_error "error calling NAP function palette3()"
		return
	    }
	    nap "u = (rgb_mat(,0))(u) /// (rgb_mat(,1))(u) /// (rgb_mat(,2))(u)"
	}
	if {$overlay_nao != ""} {
	    nap "ov_rgb_mat = palette3(overlay_palette)"
	    nap "ip = isPresent(overlay_nao)"
	    if {[$u rank] == 2} {
		nap "u = (ip ? (ov_rgb_mat(,0))(overlay_nao) : u) ///
			 (ip ? (ov_rgb_mat(,1))(overlay_nao) : u) ///
			 (ip ? (ov_rgb_mat(,2))(overlay_nao) : u)"
	    } else {
		nap "n_layers = 3 <<< (shape(u))(0)"
		nap "u = (ip ? (ov_rgb_mat(,0))(overlay_nao) : u(0,,)) ///
			 (ip ? (ov_rgb_mat(,1))(overlay_nao) : u(n_layers-2,,)) ///
			 (ip ? (ov_rgb_mat(,2))(overlay_nao) : u(n_layers-1,,))"
	    }
	}
    }

}
