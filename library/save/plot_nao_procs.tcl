# plot_nao_procs.tcl --
# 
# Copyright (c) 2000, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: plot_nao_procs.tcl,v 1.84 2003/09/09 09:16:50 dav480 Exp $
#
# Produce xy-graph, barchart (histogram), z-plot (image) or tiled-plot (multiple images).
#
# Usage
#   See variable help_usage below

namespace eval Plot_nao {

	# Following variables do not need namespace for each graph window
    variable frame_id 0;	# Number of previous graphs created
    variable help_intro \
	    "Produce one of following four types of plot:\
	    \n  xy-graph: One or more curves defined by x and y coordinates\
	    \n  barchart: Histogram defined by x and y coordinates\
	    \n  z-plot: Image defined by z values in matrix (or 3D array)\
	    \n  tiled-plot: Page of tiles (each tile is z-plot) defined by 3D array\
	    \n\
	    \nA z-plot or tiled-plot is produced using the graph image-marker facility."
    variable help_all "$help_intro\
	    \n\
	    \nUsage\
	    \n  plot_nao <NAP expression> ?options?\
	    \nOptions are:\
	    \n  -barwidth <float>: (bar chart only) width of bars in x-coordinate units.\
	    \n     (Default: 1.0)\
	    \n  -buttonCommand <script>: executed when button pressed with z-plots (Default:\
	    \n     \"lappend Plot_nao::\${window_id}::save \[set Plot_nao::\${window_id}::xyz]\")\
	    \n  -colors <list>: Colors of xy-graph lines. (Default: black red\
	    \n     green blue yellow orange purple grey aquamarine beige)\
	    \n  -dash <list>: Dash patterns of xy-graph lines. (Default: \"\" i.e. all full lines)\
	    \n     Each element is \"\" for full line, \" \" for no line or standard dash pattern\
	    \n  -columns <int>: (tiled-plot only) number of columns of tiles on page\
	    \n  -filename <string>: Name of output PostScript file.\
	    \n  -fill <0 or 1>: 1 = Scale PostScript to fill page. (Default: 0)\
	    \n  -gap_height <int>: height (pixels) of horizontal white gaps (Default: 20)\
	    \n  -gap_width  <int>: width  (pixels) of  vertical  white gaps (Default: 20)\
	    \n  -geometry <string>: If specified then use to create new toplevel window.\
	    \n  -height <int>: Desired height (screen units)\
	    \n     Type xy/bar: Height of whole window (Default: automatic)\
	    \n     Type z: Image height (can be \"min max\") (Default: NAO dim if within limits)\
	    \n     Type tiled: Not used\
	    \n  -help: Display this help page\
	    \n  -key <int>: width (pixels) of image-key. No key if 0 or blank. (Default: 30)\
	    \n  -labels <list>: Labels of xy-graph lines. (Default: Use names i.e. y0, y1, y2, ...)\
	    \n  -menu <0 or 1>: 0 = Start with menu bar at top hidden. (Default: 1)\
	    \n  -orientation <P, L or A>: P = portrait, L = landscape, A = automatic (Default: A)\
	    \n  -overlay <C, L, S, N or \"E <nap expression>\">: Define overlay.\
	    \n     C = coast, L = land, S = sea, N = none, A = auto, E = expr (Default: A)\
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
	    \n      Do recursive call to plot_nao for each sub-array of this rank\
	    \n  -scaling <0 or 1>: 0 = Start with scaling widget hidden. (Default: 1)\
	    \n  -sub_title <list>: (tiled-plot only) Title of each tile\
	    \n  -symbols <list>: One for each xy-graph line. Draw at points. Can be plus, square,\
	    \n     circle, cross, splus, scross, triangle (Default: \"\" i.e. none)\
	    \n  -title <string>: title (Default: NAO label (if any) else <NAP expression>)\
	    \n  -type <string> plot-type (\"bar\", \"tile\", \"xy\" or \"z\")\
	    \n     If rank is 1 then default type is \"xy\".\
	    \n     If rank is 2 and n_rows <= 8 then default type is \"xy\".\
	    \n     If rank is 2 and n_rows  > 8 then default type is \"z\".\
	    \n     If rank is 3 then default type is \"z\".\
	    \n  -width <int>: Desired width (screen units)\
	    \n     Type xy/bar: Width of whole window (Default: automatic)\
	    \n     Type z: Image width (can be \"min max\") (Default: NAO dim if within limits)\
	    \n     Type tiled: Not used\
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
	    \n  plot_nao sales -labels \"Joe Mary\" -type bar"
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
	if [catch "uplevel 2 [list nap "{$nao_expr}"]" nao] {
	    if {$nao_expr == ""  ||  [regexp -nocase {^-h} $nao_expr]} {
		puts $::Plot_nao::help_all
	    } else {
		handle_error $nao
	    }
	    return
	}
	nap "nao = pad(nao)"
	if {[$nao rank] == 0} {
	    handle_error "Value is scalar"
	    return
	}
	catch "package require Img"
	::Print_gui::init
	nap "shape_nao = shape(nao)"
	if [[nap "rank(nao) == 3  &&  shape_nao(0) == 1"]] {
	    nap "nao = nao(0,,)"
	    nap "shape_nao = shape(nao)"
	}
	set window_id "win$Plot_nao::frame_id"
	    # Following variables exist in namespace for each graph window
	namespace eval ${window_id} {
	    variable allow_scroll 0;	# Use scrolling if oversize? (Otherwise compress.)
	    variable auto_print 0;	# automatic printing? Useful for batch processing
	    variable auto_redraw 1;	# automatic redraw (after changing relevant parameters)?
	    variable call_level "#[expr [info level]-3]"; # stack level from which plot_nao called
	    variable font_standard "courier 10";
	    variable font_title    "courier 16";
	    variable gap_height 20;	# height (pixels) of horizontal white space between tiles
	    variable gap_width  20;	# width (pixels) of vertical white space
	    variable histograms "";	# List of histogram IDs (so can destroy at end)
	    variable image_nao "";	# Image NAO after any inversion
	    variable key_width 30;	# width (pixels) of image key
	    variable magnification "";	# magnification factor (relative to original NAO)
	    variable max_canvas_height ""; # max height (pixels) of canvas ("" = maximise)
	    variable max_canvas_width  ""; # max width  (pixels) of canvas ("" = maximise)
	    variable new_height -1;	# current image height
	    variable new_width -1;	# current image width
	    variable orientation "A";	# P = portrait, L = landscape, A = automatic
	    variable overlay_nao "";	# overlay (e.g. coastline)
	    variable image_format gif;	# format of output image file
	    variable overlay_option A;	# C = coast, L = land, S = sea, N = none, A = auto, E = expr
	    variable overlay_palette;	# NAO defining color mapping for overlay (e.g. coastline)
	    variable oversize_prompt 1;	# Prompt if image is bigger than screen?
	    variable main_palette "";	# NAO defining color mapping for 2D images
	    variable mapping "";	# NAO mapping to image
	    variable percentileFrom;	# Used to define scalingFrom
	    variable percentileTo;	# Used to define scalingTo
	    variable print_command "";	# 
	    variable save "";		# Used to save crosshair data
	    variable save_nao_ids "";	# List of nao ids to be saved until end.
	    variable scalingFrom;	# Used to scale z plots (array)
	    variable scalingFromIsNext;	# 0: scalingTo next, 1: scalingFrom next (array)
	    variable scalingFromTitle;	# Histogram title when scalingFromIsNext == 1
	    variable scalingTo;		# Used to scale z plots (array)
	    variable scalingToTitle;	# Histogram title when scalingFromIsNext == 0
	    for {set layer 0} {$layer < 3} {incr layer} {
		set percentileFrom($layer) 0
		set percentileTo($layer) 100
		set scalingFrom($layer) ""
		set scalingFromIsNext($layer) 1
		set scalingTo($layer) ""
	    }
	    variable plot_type "";	# "bar", "tile", "xy" or "z"
	    variable want_menu_bar 1;	# Display menu bar at top?
	    variable want_scaling_widget 1;	# Display scaling widget?
	    variable xflip 0;		# 1 = flip image left-right
	    variable xlabel "";
	    variable yflip 0;		# 1 = flip image upside down
	    variable ylabel "";
		# set default overlay_palette  to {black white red green blue}
	    nap "overlay_palette = f32{{3#0}{3#1}{1 0 0}{0 1 0}{0 0 1}}";
	}
	    # Make these available locally without namespace prefix
	foreach var [info vars ::Plot_nao::${window_id}::*] {
	    global $var
	}
	    # set default main_palette to "blue to red"
	Plot_nao::palette_interpolate main_palette $window_id 240 0
	set barwidth 1.0
	set buttonCommand "lappend Plot_nao::$window_id\::save \$Plot_nao::xyz"
	set colors "black red green blue yellow orange purple grey aquamarine beige"
	set dash_patterns ""
	set geometry ""
	set height "";			# height (in pixels) of image (can be "min max" for image)
	set labels ""
	set major_tick_length 6
	set ncols ""
	set parent ""
	set range_nao ""
	set rank_nao 3
	set symbols ""
	set type "";			# "bar", "tile", "xy" or "z" (copy to plot_type)
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
	proc palette_option {name expr} "Plot_nao::set_palette \$name $window_id \$expr"
	set str [lindex $dim_names end]
	if {$str ne "(NULL)"} {
	    if {[$nao rank] == 1} {
		set cv [$nao coord]
		if {$cv eq "(NULL)"} {
		    set str ""
		} else {
		    set xunit [fix_unit [$cv unit]]
		    if {$xunit ne ""  &&  $xunit ne "degrees_east"} {
			append str " ($xunit)"
		    }
		}
	    }
	    set xlabel $str
	}
	set str [lindex $dim_names end-1]
	if {$str ne "(NULL)"} {
	    set ylabel $str
	}
	unset str
	set ::Print_gui::filename ""
	set i [process_options {
		{-barwidth {set barwidth $option_value}}
		{-buttonCommand {set buttonCommand $option_value}}
		{-colors {set colors $option_value}}
		{-columns	{set ncols $option_value}}
		{-dash {set dash_patterns $option_value}}
		{-filename {set ::Print_gui::filename $option_value}}
		{-fill {set ::Print_gui::maxpect $option_value}}
		{-font_standard {set font_standard $option_value}}
		{-font_title {set font_title $option_value}}
		{-gap_height {set gap_height $option_value}}
		{-gap_width  {set gap_width  $option_value}}
		{-geometry {set geometry $option_value}}
		{-height {set height $option_value}}
		{-help {puts $::Plot_nao::help_all}}
		{-key {set key_width $option_value}}
		{-labels {set labels $option_value}}
		{-menu {set want_menu_bar $option_value}}
		{-orientation {set orientation $option_value}}
		{-overlay {set overlay_option $option_value}}
		{-oversize_prompt {set oversize_prompt $option_value}}
		{-ovpal   {palette_option overlay_palette $option_value}}
		{-palette {palette_option main_palette    $option_value}}
		{-paperheight {set ::Print_gui::paperheight $option_value}}
		{-paperwidth {set ::Print_gui::paperwidth $option_value}}
		{-parent {set parent $option_value}}
		{-print {set auto_print $option_value}}
		{-printer {set ::Print_gui::printer_name $option_value}}
		{-range {nap "range_nao = [uplevel 3 "nap \"$option_value\""]"}}
		{-rank  {nap "rank_nao  = [uplevel 3 "nap \"$option_value\""]"}}
		{-scaling {set want_scaling_widget $option_value}}
		{-sub_title {set sub_title $option_value}}
		{-symbols {set symbols $option_value}}
		{-title {set title $option_value}}
		{-type {set type $option_value}}
		{-width {set width $option_value}}
		{-xflip {set xflip $option_value}}
		{-xlabel {set xlabel $option_value}}
		{-yflip {set want_yflip $option_value}}
		{-ylabel {set ylabel $option_value}}
	    } $args]
	if {$i != [llength $args]} {
	    handle_error "Illegal option"
	    return
	}
	if {$::Print_gui::filename eq ""  &&  !$auto_print} {
	    set ::Print_gui::filename tmp.ps
	}
	Plot_nao::incrRefCount $window_id $nao
	set rank_nao [[nap "i32(rank_nao <<< rank(nao))"]]
	nap "shape_frame = (shape(nao))(0 .. (rank(nao) - rank_nao - 1) ... 1)"
	set nplots [[nap "prod(shape_frame)"]]
	if {$nplots > 1} {
	    if {$geometry == ""} {
		set geometry "+[winfo rootx .]+[winfo rooty .]"
	    }
	    if {$range_nao == ""} {
		nap "range_nao = range(nao)"
	    }
	    set all ""
	    set cv0 [$nao coord 0]
	    for {set i 0} {$i < $nplots} {incr i} {
		nap "tmp = (mixed_base(i, shape_frame))(1 .. nels(shape_frame) ... 1)"
		set cell_subscript "[$tmp value -format "%g,"][commas "$rank_nao-1"]"
		nap "cell = nao(cell_subscript)"
		if {$cv0 eq "(NULL)"} {
		    set cell_title "{$title\n($cell_subscript)}"
		} else {
		    set cell_title "{$title\n(@[[nap "cv0(tmp)"]])}"
		}
		unset tmp
		lappend all [eval Plot_nao::plot_nao $cell $args \
			-geometry $geometry \
			-oversize_prompt [expr "$i == 0"] \
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
	    set main $all.main
	    frame $main
	    set graph $main.canvas
	    canvas $graph -background white
	    pack $main -side left -expand 1 -fill both
	    $graph configure -xscrollcommand [list $main.xscroll set]
	    $graph configure -yscrollcommand [list $main.yscroll set]
	    scrollbar $main.xscroll -orient horizontal -command [list $graph xview]
	    scrollbar $main.yscroll -orient vertical   -command [list $graph yview]
	    grid $graph $main.yscroll -sticky news
	    grid $main.xscroll -sticky ew
	    grid rowconfigure $main 0 -weight 1
	    grid columnconfigure $main 0 -weight 1
	    grid remove $main.xscroll $main.yscroll
	    set print_command "::Print_gui::canvas2ps $graph 0 0 0"
	    switch -glob $type {
		b* {
		    set plot_type bar
		    Plot_nao::draw_xy $all $window_id $graph $nao $title $range_nao $height $width \
			    $colors $labels $symbols $dash_patterns $barwidth $major_tick_length
		}
		t* {
		    set plot_type tile
		    Plot_nao::draw_tiles   $all $window_id $graph $nao $title \
			    $ncols $sub_title $range_nao $want_yflip
		}
		x* {
		    set plot_type xy
		    Plot_nao::draw_xy $all $window_id $graph $nao $title $range_nao $height $width \
			    $colors $labels $symbols $dash_patterns 0 $major_tick_length
		}
		z  {
		    set plot_type z
		    Plot_nao::draw_z  $all $window_id $graph $nao $title $height $width \
			    $range_nao $buttonCommand $want_yflip $major_tick_length
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

    # check_cvs --
    # Check that xcv & ycv are monotonically ascending or descending.
    # If so (OK) return 0, else (error) return 1.

    proc check_cvs {
	nao
    } {
	foreach cv [lrange [$nao coord] end-1 end] {
	    if {![string equal $cv (NULL)]} {
		if {[string equal [$cv step] +-]} {
		    return 1
		}
	    }
	}
	return 0
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
	    toplevel $all -background white
            update idletasks
	    wm geometry $all $geometry
	    wm title $all "plot_nao  $all"
	} else {
	    frame $all -background white
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
	if {$redraw_command eq ""} {
	    set cond_redraw_command ""
	} else {
	    button $m.redraw -text redraw -command $redraw_command
	    pack $m.redraw -side left -expand 1 -fill both
	    set name ::Plot_nao::${window_id}::auto_redraw
	    set cond_redraw_command [list if $$name $redraw_command]
	}
	menubutton $m.options -text options -menu $m.options.options_menu -relief raised
	button $m.cancel -text cancel -command "destroy $all"
	menubutton $m.help -text help -menu $m.help.help_menu -relief raised
	pack $m.options $m.cancel $m.help -side left -expand 1 -fill both
	pack $m -fill x -before $all.main -anchor n
	if {!$want_menu_bar} {
	    pack forget $m
	}
	create_options_menu $all $m.options $window_id $graph \
		$cond_redraw_command $redraw_command $nao
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
	create_options_menu $all $m $window_id $graph $cond_redraw_command $redraw_command
	create_help_menu $m
    }


    # create_options_menu --

    proc create_options_menu {
	all
	parent
	window_id
	graph
	{cond_redraw_command ""}
	{redraw_command ""}
	{nao ""}
    } {
	global Plot_nao::${window_id}::plot_type
	set options_menu $parent.options_menu
	menu $options_menu
	$options_menu add checkbutton -label "display menu-bar?" \
		-variable Plot_nao::${window_id}::want_menu_bar \
		-command [list Plot_nao::toggle_menu_bar $all $window_id]
	if {[lsearch "z" $plot_type] >= 0} {
	    $options_menu add checkbutton -label "display scaling widget?" \
		    -variable Plot_nao::${window_id}::want_scaling_widget \
		    -command [list Plot_nao::toggle_scaling $all $window_id]
	}
	$options_menu add checkbutton -label "automatic redraw?" \
		-variable Plot_nao::${window_id}::auto_redraw
	if {[lsearch "z" $plot_type] >= 0} {
	    $options_menu add checkbutton -label "flip left-right?" \
		    -variable Plot_nao::${window_id}::xflip \
		    -command $cond_redraw_command
	    $options_menu add checkbutton -label "flip upside down?" \
		    -variable Plot_nao::${window_id}::yflip \
		    -command $cond_redraw_command
	}
	$options_menu add checkbutton -label "allow scrolling?" \
		-variable Plot_nao::${window_id}::allow_scroll \
		-command $cond_redraw_command
	if {[lsearch "tile z" $plot_type] >= 0} {
	    #
	    $options_menu add cascade -label "define main palette" \
		    -menu $options_menu.main_palette
	    create_palette_menu main_palette $all $options_menu $window_id \
		    $cond_redraw_command $redraw_command
	    #
	    $options_menu add cascade -label "define overlay (eg coasts)" \
		    -menu $options_menu.overlay
	    create_overlay_menu $all $options_menu $window_id $cond_redraw_command \
		    $redraw_command $nao
	}
	if {[lsearch "tile" $plot_type] >= 0} {
	    $options_menu add cascade -label "page orientation" -menu $options_menu.orientation
	    create_orientation_menu $all $options_menu $window_id
	}
	$options_menu add cascade -label "adjust various sizes" -menu $options_menu.size
	create_size_menu $all $options_menu $window_id $cond_redraw_command
	#
	$options_menu add cascade -label "select fonts" -menu $options_menu.font
	create_font_menu $all $options_menu $window_id $cond_redraw_command
	#
	$options_menu add command -label print \
		-command [list Print_gui::widget \$Plot_nao::${window_id}::print_command $all]
	#
	$options_menu add command -label "write image file" \
		-command [list Plot_nao::write_image $window_id $all $graph]
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
	cond_redraw_command
    } {
	set m $options_menu.size
	menu $m
	set command "set Plot_nao::${window_id}::new_width"
	append command { [get_entry "width of image in pixels"}
	append command " -parent $all -text \$Plot_nao::${window_id}::new_width]"
	append command "; set Plot_nao::${window_id}::magnification {}"
	append command "; $cond_redraw_command"
	$m add command -label "adjust width of image" -command $command
	#
	set command "set Plot_nao::${window_id}::new_height"
	append command { [get_entry "height of image in pixels"}
	append command " -parent $all -text \$Plot_nao::${window_id}::new_height]"
	append command "; set Plot_nao::${window_id}::magnification {}"
	append command "; $cond_redraw_command"
	$m add command -label "adjust height of image" -command $command
	#
	set name ::Plot_nao::${window_id}::magnification
	set command "set $name"
	append command { [get_entry "magnification factor (relative to original NAO)"}
	append command " -parent $all -text \[expr {$$name eq \"\" ? 1 : $$name}]]"
	append command "; $cond_redraw_command"
	$m add command -label "adjust height & width of image" -command $command
	#
	set command "set Plot_nao::${window_id}::key_width"
	append command { [get_entry "width of key in pixels (no key if blank)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::key_width]"
	append command "; $cond_redraw_command"
	$m add command -label "adjust width of key" -command $command
	#
	set command "set Plot_nao::${window_id}::gap_width"
	append command { [get_entry "width of vertical gaps (pixels)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::gap_width]"
	append command "; $cond_redraw_command"
	$m add command -label "adjust width of vertical gaps" -command $command
	#
	set command "set Plot_nao::${window_id}::gap_height"
	append command { [get_entry "height of horizontal gaps (pixels)"}
	append command " -parent $all -text \$Plot_nao::${window_id}::gap_height]"
	append command "; $cond_redraw_command"
	$m add command -label "adjust height of horizontal gaps" -command $command
    }


    # create_font_menu --

    proc create_font_menu {
	all
	options_menu
	window_id
	cond_redraw_command
    } {
	set m $options_menu.font
	menu $m
	#
	set label "standard font (axes, etc.)"
	set varname ::Plot_nao::${window_id}::font_standard
	set command "[list select_font $all $label $varname]; $cond_redraw_command"
	$m add command -label $label -command $command
	#
	set label "title font (top of page)"
	set varname ::Plot_nao::${window_id}::font_title
	set command "[list select_font $all $label $varname]; $cond_redraw_command"
	$m add command -label $label -command $command
    }


    # create_palette_menu --

    proc create_palette_menu {
	name
	all
	parent
	window_id
	cond_redraw_command
	redraw_command
    } {
	set palette_menu $parent.$name
	menu $palette_menu
	$palette_menu add command -label "black to white" \
		-command "Plot_nao::set_palette $name $window_id {}; $cond_redraw_command"
	$palette_menu add command -label "white to black" \
		-command "Plot_nao::set_palette $name $window_id \
			\"transpose(reshape(255 .. 0 ... -1, 3 // 256))\"; $cond_redraw_command"
	$palette_menu add command -label "blue to red (white = missing)" -command \
		"Plot_nao::palette_interpolate $name $window_id 240 0; $cond_redraw_command"
	$palette_menu add command -label "red to blue (white = missing)" -command \
		"Plot_nao::palette_interpolate $name $window_id 0 240; $cond_redraw_command"
	$palette_menu add command -label "green to red (white = missing)" -command \
		"Plot_nao::palette_interpolate $name $window_id -240 0; $cond_redraw_command"
	$palette_menu add command -label "red to green (white = missing)" -command \
		"Plot_nao::palette_interpolate $name $window_id 0 -240; $cond_redraw_command"
	$palette_menu add command \
		-label "default overlay palette: 0=black, 1=white, 2=red, 3=green, 4=blue" \
		-command "nap \"::Plot_nao::${window_id}::overlay_palette =
			f32{{3#0}{3#1}{1 0 0}{0 1 0}{0 0 1}}\"; $cond_redraw_command"
	$palette_menu add command -label "define palette using 'pal' GUI" \
		-command [list pal ::Plot_nao::${window_id}::$name $redraw_command]
	$palette_menu add command -label "define palette using NAP expression" \
		-command "Plot_nao::palette_nap $name $all $window_id; $cond_redraw_command"
	$palette_menu add command -label "read palette from text file" \
		-command "Plot_nao::palette_file $name $all $window_id; $cond_redraw_command"
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
	cond_redraw_command
	redraw_command
	nao
    } {
	set m $parent.overlay
	menu $m
	$m add command -label "set overlay NAO coast values to 0" \
		-command "set ::Plot_nao::${window_id}::overlay_option C; $cond_redraw_command"
	#
	$m add command -label "set overlay NAO land values to 2" \
		-command "set ::Plot_nao::${window_id}::overlay_option L; $cond_redraw_command"
	#
	$m add command -label "set overlay NAO sea values to 4" \
		-command "set ::Plot_nao::${window_id}::overlay_option S; $cond_redraw_command"
	#
	$m add command -label "set overlay NAO using NAP expression" \
		-command "set ::Plot_nao::${window_id}::overlay_option E; \
			::Plot_nao::overlay_nap $all $window_id; $cond_redraw_command"
	#
	$m add command -label "clear overlay NAO" \
		-command "set ::Plot_nao::${window_id}::overlay_option N; $cond_redraw_command"
	#
	$m add separator
	#
	$m add cascade -label "define overlay palette" -menu $m.overlay_palette
	create_palette_menu overlay_palette $all $m $window_id $cond_redraw_command $redraw_command
    }


    # write_image --
    # write canvas to image file

    proc write_image {
	window_id
	all
	graph
    } {
	global Plot_nao::${window_id}::image_format
	if [catch {image create photo -format window -data $graph} img] {
	    handle_error "error creating image"
	    return
	}
	set formats "ppm pgm gif"
	if {[catch "package require Img"] == 0} {
	    lappend formats bmp xbm xpm png jpeg tiff
	}
	set formats [lsort $formats]
	set top .image_tmp_top
	toplevel $top
	wm geometry $top "+[winfo x $all]+[winfo y $all]"
	wm title $top "Select format"
	label $top.label -text "Select format of output image file"
	pack $top.label
	foreach fmt $formats {
	    radiobutton $top.$fmt -text $fmt -value $fmt \
		    -variable ::Plot_nao::${window_id}::image_format
	    pack $top.$fmt -anchor w
	}
	button $top.ok -text OK -command "destroy $top"
	pack $top.ok
	tkwait window $top
	set filename "plot.$image_format"
	set filename [tk_getSaveFile -initialfile $filename -title "Image Filename"]
	if {$filename ne ""} {
	    if [catch "$img write $filename -format $image_format" msg] {
		handle_error "Error writing image file $filename\n$msg"
	    }
	}
    }


    # overlay_land_flag --

    proc overlay_land_flag {
	window_id
	func
	value
	nao
    } {
	global Plot_nao::${window_id}::overlay_nao
	nap "longitude = coordinate_variable(nao, -1)"
	nap "latitude  = coordinate_variable(nao, -2)"
	if {$overlay_nao == ""  ||
		[[nap "! prod((shape overlay_nao){-2 -1} == (shape nao){-2 -1})"]]} {
	    nap "overlay_nao = 255u8"
	    $overlay_nao set missing 255
	}
	if [catch "nap overlay_nao = ${func}(latitude,longitude)?u8(value):overlay_nao" result] {
	    puts "overlay_land_flag: Error defining overlay"
	    nap "overlay_nao = reshape(255u8, nels(latitude) // nels(longitude))"
	}
	$overlay_nao set missing 255
	$overlay_nao set coo latitude longitude
    }


    # create_help_menu --

    proc create_help_menu {
	parent
    } {
	set help_menu $parent.help_menu
	menu $help_menu -tearoff 0
	$help_menu add command -label introduction -command \
		{message_window $::Plot_nao::help_intro -geometry +0+0 -parent ""}
	$help_menu add command -label usage -command \
		{message_window $::Plot_nao::help_all -geometry +0+0 -parent "" -width 90}
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
	    pack $m -before [lindex [pack slaves $all] 0] -fill x -anchor n
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
	    pack $all.scaling_range -before $all.main -anchor n -fill x
	} else {
	    pack forget $all.scaling_range
	}
	update idletasks
    }


    # create_scaling_range --
    #
    # Create "histogram menu" button & entry widgets for min & max values defining
    # scaling for z plots

    proc create_scaling_range {
	all
	window_id
	frame
	nao
	layer
	color
	redraw_command
    } {
	destroy $frame
	frame $frame -relief ridge -borderwidth 3
	set menu $frame.histogram.menu 
	menubutton $frame.histogram -text "histogram menu" -pady 0.3m -relief raised -menu $menu
	menu $menu -tearoff 0
	$menu add command -label "Display histogram" -command \
	    [list Plot_nao::plot_histogram $all $window_id $nao $layer $color $redraw_command]
	$menu add command -label "Display ogive" -command \
	    [list Plot_nao::plot_ogive $all $window_id $nao $layer $color $redraw_command]
	$menu add command -label "Trim tails of histogram" -command \
	    [list Plot_nao::trim_histogram $all $window_id $nao $layer $color $redraw_command]
	$menu add command -label "Equalise histogram" -command \
	    [list Plot_nao::equalise_histogram $all $window_id $nao $layer $color $redraw_command]
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
	pack $frame -anchor w -fill x -expand 1
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
	set_overlay $window_id $expr
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
	set n ::Plot_nao::${window_id}::$name
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
	nap "mat = transpose(hsv2rgb(h /// s // v))"
	nap "white = 3 # 1f32"
	nap "::Plot_nao::${window_id}::$name = u8(255.999f32 * (mat // white))"
    }


    # set_overlay --
    #
    # Define overlay_nao.
    # If overlay_option is "none" then set overlay_nao to "".
    # If overlay_option is "coast", "land" or "sea" then set overlay_nao using "land_flag", using
    #   coordinate vars of <nao> for latitude & longitude.
    # If overlay_option is "auto" then treat as "coast" if cv units are geographic
    # If overlay_option is "expr" then set overlay_nao using NAP expression specified by <nao>.
    #    This expression is evaluated in caller's namespace.
    # overlay_option can be abbreviated to 1st letter.

    proc set_overlay {
	window_id
	nao
    } {
	global Plot_nao::${window_id}::call_level
	global Plot_nao::${window_id}::overlay_nao
	global Plot_nao::${window_id}::overlay_option
	switch [string toupper [string index $overlay_option 0]] {
	    N	{set overlay_nao ""}
	    C	{overlay_land_flag $window_id is_coast 0 $nao}
	    L	{overlay_land_flag $window_id is_land  2 $nao}
	    S	{overlay_land_flag $window_id !is_land 4 $nao}
	    A	{
		set unit_x [fix_unit [[nap "coordinate_variable(nao,-1)"] unit]]
		set unit_y [fix_unit [[nap "coordinate_variable(nao,-2)"] unit]]
		if {$unit_x eq "degrees_east"  &&  $unit_y eq "degrees_north"} {
		    overlay_land_flag $window_id is_coast 0 $nao
		} else {
		    set overlay_nao ""
		}
	    }
	    E	{
		if [catch "uplevel $call_level \
			    nap \"::Plot_nao::${window_id}::overlay_nao = $nao\"" result] {
		    handle_error $result
		}
	    }
	}
	if {$overlay_nao != ""} {
	    # If overlay_nao is boxed (polyline) then convert to overlay matrix
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
	    } else {
		nap "cvx = coordinate_variable(overlay_nao,-1)"
		nap "cvy = coordinate_variable(overlay_nao,-2)"
		if {[fix_unit [$cvx unit]] == "degrees_east"} {
		    nap "cvx = fix_longitude(cvx)"
		}
		$overlay_nao set coord $cvy $cvx
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
	color
	redraw_command
	{n 100}
	{height 250}
	{width  300}
    } {
	global Plot_nao::${window_id}::histograms
	global Plot_nao::${window_id}::scalingFromTitle
	global Plot_nao::${window_id}::scalingToTitle
	set main $all.main
	set geometry +[winfo rootx $main]+[winfo rooty $main]
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
	nap "f = define_histogram(data, 0, n)"
	nap "tmp = coordinate_variable(f)"
	nap "delta = tmp(1) - tmp(0)"
	set buttonCommand \
		"Plot_nao::histogram_button_command $window_id $layer [llength $histograms]"
	set histogram [::Plot_nao::plot_nao $f \
		-barwidth [$delta] \
		-buttonCommand $buttonCommand \
		-colors $color \
		-geometry $geometry \
		-height $height \
		-title $scalingFromTitle \
		-type bar \
		-width $width \
	]
	lappend histograms $histogram
    }


    # plot_ogive --
    #
    # Plot ogive (relative cumulative frequencies)

    proc plot_ogive {
	all
	window_id
	nao
	layer
	color
	redraw_command
	{n 100}
	{height 250}
	{width  300}
    } {
	global Plot_nao::${window_id}::histograms
	global Plot_nao::${window_id}::scalingFromTitle
	global Plot_nao::${window_id}::scalingToTitle
	set main $all.main
	set geometry +[winfo rootx $main]+[winfo rooty $main]
	if [[nap "rank(nao) == 3"]] {
	    set text "Ogive of layer $layer"
	    nap "data = f32(nao(layer,,))"
	} else {
	    set text "Ogive"
	    nap "data = f32(nao)"
	}
	set scalingFromTitle "$text\nLeft click to set 'from' value"
	set scalingToTitle "$text\nLeft click to set 'to' value"
	set color [color_of_layer $nao $layer]
	nap "f = define_histogram(data, 0, n)"
	nap "tmp = coordinate_variable(f)"
	nap "delta = tmp(1) - tmp(0)"
	nap "rcf = 100f32 * psum(f) / sum(f)"
	$rcf set coo $tmp
	set buttonCommand \
		"Plot_nao::histogram_button_command $window_id $layer [llength $histograms]"
	set ogive [::Plot_nao::plot_nao $rcf \
		-buttonCommand $buttonCommand \
		-colors $color \
		-geometry $geometry \
		-height $height \
		-title $scalingFromTitle \
		-width $width \
		-ylabel "percentile" \
	]
	lappend histograms $ogive
    }


    # trim_histogram --
    #
    # Adjust scalingFrom & scalingTo to specified percentiles

    proc trim_histogram {
	all
	window_id
	nao
	layer
	color
	redraw_command
	{top .trimTop}
    } {
	destroy $top
	toplevel $top
	wm geometry $top "+[winfo x $all]+[winfo y $all]"
	wm title $top "Trim Histogram"
	set frame $top.trim
	frame $frame -relief ridge -borderwidth 3
	label $frame.from -text "Scale from percentile"
	spinbox $frame.from_entry -relief sunken -width 10 -from 0 -to 100 \
		-validate all -vcmd "Plot_nao::validate_percentile %P" \
		-textvariable Plot_nao::${window_id}::percentileFrom($layer)
	label $frame.to -text "to percentile"
	spinbox $frame.to_entry -relief sunken -width 10 -from 0 -to 100 \
		-validate all -vcmd "Plot_nao::validate_percentile %P" \
		-textvariable Plot_nao::${window_id}::percentileTo($layer)
	pack $frame.from $frame.from_entry $frame.to $frame.to_entry \
		-side left -anchor w -fill y
	if {$color != "black"} {
	    $frame configure -background $color
	}
	set buttons $top.buttons
	frame $buttons
	set command "destroy $top; \
		[list Plot_nao::trim_histogram_ok $window_id $layer $nao $redraw_command]"
	bind $top <Return> $command
	button $buttons.ok -text OK -command $command
	button $buttons.cancel -text Cancel -command "destroy $top"
	pack $buttons.ok $buttons.cancel -side left -fill x -expand 1
	pack $frame $buttons -anchor w -fill x -expand 1
    }


    # validate_percentile --

    proc validate_percentile {
	percentile
    } {
	if {$percentile eq ""} {
	    return 1
	}
	return [expr [string is double $percentile]  &&  $percentile >= 0  &&  $percentile <= 100]
    }


    # trim_histogram_ok --
    #
    # called by trim_histogram as command when user presses "OK'

    proc trim_histogram_ok {
	window_id
	layer
	nao
	redraw_command
    } {
	global Plot_nao::${window_id}::auto_redraw
	global Plot_nao::${window_id}::percentileFrom
	global Plot_nao::${window_id}::percentileTo
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	if {$percentileFrom($layer) eq ""} {
	    set percentileFrom($layer) 0
	}
	if {$percentileTo($layer) eq ""} {
	    set percentileTo($layer) 0
	}
	if [[nap "rank(nao) == 3"]] {
	    nap "data = f32(nao(layer,,))"
	} else {
	    nap "data = f32(nao)"
	}
	nap "f = f32(define_histogram(data))"
	nap "rcf = psum(f) / sum(f)"
	set tmp [expr 0.01 * $percentileFrom($layer)]
	set scalingFrom($layer) [[nap "(coordinate_variable(f))(rcf @ tmp)"]]
	set tmp [expr 0.01 * $percentileTo($layer)]
	set scalingTo($layer)   [[nap "(coordinate_variable(f))(rcf @ tmp)"]]
	if {$auto_redraw} {
	    eval $redraw_command
	}
    }


    # equalise_histogram --
    #
    # Perform histogram equalisation

    proc equalise_histogram {
	all
	window_id
	nao
	layer
	color
	redraw_command
	{m 256}
	{n 32000}
    } {
	global Plot_nao::${window_id}::mapping
	if [[nap "rank(nao) == 3"]] {
	    nap "data = f32(nao(layer,,))"
	} else {
	    nap "data = f32(nao)"
	}
	nap "f = f32(define_histogram(data, 0, n))"
	nap "rcf_old = 0f32 // (psum(f) / sum(f))"
	nap "rcf_new = (m+1) ... 0f32 .. 1f32"
	nap "i = rcf_old @@ rcf_new"
	nap "j = 0 .. (m-1)"
puts "i: [$i a]"
puts "j: [$j a]"
	nap "mapping = (i(j+1) - i(j)) # j"
puts "mapping: [[nap mapping]]"
	eval $redraw_command
    }


    # define_histogram --
    #
    # Function giving frequencies
    # n = no. classes
    #
    # If full is 0 then 
    #    - CV contains middle values of each class
    #    - min(data) = min of first class 
    #    - max(data) = max of final class
    # If full is 1 then 
    #    - CV contains max values of each class
    #    - min(data) = min of first class = max of first class 
    #    - max(data) = max of final class

    proc define_histogram {
	data
	{full 1}
	{n 32000}
    } {
	nap "x = reshape(f32(data))"
	nap "r = range(x)"
	if {[[nap "r(0) == r(1)"]]} {
	    nap "f = n # 0"
	} else {
	    nap "delta = (r(1) - r(0)) / f32(n)"
	    nap "v = n ... (r(0) + delta) .. r(1)"
	    nap "f = # ((i32(ceil((x - r(0)) / delta)) >>> 1 <<< n) - 1)"
	    if {[[nap "full"]]} {
		if {[[nap "r(0) < v(0)"]]} {
		    nap "f = 0 // f"
		    nap "v = r(0) // v"
		}
	    } else {
		nap "v = v - 0.5 * delta"
	    }
	    $f set coo $v
	}
	nap "f"
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
	    $histogram.main.canvas itemconfigure title -text $scalingFromTitle
	} else {
	    $histogram.main.canvas itemconfigure title -text $scalingToTitle
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
	if {$xlabel eq ""} {
	    set text x
	} else {
	    set text $xlabel
	}
	label $w.xy.x.label -text $text -anchor w
	label $w.xy.x.value -textvariable Plot_nao::x \
		-anchor w -relief sunken -background white
	if {$ylabel eq ""} {
	    set text y
	} else {
	    set text $ylabel
	}
	label $w.xy.y.label -text $text -anchor w
	label $w.xy.y.value -textvariable Plot_nao::y \
		-anchor w -relief sunken -background white
	pack $w.xy.x.value -side right -anchor w -expand 1 -fill x
	pack $w.xy.x.label -side right -anchor w
	pack $w.xy.y.value -side right -anchor w -expand 1 -fill x
	pack $w.xy.y.label -side right -anchor w
	place $w.xy.x -relwidth 0.5 -relx 0 -rely 0 -anchor nw
	place $w.xy.y -relwidth 0.5 -relx 1 -rely 0 -anchor ne
	pack $w.xy -expand 1 -fill x
	if {$want_z} {
	    label $w.z -textvariable Plot_nao::z \
		    -anchor w -relief sunken -background white
	    pack $w.z -expand 1 -fill x
	}
	place $w -x 0 -y 0 -relwidth 1
	bind $graph <Leave> "destroy $all.xyz; $graph delete lines"
    }


    # draw_xy --
    #
    # Draw XY graph defined by 1D or 2D NAO.

    proc draw_xy {
	all
	window_id
	graph
	nao
	title
	range_nao
	height
	width
	colors
	labels
	symbols
	dash_patterns
	barwidth
	major_tick_length
	{default_height_width 256}
    } {
	if {"$height" eq ""} {
	    if {"$width" eq ""} {
		set width $default_height_width
	    }
	    set height $width
	} else {
	    if {"$width" eq ""} {
		set width $height
	    }
	}
	if {$range_nao == ""} {
	    nap "range_nao = nao"
	}
	if {$barwidth > 0} {
	    nap "range_nao = range_nao // 0"
	}
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	Plot_nao::incrRefCount $window_id $range_nao
	set redraw_command [list Plot_nao::redraw_xy $all $window_id $graph $nao $title \
		$range_nao $height $width $colors $labels $symbols $dash_patterns $barwidth \
		$major_tick_length]
	create_main_menu $all $window_id $graph $redraw_command $nao
	eval $redraw_command
    }


    # redraw_xy --
    #
    # Draw XY graph defined by 1D or 2D NAO.
    #
    # Called by draw_xy
    # Delete points whose x or y value is missing.

    proc redraw_xy {
	all
	window_id
	graph
	nao
	title
	range_nao
	height
	width
	colors
	labels
	symbols
	dash_patterns
	barwidth
	major_tick_length
	{margin_right_1D 16}
	{margin_right_2D 64}
	{legend_line_length 16}
	{legend_spacing 16}
	{spacing 4}
	{nmin_x 4}
	{nmin_y 4}
    } {
	global Plot_nao::${window_id}::font_standard
	global Plot_nao::${window_id}::font_title
	global Plot_nao::${window_id}::magnification
	global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
	global Plot_nao::${window_id}::xlabel
	global Plot_nao::${window_id}::ylabel
	$graph delete all
	if {$magnification ne ""} {
	    set new_width  [expr round($magnification * $width)]
	    set new_height [expr round($magnification * $height)]
	}
	if {$new_width < 0} {
	    set new_width $width
	}
	if {$new_height < 0} {
	    set new_height $height
	}
	nap "cvx = coordinate_variable(nao, -1)"
	set linespace [font metrics $font_standard -linespace]
	set margin_top    [expr 3 * [font metrics $font_title -linespace]]
	set margin_bottom [expr 3 * $linespace + $major_tick_length]
	set width_char [font measure $font_standard A]
	set margin_left   [expr $linespace + $major_tick_length + 10 * $width_char]
	set height_total [expr "$new_height + $margin_top + $margin_bottom"]
	switch [$nao rank] {
	    1 {set width_total [expr "$new_width + $margin_left + $margin_right_1D"]}
	    2 {set width_total [expr "$new_width + $margin_left + $margin_right_2D"]}
	    default {handle_error "Illegal rank"; return}
	}
	set unit [$nao unit]
	$graph delete all
	set tmp [resize_canvas $all $window_id $width_total $height_total]
	set delta_width  [expr [lindex $tmp 0] -  $width_total]
	set new_width [expr $new_width + $delta_width]
	set width_total [expr $width_total + $delta_width]
	set delta_height [expr [lindex $tmp 1] - $height_total]
	set new_height [expr $new_height + $delta_height]
	set height_total [expr $height_total + $delta_height]
	set tmp [draw_y_axis_for_xy $window_id $graph $ylabel $margin_left $margin_top \
		$new_height $range_nao $unit $major_tick_length]
	set y0 [lindex $tmp 0]
	set yend [lindex $tmp 1]
	nap "range_x = range(cvx)"
	if {[[nap "range_x(0) == range_x(1)"]]} {
	    nap "range_x = range_x + {0 1}"
	}
	set unit_x [$cvx unit]]
	# Following just to define max_width
	nap "major_ticks_x = scaleAxisSpan(range_x(0), range_x(1), 32)"
	$major_ticks_x set unit $unit_x
	set max_width [font measure $font_standard \
		"[longest_element [geog_format $major_ticks_x]] "]
	nap "major_ticks_x = scaleAxisSpan(range_x(0), range_x(1), i32(new_width / max_width - 1))"
	$major_ticks_x set unit $unit_x
	set x0   [[nap "major_ticks_x(0)"]]
	set xend [[nap "major_ticks_x(-1)"]]
	nap "xslope = new_width / f64(xend - x0)"; # slope for x mapping
	set width_bar [[nap "xslope * barwidth"]]
	set width_total [expr "round($width_total + $width_bar)"]
	nap "x_b = margin_left + 0.5 * width_bar - xslope * x0"; # y-intercept for x mapping
	nap "yslope = new_height / f64(y0 - yend)"; # slope for y mapping
	nap "y_b = margin_top - yslope * yend"; # y-intercept for y mapping
	if {[llength $dash_patterns] == 0} {
	    set dash_patterns [list $dash_patterns]
	}
	set x [expr round($margin_left + 0.5 * $width_bar)]
	set y [expr $margin_top + $new_height + 2 * ($width_bar > 0)]
	draw_x_axis_for_xy $window_id $graph $xlabel $x $y $new_width \
		$major_ticks_x $major_tick_length
	set x [expr $width_total / 2] 
	set y [expr $margin_top/2]
	$graph create text $x $y -font $font_title -justify center -text $title -tags title
	switch [$nao rank] {
	    1 {
		set color [lindex $colors 0]
		set symbol [lindex $symbols 0]
		set dash_pattern [lindex $dash_patterns 0]
		nap "mask = count(cvx,0) && count(nao,0)"
		nap "x = x_b + xslope * (mask # cvx)"
		nap "y = y_b + yslope * (mask # nao)"
		draw_xy_or_bar $width_bar $graph 1 0 $color $symbol $dash_pattern $x $y \
			$new_height $margin_top
	    }
	    2 {
		set nrows [[nap "(shape(nao))(0)"]]
		set ncolors [llength $colors]
		set n_dash_patterns [llength $dash_patterns]
		set x1 [expr $margin_left + $width_bar + $new_width + $spacing]
		set x3 [expr $x1 + $legend_line_length]
		set x2 [expr 0.5 * ($x1 + $x3)]
		set x4 [expr $x3 + $spacing]
		for {set i  0} {$i < $nrows} {incr i} {
		    set label [lindex $labels $i]
		    if {$label == ""} {
			set label y$i
		    }
		    set color [lindex $colors [expr $i % $ncolors]]
		    set symbol [lindex $symbols $i]
		    set dash_pattern [lindex $dash_patterns [expr $i % $n_dash_patterns]]
		    nap "mask = count(cvx,0) && count(nao(i,),0)"
		    nap "x = x_b + xslope * (mask # cvx)"
		    nap "y = y_b + yslope * (mask # nao(i,))"
		    draw_xy_or_bar $width_bar $graph $nrows $i $color $symbol $dash_pattern $x $y \
			    $new_height $margin_top
		    set y [expr $margin_top + $legend_spacing * ($i + 1)]
		    draw_symbol $graph $symbol $color $x2 $y
		    if {$barwidth > 0} {
			$graph create rectangle \
				$x1 [expr $y - 0.5 * $legend_spacing] \
				$x3 [expr $y + 0.5 * $legend_spacing] \
				-fill $color -width 0
		    } else {
			$graph create line $x1 $y $x3 $y -fill $color
		    }
		    $graph create text $x4 $y -anchor w -text $label
		}
	    }
	}
	# Following define inverse tranformation
	set x_b [[nap "-f64(x_b) / xslope"]]
	set xslope [[nap "1.0 / xslope"]]
	set y_b [[nap "-f64(y_b) / yslope"]]
	set yslope [[nap "1.0 / yslope"]]
	bind $graph <Motion> "Plot_nao::crosshairs_xy \
		[list $all $window_id $graph $x_b $xslope $y_b $yslope %x %y]"
    }


    # draw_xy_or_bar --

    proc draw_xy_or_bar {
	width_bar
	graph
	nrows
	i
	color
	symbol
	dash_pattern
	x
	y
	height
	margin_top
    } {
	set n [$x nels]
	if {$width_bar == 0} {
	    nap "xy = reshape(transpose(x /// y))"
	    switch -- $dash_pattern {
		{ }	{}
		{}	{$graph create line [$xy value] -fill $color}
		default	{$graph create line [$xy value] -fill $color -dash $dash_pattern}
	    }
	    if {"$symbol" ne ""} {
		for {set j 0} {$j < $n} {incr j} {
		    draw_symbol $graph $symbol $color [[nap "xy(2*j)"]] [[nap "xy(2*j+1)"]]
		}
	    }
	} else {
	    nap "x0 = f64(width_bar) / nrows * (i - 0.5 * nrows)"
	    nap "x1 = f64(width_bar) / nrows * (i - 0.5 * nrows + 1.0)"
	    set y1 [expr "$height + $margin_top"]
	    for {set j 0} {$j < $n} {incr j} {
		$graph create rectangle \
			[[nap "x(j) + x0"]] [[nap "y(j)"]] \
			[[nap "x(j) + x1"]] $y1 \
			-fill $color -width 0
	    }
	}
    }


    # draw_symbol --
    #
    # Draw specified symbol at specified point.
    # Intended for marking data points on graph.
    # Symbol names (plus, square, circle, cross, splus, scross, triangle) are from BLT graph.
    # If symbol is "" then do nothing.
    # symbol can also be single character e.g. "*".

    proc draw_symbol {
	graph
	symbol
	color
	x
	y
	{width 1}
	{h 8.0}
    } {
	switch -glob $symbol {
	    circle {
		$graph create oval \
			[expr $x - $h/2] \
			[expr $y - $h/2] \
			[expr $x + $h/2] \
			[expr $y + $h/2] \
			-fill $color \
			-width 0
	    }
	    cross {
		    draw_symbol $graph scross $color $x $y 2
		}
	    plus {
		    draw_symbol $graph splus $color $x $y 2
	    }
	    scross {
		$graph create line \
			[expr $x - $h/2] [expr $y - $h/2] \
			[expr $x + $h/2] [expr $y + $h/2] \
			-fill $color \
			-width $width
		$graph create line \
			[expr $x - $h/2] [expr $y + $h/2] \
			[expr $x + $h/2] [expr $y - $h/2] \
			-fill $color \
			-width $width
	    }
	    splus {
		$graph create line \
			[expr $x - $h/2] $y \
			[expr $x + $h/2] $y \
			-fill $color \
			-width $width
		$graph create line \
			$x [expr $y - $h/2] \
			$x [expr $y + $h/2] \
			-fill $color \
			-width $width
	    }
	    square {
		$graph create rectangle \
			[expr $x - $h/2] \
			[expr $y - $h/2] \
			[expr $x + $h/2] \
			[expr $y + $h/2] \
			-fill $color \
			-width 0
	    }
	    triangle {
		set R [expr $h / 2 / 0.866025]; # sin(pi/3)
		$graph create polygon \
			[expr $x - $h/2] [expr $y + $R/2] \
			$x               [expr $y - $R] \
			[expr $x + $h/2] [expr $y + $R/2] \
			-fill $color \
			-width 0
	    }
	    ? {
		$graph create text $x $y -justify center -text $symbol -fill $color
	    }
	    "" {
	    }
	    default {
		handle_error "Illegal symbol"
	    }
	}
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
	range_nao
	buttonCommand
	want_yflip
	major_tick_length
    } {
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
        global Plot_nao::${window_id}::main_palette
        global Plot_nao::${window_id}::want_scaling_widget
	global Plot_nao::${window_id}::xlabel
	global Plot_nao::${window_id}::ylabel
	if {[[nap "rank(nao) < 2"]]} {
	    handle_error "Illegal rank"
	    return
	}
	if {[check_cvs $nao]} {
	    handle_error "Illegal coordinate variable"
	    return
	}
	set new_width $width
	set new_height $height
	set_yflip $window_id $want_yflip $nao
	set cvx [$nao coord -1]
	set cvy [$nao coord -2]
	set cvz [$nao coord -3]
	if {$cvx ne "(NULL)"  &&  [fix_unit [$cvx unit]] == "degrees_east"} {
	    nap "cvx = fix_longitude(cvx)"
	}
	switch [$nao rank] {
	    2 {$nao set coord $cvy $cvx}
	    3 {$nao set coord $cvz $cvy $cvx}
	}
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	set redraw_command [list Plot_nao::redraw_z $all $window_id $graph $nao $range_nao \
		$title $xlabel $ylabel $major_tick_length]
	create_main_menu $all $window_id $graph $redraw_command $nao
	frame $all.scaling_range
	if {$want_scaling_widget} {
	    pack $all.scaling_range -before $all.main -anchor n -fill x
	}
	set nlayers [[nap "rank(nao) == 2 ? 1 : (3 <<< (shape(nao))(0))"]]
	for {set layer 0} {$layer < $nlayers} {incr layer} {
	    set color [color_of_layer $nao $layer]
	    set frame $all.scaling_range.$color
	    create_scaling_range $all $window_id $frame $nao $layer $color $redraw_command
	}
	eval $redraw_command
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
	    set unit [fix_unit [$row_cv unit]]
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


    # geog_format --
    #
    # Format a scalar or vector nao with special treatment of latitudes & longitudes
    # (defined by unit of nao)

    proc geog_format {
	nao
    } {
	set degree "\xb0"; # ISO-8859 code for degree symbol
	set n [$nao nels]
	switch [fix_unit [$nao unit]] {
	    degrees_north {
		set a [[nap "reshape(abs(nao), n // 1)"] value]
		set j [[nap "1 + sign(nao)"] value]
		set suffix {S { } N}
		for {set i 0} {$i < $n} {incr i} {
		    lappend result "[lindex $a $i]$degree[lindex $suffix [lindex $j $i]]"
		}
	    }
	    degrees_east {
		nap "lon = (nao + 180f32) % 360f32 - 180f32"
		set a [[nap "reshape(abs(lon), n // 1)"] value]
		set j [[nap "abs(lon) == 180 ? 1 : 1 + sign(lon)"] value]
		set suffix {W {} E}
		for {set i 0} {$i < $n} {incr i} {
		    lappend result "[lindex $a $i]$degree[lindex $suffix [lindex $j $i]]"
		}
	    }
	    default {
		set result [[nap "reshape(nao, n // 1)"] value]
	    }
	}
	return $result
    }


    # fix_unit --
    #
    # Return "degrees_east"  if arg is anything equivalent to this e.g. "degreeE"
    # Return "degrees_north" if arg is anything equivalent to this e.g. "degreeN"
    # Return "" if arg is "(NULL)"
    # Otherwise just return arg

    proc fix_unit {
	unit
    } {
	set unit [string trim $unit]
	if {"$unit" eq "(NULL)"} {
	    return ""
	}
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


    # redraw_z --
    #
    # Draw grey-scale or color image
    # Called by draw_z, "redraw" button, etc.

    proc redraw_z {
	all
	window_id
	graph
	nao
	range_nao
	title
	xlabel
	ylabel
	major_tick_length
	{min_dim 64}
    } {
	global Plot_nao::${window_id}::allow_scroll
	global Plot_nao::${window_id}::font_standard
	global Plot_nao::${window_id}::font_title
	global Plot_nao::${window_id}::gap_width
	global Plot_nao::${window_id}::image_nao
	global Plot_nao::${window_id}::key_width
	global Plot_nao::${window_id}::magnification
	global Plot_nao::${window_id}::main_palette
	global Plot_nao::${window_id}::mapping
	global Plot_nao::${window_id}::new_height
	global Plot_nao::${window_id}::new_width
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	global Plot_nao::${window_id}::xflip
	global Plot_nao::${window_id}::yflip

	set rank_nao [$nao rank]
	set nx [[nap "(shape nao)(-1)"]]
	set ny [[nap "(shape nao)(-2)"]]
	if {$magnification ne ""} {
	    set new_width  [expr round($magnification * $nx)]
	    set new_height [expr round($magnification * $ny)]
	} elseif {$allow_scroll} {
	    set new_width  $nx
	    set new_height $ny
	}
	if {$new_width eq ""} {
	    set new_width  [expr $nx < $min_dim ? $min_dim : $nx]
	}
	if {$new_height eq ""} {
	    set new_height [expr $ny < $min_dim ? $min_dim : $ny]
	}
	if {$new_width != $nx  ||  $new_height != $ny} {
	    nap "magnification_x = f32(new_width)  / nx"
	    nap "magnification_y = f32(new_height) / ny"
	    nap "nao = magnify_nearest(nao, (rank_nao-2) # 1 // magnification_y // magnification_x)"
	    nap "cvx = coordinate_variable(nao, -1)"
	    nap "cvy = coordinate_variable(nao, -2)"
	    set new_width  [$cvx nels]
	    set new_height [$cvy nels]
	}
	set nx [[nap "(shape nao)(-1)"]]
	set ny [[nap "(shape nao)(-2)"]]
	set xend [[nap "nx - 1"]]
	set xflip [expr $xflip != 0]; # ensure either 0 or 1
	set yflip [expr $yflip != 0]; # ensure either 0 or 1
	if {$xflip || $yflip} {
	    set reverse(0) ""
	    set reverse(1) "-"
	    set comma(2) ""
	    set comma(3) ","
	    nap "nao = nao($comma($rank_nao)$reverse($yflip),$reverse($xflip))"
	}
	set_scaling $window_id $nao $range_nao intercept slope y_0 y_1 255
	if [[nap "rank_nao == 3  &&  (shape(nao))(0) > 3"]] {
	    nap "nao = nao(0 .. 2, , )"
	}
	set linespace [font metrics $font_standard -linespace]
	set margin_top    [expr 3 * [font metrics $font_title -linespace]]
	set margin_bottom [expr 3 * $linespace + $major_tick_length]
	set width_char [font measure $font_standard A]
	set margin_left  [expr $linespace + $major_tick_length + 10 * $width_char]
	set height_total [expr "$new_height + $margin_top + $margin_bottom"]
	set width_total  [expr "$new_width + $margin_left + $gap_width"]
	set have_key [expr {$key_width ne ""  &&  $key_width > 0  &&  $rank_nao == 2}]
	if {$have_key} {
	    incr width_total [expr $key_width + $margin_left]
	}
	$graph delete all
	set tmp [resize_canvas $all $window_id $width_total $height_total]
	set new_width_total  [lindex $tmp 0]
	set new_height_total [lindex $tmp 1]
	if {$new_width_total < $width_total  ||  $new_height_total < $height_total} {
	    nap "rx = new_width  / f32(new_width  + new_width_total  - width_total)"
	    nap "ry = new_height / f32(new_height + new_height_total - height_total)"
	    set magnification [[nap "1.0 / ceil(rx >>> ry)"]]
	    nap "nao = magnify_nearest(nao, (rank_nao-2) # 1 // 2 # magnification)"
	    nap "cvx = coordinate_variable(nao, -1)"
	    nap "cvy = coordinate_variable(nao, -2)"
	    set new_width  [$cvx nels]
	    set new_height [$cvy nels]
	    set height_total [expr "$new_height + $margin_top + $margin_bottom"]
	    set width_total  [expr "$new_width + $margin_left + $gap_width"]
	    if {$have_key} {
		incr width_total [expr $key_width + $margin_left]
	    }
	    $graph configure -height $height_total -width $width_total  
	}
	if {$have_key} {
	    set ncols [[nap "(shape(nao))(1)"]]
	    set x2 [expr "$xend + $gap_width * $ncols / $new_width"]
	    set x3 [expr "$x2   + $key_width * $ncols / $new_width"]
	}
	if {$mapping eq ""} {
	    nao2image u $window_id $nao $y_0 $y_1 $slope $intercept 1
	} else {
	    nao2image u $window_id $nao 0 31999 1f32 0f32 1
	}
	set x [expr $width_total / 2] 
	set y [expr $margin_top/2]
	$graph create text $x $y -font $font_title -justify center -text $title -tags title
	set x $margin_left
	set y [expr $margin_top + $new_height + 2]
	nap "cvx = coordinate_variable(nao, -1)"
	nap "cvy = coordinate_variable(nao, -2)"
	draw_x_axis_for_image $window_id $graph $xlabel $x $y $new_width $cvx $major_tick_length
	set x [expr $margin_left - 2]
	set y $margin_top
	draw_y_axis_for_image $window_id $graph $ylabel $x $y $new_height $cvy -1 $major_tick_length
	update
	set imageName [image create photo -format NAO -data $u]
	$graph create image $margin_left $margin_top -image $imageName -anchor nw
	if {$have_key} {
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
		set imageName [image create photo -format NAO -data $u]
		set x [expr $margin_left + $new_width + $gap_width]
		set y $margin_top
		$graph create image $x $y -image $imageName -anchor nw
		set x [expr $x + $key_width + 2]
		draw_y_axis_for_image $window_id $graph "" $x $y $new_height $cvy2 1 \
			$major_tick_length
	    }
	}
	nap "image_nao = nao"
	bind $graph <Motion> "Plot_nao::crosshairs_xyz \
		[list $all $window_id $graph $margin_left $margin_top %x %y]"
	raise $all
	update
    }


    # resize_canvas --
    #
    # Change width & height of canvas to specified values if possible.
    # Create scrollbars if needed.
    # Return new width & height (which may be less than requested)

    proc resize_canvas {
	all
	window_id
	width
	height
	{width_scrollbar 21}
    } {
	global Plot_nao::${window_id}::allow_scroll
	global Plot_nao::${window_id}::auto_print
	global Plot_nao::${window_id}::oversize_prompt
	global Plot_nao::${window_id}::max_canvas_width
	global Plot_nao::${window_id}::max_canvas_height
	set main $all.main
	set canvas $main.canvas
	set xscroll $main.xscroll
	set yscroll $main.yscroll
	set top [winfo toplevel $all]
	set max_width  $max_canvas_width
	set max_height $max_canvas_height
	grid remove $xscroll $yscroll
	if {$max_width eq ""} {
	    set max_width [expr [lindex [wm maxsize $top] 0] - $width_scrollbar]
	}
	if {$max_height eq ""} {
	    set max_height [expr [lindex [wm maxsize $top] 1] - $width_scrollbar]
	    update idletasks
	    foreach w "$all.main_menu $all.scaling_range" {
		if {[winfo exists $w]  &&  [winfo ismapped $w]} {
		    incr max_height -[winfo height $w]
		}
	    }
	}
	if {$oversize_prompt  &&  ! $auto_print \
		&& ($height > $max_height  ||  $width > $max_width)} {
	    set allow_scroll \
		    [tk_dialog .tk_dialog "compress scroll" \
		    "Image is bigger than screen!" \
		    "" $allow_scroll "Compress (sample)" Scroll]
	    set oversize_prompt 0
	}
	if {$height > $max_height} {
	    if {$allow_scroll} {
		set new_height  $height
		grid $yscroll -row 0 -column 1
	    } else {
		set new_height  $max_height
	    }
	    $canvas configure -height $max_height
	} else {
	    set new_height  $height
	    $canvas configure -height $height
	}
	if {$width > $max_width} {
	    if {$allow_scroll} {
		set new_width  $width
		grid $xscroll -row 1 -column 0
	    } else {
		set new_width  $max_width
	    }
	    $canvas configure -width $max_width
	} else {
	    set new_width  $width
	    $canvas configure -width $width
	}
	$canvas configure -scrollregion "0 0 $new_width $new_height"
	set width_canvas [winfo width $canvas]
	if {$width_canvas > $new_width} {
	    set new_width $width_canvas
	    $canvas configure -scrollregion "0 0 $new_width $new_height"
	}
	return "$new_width $new_height"
    }


    # vertical_text  --
    #
    # Write vertical text onto canvas.
    # Try to rotate 90 degrees via image using package Img.
    # If this fails, use 'HOTEL' writing.

    proc vertical_text {
	canvas
	text
	x
	y
	{font "courier 12"}
	{anchor e}
	{tags ""}
	{tmp_top .tmpTop}
    } {
	catch "package require Img"
	toplevel $tmp_top
	set tmp_can $tmp_top.canvas
	set w [expr 1 + [font measure $font $text]]
	set h [font metrics $font -linespace]
	canvas $tmp_can -height $h -width $w -highlightthickness 0
	$tmp_can configure -background [$canvas cget -background]
	$tmp_can create text 1 0 -anchor nw -font $font -text $text
	pack $tmp_can
	update 
	set status [catch {image create photo -format window -data $tmp_can} img1]
	if {$status == 0} {
	    $img1 write u -format NAO
	    image delete $img1
	    nap "u = (transpose(u, {0 2 1}))(,-,)"
	    set img2 [image create photo -format NAO -data $u]
	    $canvas create image $x $y -anchor $anchor -tags $tags -image $img2
	} else {
	    set text [join [split $text {}] \n]
	    $canvas create text $x $y -anchor $anchor -tags $tags -font $font -text $text
	}
	destroy $tmp_top
    }


    # longest_element --
    #
    # Return longest (max. no. characters) element of list

    proc longest_element {
	list
    } {
	set max_n 0
	set longest ""
	foreach e $list {
	    set n [string length $e]
	    if {$n > $max_n} {
		set max_n $n
		set longest $e
	    }
	}
	return $longest
    }


    # axis_major_ticks --
    #
    # nap function giving vector of axis major ticks based on given coord. var. cv
    # Assume axis has same length as cv, so major ticks are within range of cv
    # Treat specially if cv has geographic (lat/lon) unit

    proc axis_major_ticks {
	cv
	nmax
	{nice_geog "{30 45 90 180 360}"}
    } {
	nap "nmax = 2 >>> i32(nmax)"
	nap "geog_nice = nice_geog"
	nap "major_ticks = scaleAxis(cv(0), cv(-1), nmax)"
	set step [[nap "major_ticks(1) - major_ticks(0)"]]
	set unit [fix_unit [$cv unit]]
	if {abs($step) > 10  &&  [regexp {^degrees_(east|north)$} $unit]} {
	    nap "cv_min = cv(0) <<< cv(-1)"
	    nap "cv_max = cv(0) >>> cv(-1)"
	    nap "label_min = geog_nice * ceil (cv_min/geog_nice)"
	    nap "label_max = geog_nice * floor(cv_max/geog_nice)"
	    nap "n = nint((label_max - label_min) / geog_nice)"
	    nap "i = n @@@ max((n <= nmax) # n)"
	    nap "geog_labels = label_min(i) .. label_max(i) ... geog_nice(i)"
	    if [[nap "nels(geog_labels) > 1"]] {
		nap "major_ticks = cv(0) < cv(1) ? geog_labels : geog_labels(-)"
	    }
	}
	nap "major_ticks"
    }


    # axis_minor_ticks --
    #
    # nap function giving vector of axis minor tick marks based on cv & major tick marks

    proc axis_minor_ticks {
	cv
	major_ticks
	{min_interval 6}
	{nice "{2 5 10 15 30 45 90}"}
    } {
	set n [$major_ticks nels]
	nap "i = cv @@ major_ticks"
	# max no. minor intervals per major interval
	nap "max_nminor = i32(nint(min(abs(i(1 .. (n-1)) - i(0 .. (n-2)))) / min_interval))"
	nap "step_major = f64(major_ticks(1) - major_ticks(0))"
	nap "normalised_step_major = nint(10.0 * 10.0 ** (log10(abs(step_major)) % 1.0))"
	nap "steps = normalised_step_major / (1.0 .. 5.0)"
	nap "rem = steps % 1.0"
	nap "steps = (rem < 0.01  ||  rem > 0.99) # i32(nint(steps))"
	nap "steps = isMember(steps, nice) # steps"
	nap "nminor = normalised_step_major / steps"
	nap "nminor = i32(1 >>> max((nminor <= max_nminor) # nminor))"
	nap "step = step_major / nminor"
	nap "from = i32(fuzzy_ceil (cv( 0) / step))"
	nap "to   = i32(fuzzy_floor(cv(-1) / step))"
	nap "step * (from .. to)"
    }


    # draw_x_axis --
    #
    # Draw x-axis with origin at (x0,y0), given a coord. var. defining value at each pixel.
    # sign is -1 for ticks above axis, 1 for ticks below axis

    proc draw_x_axis {
	window_id
	graph
	label
	x0
	y0
	length
	cv
	sign
	major_ticks
	major_tick_length
	{tick_offset 0}
    } {
	global Plot_nao::${window_id}::font_standard
	set unit [fix_unit [$cv unit]]
	set is_geog [regexp {degrees_(east|north)} $unit]
	set linespace [font metrics $font_standard -linespace]
	$graph create line $x0 $y0 [expr $x0 + $length] $y0
	nap "minor_ticks = axis_minor_ticks(cv, major_ticks)"
	set n [$major_ticks nels]
	nap "step_major = f64(major_ticks(1) - major_ticks(0))"
	nap "normalised = nint(10.0 ** (log10(abs(step_major)) % 1.0))"
	nap "want_text = normalised != 5 ||  nint(major_ticks / step_major) % 2 == 0"
	if {[[nap "is_geog  ||  sum(want_text) < 4"]]} {
	    nap "want_text = n # 1"
	}
	nap "x1 = x0 + tick_offset"
	set y1 [expr $y0 + $sign * $major_tick_length]
	set y2 [expr $y1 + $sign * $linespace * 3/4]
	nap "i = cv @ major_ticks"
	nap "tmp = want_text * major_ticks"
	$tmp set unit $unit
	set labels [geog_format $tmp]
	for {set j 0} {$j < $n} {incr j} {
	    set x [[nap "x1 + i(j)"]]
	    $graph create line $x $y1 $x $y0
	    if {[[nap "want_text(j)"]]} {
		set text [lindex $labels $j]
		$graph create text $x $y2 -font $font_standard -justify center -text $text
	    }
	}
	set y1 [expr $y0 + $sign * $major_tick_length/2]
	nap "i = cv @ minor_ticks"
	set n [$minor_ticks nels]
	for {set j 0} {$j < $n} {incr j} {
	    set x [[nap "x1 + i(j)"]]
	    $graph create line $x $y1 $x $y0
	}
	if {$label ne ""  &&  $unit ne "degrees_east"} {
	    set x [expr $x0 + 0.5 * $length]
	    set y [expr $y2 + $sign * $linespace]
	    $graph create text $x $y -font $font_standard -justify center -tags xlabel -text $label
	}
    }


    # draw_x_axis_for_xy --
    #
    # Draw linear x-axis with origin at (x0,y0)

    proc draw_x_axis_for_xy {
	window_id
	graph
	label
	x0
	y0
	length
	major_ticks
	major_tick_length
	{sign 1}
    } {
	global Plot_nao::${window_id}::font_standard
	nap "cv = (length + 1) ... major_ticks(0) .. major_ticks(-1)"
	draw_x_axis $window_id $graph $label $x0 $y0 $length $cv $sign $major_ticks \
		$major_tick_length
    }


    # draw_x_axis_for_image --
    #
    # Draw x-axis with origin at (x0,y0), given a coord. var. defining value at each pixel.
    # sign is -1 for ticks above axis, 1 for ticks below axis
    # length is # columns in matrix

    proc draw_x_axis_for_image {
	window_id
	graph
	label
	x0
	y0
	length
	cv
	major_tick_length
	{sign 1}
    } {
	global Plot_nao::${window_id}::font_standard
	set unit [fix_unit [$cv unit]]
	nap "major_ticks = axis_major_ticks(cv, 32)"; # Just to define max_width
	$major_ticks set unit $unit
	set max_width [font measure $font_standard "[longest_element [geog_format $major_ticks]] "]
	nap "major_ticks = axis_major_ticks(cv, length / max_width - 1)"
	$major_ticks set unit $unit
	draw_x_axis $window_id $graph $label $x0 $y0 $length $cv $sign $major_ticks \
		$major_tick_length 0.5
    }


    # draw_y_axis --
    #
    # Draw y-axis with origin at (x0,y0), given a coord. var. defining value at each pixel.
    # sign is -1 for ticks on left of axis, 1 for ticks on right of axis
    # y0 is y-coord. of top of axis

    proc draw_y_axis {
	window_id
	graph
	label
	x0
	y0
	length
	cv
	sign
	major_ticks
	major_tick_length
	{tick_offset 0}
    } {
	global Plot_nao::${window_id}::font_standard
	set linespace [font metrics $font_standard -linespace]
	set spacing [expr $linespace / 4]
	$graph create line $x0 $y0 $x0 [expr $y0 + $length]
	nap "minor_ticks = axis_minor_ticks(cv, major_ticks)"
	set unit [fix_unit [$cv unit]]
	set is_geog [regexp {degrees_(east|north)} $unit]
	$major_ticks set unit $unit
	set labels [geog_format $major_ticks]
	set max_width [font measure $font_standard [longest_element $labels]]
	set x1 [expr $x0 + $sign * $major_tick_length]
	nap "y1 = y0 + tick_offset"
	if {$sign < 0} {
	    set x2 [expr $x1 - $spacing]
	    set x3 [expr $x2 - $max_width - 2 * $spacing]
	    set anchor e
	} else {
	    set x2 [expr $x1 + $spacing + $max_width]
	    set x3 [expr $x2 + 2 * $spacing]
	    set anchor w
	}
	nap "i = cv @ major_ticks"
	set n [$major_ticks nels]
	nap "step_major = f64(major_ticks(1) - major_ticks(0))"
	nap "normalised = nint(10.0 ** (log10(abs(step_major)) % 1.0))"
	nap "want_text = normalised != 5 ||  nint(major_ticks / step_major) % 2 == 0"
	if {[[nap "is_geog  ||  sum(want_text) < 4"]]} {
	    nap "want_text = n # 1"
	}
	nap "tmp = want_text * major_ticks"
	$tmp set unit $unit
	set labels [geog_format $tmp]
	for {set j 0} {$j < $n} {incr j} {
	    set y [[nap "y1 + i(j)"]]
	    $graph create line $x1 $y $x0 $y
	    if {[[nap "want_text(j)"]]} {
		set text [lindex $labels $j]
		$graph create text $x2 $y -anchor e -font $font_standard -justify right -text $text
	    }
	}
	set x1 [expr $x0 + $sign * $major_tick_length/2]
	nap "i = cv @ minor_ticks"
	set n [$minor_ticks nels]
	for {set j 0} {$j < $n} {incr j} {
	    set y [[nap "y1 + i(j)"]]
	    $graph create line $x1 $y $x0 $y
	}
	if {$label ne ""  &&  $unit ne "degrees_north"} {
	    set y [expr $y0 + 0.5 * $length]
	    vertical_text $graph $label $x3 $y $font_standard $anchor ylabel
	}
    }


    # draw_y_axis_for_xy --
    #
    # Draw linear y-axis with origin at (x0,y0)

    proc draw_y_axis_for_xy {
	window_id
	graph
	label
	x0
	y0
	length
	range_y
	unit
	major_tick_length
	{sign -1}
    } {
	global Plot_nao::${window_id}::font_standard
	nap "range_y = range(range_y)"
	if {[[nap "range_y(0) == range_y(1)"]]} {
	    nap "range_y = range_y + {0 1}"
	}
	nap "major_ticks = scaleAxisSpan(range_y(1), range_y(0), 32)"
	$major_ticks set unit $unit
	set max_width [font measure $font_standard "[longest_element [geog_format $major_ticks]] "]
	nap "nmax = i32(length / max_width - 1)"
	nap "major_ticks = scaleAxisSpan(range_y(1), range_y(0), nmax)"
	$major_ticks set unit $unit
	nap "cv = (length + 1) ... major_ticks(0) .. major_ticks(-1)"
	$cv set unit $unit
	draw_y_axis $window_id $graph $label $x0 $y0 $length $cv $sign $major_ticks \
		$major_tick_length
	return [[nap "major_ticks{-1 0}"]]
    }


    # draw_y_axis_for_image --
    #
    # Draw y-axis with origin at (x0,y0), given a coord. var. defining value at each pixel.
    # sign is -1 for ticks on left of axis, 1 for ticks on right of axis
    # y0 is y-coord. of top of axis
    # length is # rows in matrix

    proc draw_y_axis_for_image {
	window_id
	graph
	label
	x0
	y0
	length
	cv
	sign
	major_tick_length
    } {
	global Plot_nao::${window_id}::font_standard
	nap "major_ticks = axis_major_ticks(cv, 32)"
	set unit [$cv unit]
	if {$unit ne "(NULL)"} {
	    $major_ticks set unit $unit
	}
	set max_width [font measure $font_standard "[longest_element [geog_format $major_ticks]] "]
	nap "nmax = i32(length / max_width - 1)"
	nap "major_ticks = axis_major_ticks(cv, nmax)"
	draw_y_axis $window_id $graph $label $x0 $y0 $length $cv $sign $major_ticks \
		$major_tick_length 0.5
    }


    # crosshairs_xy --
    #
    # called when pointer moves within xy-plot or barchart

    proc crosshairs_xy {
	all
	window_id
	graph
	x_b
	xslope
	y_b
	yslope 
	screen_x
	screen_y
	{color_crosshair red}
    } {
	global Plot_nao::x
	global Plot_nao::y
	global Plot_nao::xyz
	if {![winfo exists $all.xyz]} {
	    Plot_nao::create_xyz $all $window_id $graph 0
	    $graph config -cursor crosshair
	}
	set width_total  [lindex [$graph cget -scrollregion] 2]
	set height_total [lindex [$graph cget -scrollregion] 3]
	set can_x [$graph canvasx $screen_x]
	set can_y [$graph canvasy $screen_y]
	$graph delete lines
	set x [format %0.6g [expr "$xslope * $can_x + $x_b"]]
	set y [format %0.6g [expr "$yslope * $can_y + $y_b"]]
	set xyz "$x $y"
	$graph create line $can_x 0 $can_x $height_total -fill $color_crosshair -tag lines
	$graph create line 0 $can_y $width_total $can_y  -fill $color_crosshair -tag lines
    }


    # crosshairs_xyz --
    #
    # called when pointer moves within z-plot (image plot)

    proc crosshairs_xyz {
	all
	window_id
	graph
	margin_left
	margin_top
	screen_x
	screen_y
	{color_crosshair red}
    } {
	global Plot_nao::x
	global Plot_nao::y
	global Plot_nao::z
	global Plot_nao::xyz
	global Plot_nao::${window_id}::gap_width
        global Plot_nao::${window_id}::image_nao
	if {![winfo exists $all.xyz]} {
	    Plot_nao::create_xyz $all $window_id $graph 1
	    $graph config -cursor crosshair
	}
	set scroll_region [$graph cget -scrollregion]
	set width_total  [lindex $scroll_region 2]
	set height_total [lindex $scroll_region 3]
	set can_x [$graph canvasx $screen_x]
	set can_y [$graph canvasy $screen_y]
	$graph delete lines
	$graph create line $can_x 0 $can_x $height_total -fill $color_crosshair -tag lines
	$graph create line 0 $can_y $width_total $can_y  -fill $color_crosshair -tag lines
	nap "cvx = coordinate_variable(image_nao,-1)"
	nap "cvy = coordinate_variable(image_nao,-2)"
	nap "nx = nels(cvx)"
	nap "ny = nels(cvy)"
	nap "i = can_y - $margin_top  >>> 0 <<< ny - 1"
	nap "j = can_x - $margin_left >>> 0"
	set x [[nap "cvx(j <<< nx - 1)"] -format %0.6g]
	set y [[nap "cvy(i)"] -format %0.6g]
	if {[$image_nao rank] == 3} {
	    set z [[nap "image_nao(, i, j <<< nx - 1)"] value -format %0.6g]
	} else {
	    if [[nap "j < nx + gap_width/2"]] {
		set z [[nap "image_nao(i, j <<< nx - 1)"] -format %0.6g]
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
		set z [[nap "zmax - i * (zmax - zmin) / (ny - 1f32)"] -format %0.6g]
	    }
	}
	set xyz "$x $y $z"
    }


    # set_scaling --
    #
    # Set scalingFrom, scalingTo, slope, intercept

    proc set_scaling {
	window_id
	nao
	range_nao
	name_intercept
	name_slope
	name_y0
	name_y1
	{upper 255}
    } {
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	upvar $name_intercept intercept
	upvar $name_slope slope
	upvar $name_y0 y0
	upvar $name_y1 y1
	set range_nao [info commands $range_nao]; # In case range_nao has been deleted
	set nlayers [[nap "rank(nao) == 2 ? 1 : (3 <<< (shape(nao))(0))"]]
	nap "tol = 0.01f32";	# tolerance for rounding error
	nap "y0 = tol"
	if {[$nao datatype] == "u8"  &&  [$nao missing] == "(NULL)"} {
	    nap "y1 = 1 + upper - tol"
	    if {$range_nao == ""} {
		for {set layer 0} {$layer < $nlayers} {incr layer} {
		    if {$scalingFrom($layer) == ""} {
			set scalingFrom($layer) 0
		    }
		    if {$scalingTo($layer) == ""} {
			set scalingTo($layer) $upper
		    }
		}
	    }
	} else {
	    nap "y1 = upper - tol"
	}
	if {$range_nao == ""} {
	    nap "range_nao = reshape(0f32, {0 2})"
	    for {set layer 0} {$range_nao != ""  &&  $layer < $nlayers} {incr layer} {
		if {$scalingFrom($layer) == ""  ||  $scalingTo($layer) == ""} {
		    set range_nao ""
		} else {
		    nap "range_nao = range_nao // ($scalingFrom($layer) // $scalingTo($layer))"
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
	nap "minValue = reshape(minValue)"
	nap "maxValue = reshape(maxValue)"
	for {set layer 0} {$layer < $nlayers} {incr layer} {
	    set scalingFrom($layer) [[nap "minValue(layer)"]]
	    set scalingTo($layer) [[nap "maxValue(layer)"]]
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
	if {[check_cvs $nao]} {
	    handle_error "Illegal coordinate variable"
	    return
	}
	    # This graph widget points to nao, so increment ref. count
	    # Decrement when widget destroyed (in procedure "close_window")
	Plot_nao::incrRefCount $window_id $nao
	set nlevels [[nap "(shape(nao))(0)"]]
	set ny [[nap "(shape(nao))(1)"]]
	set nx [[nap "(shape(nao))(2)"]]
	set_yflip $window_id $want_yflip $nao
	frame $all.scaling_range
	if {$want_scaling_widget} {
	    pack $all.scaling_range -before $all.main -anchor n -fill x
	}
	nap "nao2d = reshape(nao, (nlevels * ny) // nx)"
	Plot_nao::incrRefCount $window_id $nao2d
	set color black
	set frame $all.scaling_range.$color
	set redraw_command [list Plot_nao::redraw_tiles $all $window_id $graph $nao \
		$nlevels $ny $nx $nao2d $title $ncols $sub_title $range_nao]
	create_scaling_range $all $window_id $frame $nao2d 0 $color $redraw_command
	create_main_menu $all $window_id $graph $redraw_command $nao
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
    } {
	global Plot_nao::${window_id}::font_standard
	global Plot_nao::${window_id}::font_title
	global Plot_nao::${window_id}::gap_height
	global Plot_nao::${window_id}::gap_width
	global Plot_nao::${window_id}::key_width
        global Plot_nao::${window_id}::magnification
	global Plot_nao::${window_id}::orientation
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
	global Plot_nao::${window_id}::print_command
	global Plot_nao::${window_id}::scalingFrom
	global Plot_nao::${window_id}::scalingTo
	global Plot_nao::${window_id}::xflip
	global Plot_nao::${window_id}::yflip
	global Print_gui::paperheight 
	global Print_gui::paperwidth
	set screen_height [winfo screenheight $all]
	set screen_width  [winfo screenwidth  $all]
	set screen_ratio [expr double($screen_height) / double($screen_width)]
	set paper_ratio [expr double([winfo fpixels . $paperheight]) \
			    / double([winfo fpixels . $paperwidth])]
	if {$orientation eq "L"} {
	    set paper_ratio [expr 1.0 / $paper_ratio]
	}
	if {$orientation ne "A"} {
	    if {$screen_ratio > $paper_ratio} {
		set screen_height [expr $screen_width * $paper_ratio]
	    } else {
		set screen_width [expr $screen_height / $paper_ratio]
	    }
	    set new_width  -1
	    set new_height -1
	}
	if {$magnification ne ""} {
	    set new_width  [expr int($magnification * $nx)]
	    set new_height [expr int($magnification * $ny)]
	}
	$graph delete all
	set_scaling $window_id $nao2d $range_nao intercept slope y0 y1 255
	nap "axis = scaleAxis($scalingFrom(0), $scalingTo(0), 10)"
	set n_ticks [$axis nels]
	set tmp [split [[nap "reshape(axis, n_ticks // 1)"] value] "\n"]
	for {set k 0} {$k < $n_ticks} {incr k} {
	    lappend axis_text " [lindex $tmp $k] "
	}
	unset tmp
	set axis_text_width [font measure $font_standard [lindex $axis_text 0]]
	set ncols [layout_tiles $window_id $nlevels $ncols $screen_height $screen_width \
		$ny $nx $gap_height $gap_width $key_width $title_height \
		$tick_length $axis_text_width]
	nap "j = 0 // (nx - 1)"
	nap "j = i32(nint(ap_n(j(xflip), j(!xflip), nint(new_width))))"
	nap "i = 0 // (ny - 1)"
	nap "i = i32(nint(ap_n(i(yflip), i(!yflip), nint(new_height))))"
	nap "mat = nao(0,i,j)"
	set image_height "[$i nels]"
	set image_width  "[$j nels]"
	set nrows [expr ($nlevels + $ncols - 1) / $ncols]
	for {set level 0} {$level < $nlevels} {incr level} {
	    nap "mat = nao(level,i,j)"
	    nao2image u $window_id $mat $y0 $y1 $slope $intercept 1
	    set img [image create photo -format NAO -data $u]
	    if {$level == 0} {
		# Create canvas & key
		set can_height [expr $title_height + $nrows * ($image_height + $gap_height)]
		set can_width  [expr $ncols * ($image_width + $gap_width) + $gap_width]
		if {$key_width > 0} {
		    incr can_width [expr $key_width + $tick_length + $axis_text_width]
		}
		$graph configure -width  $can_width -height $can_height
		if {$key_width > 0} {
		    set key_height [expr ($can_height - $title_height) / 2]
		    nap "key_y = ap_n($scalingTo(0), $scalingFrom(0), key_height)"
		    nap "key = transpose(reshape(key_y, key_width // key_height))"
		    nao2image u $window_id $key $y0 $y1 $slope $intercept
		    set key_img [image create photo -format NAO -data $u]
		    set x [expr $can_width - $tick_length - $axis_text_width]
		    set y [expr $title_height + ($can_height - $title_height - $key_height) / 2]
		    $graph create image $x $y -image $key_img -anchor ne
		    set xx [expr $x + $tick_length]
		    for {set k 0} {$k < $n_ticks} {incr k} {
			set yy [[nap "y + (key_y @@ axis(k))"]]
			$graph create line $x $yy $xx $yy
			$graph create text $can_width $yy -text [lindex $axis_text $k] -anchor e \
				-font $font_standard
		    }
		}
	    }
	    set row [expr $level / $ncols]
	    set col [expr $level % $ncols]
	    set x [expr $gap_width + ($image_width + $gap_width) * $col]
	    set y [expr $title_height + ($image_height + $gap_height) * $row]
	    $graph create image $x $y -image $img -anchor nw
	    set x [expr $x + $image_width / 2]
	    set y [expr $y + $image_height + $gap_height * 5 / 12]
	    $graph create text $x $y -text [lindex $sub_title $level] -font $font_standard 
	}
	set x [expr $can_width / 2]
	set y [expr $title_height / 2]
	$graph create text $x $y -text $title -font $font_title -justify center
    }

    # layout_tiles --
    #
    # Return # columns (if ncols arg defined then this is result)
    # Also if both are undefined then set new_height & new_width

    proc layout_tiles {
	window_id
	nlevels
	ncols
	screen_height
	screen_width
	image_height
	image_width
	gap_height
	gap_width
	key_width
	title_height
	tick_length
	axis_text_width
    } {
        global Plot_nao::${window_id}::new_height
        global Plot_nao::${window_id}::new_width
	if {$ncols eq ""} {
	    set nc_min 1
	    set nc_max $nlevels
	} else {
	    set nc_min $ncols
	    set nc_max $ncols
	}
	if {$new_height < 0  &&  $new_width < 0} {
	    for {set step 1} {1} {incr step} {
		set min_area 1e9
		for {set nc $nc_min} {$nc <= $nc_max} {incr nc} {
		    set nrows [expr ($nlevels + $nc - 1) / $nc]
		    set new_height [expr ($image_height + $step - 1) / $step]
		    set new_width [expr ($image_width  + $step - 1) / $step]
		    set can_height [expr $title_height + $nrows * ($new_height + $gap_height)]
		    set can_width  [expr $nc * ($new_width + $gap_width) + $gap_width]
		    if {$key_width > 0} {
			incr can_width [expr $key_width + $tick_length + $axis_text_width]
		    }
		    if {$can_width <= $screen_width  &&  $can_height <= $screen_height} {
			set area [expr $can_height * $can_width]
			if {$area < $min_area} {
			    set min_area $area
			    set ncols $nc
			}
		    }
		}
		if {$ncols ne ""} {
		    return $ncols
		}
	    }
	} else {
	    set min_area_fits 1e9; # for case where fits on screen
	    set min_area 1e9; #  all cases
	    set ncols_fits ""
	    for {set nc $nc_min} {$nc <= $nc_max} {incr nc} {
		set nrows [expr ($nlevels + $nc - 1) / $nc]
		set can_height [expr $title_height + $nrows * ($new_height + $gap_height)]
		set can_width  [expr $nc * ($new_width + $gap_width) + $gap_width]
		if {$key_width > 0} {
		    incr can_width [expr $key_width + $tick_length + $axis_text_width]
		}
		set area [expr $can_height * $can_width]
		if {$area < $min_area} {
		    set min_area $area
		    set ncols $nc
		}
		if {$can_width <= $screen_width  &&  $can_height <= $screen_height  && \
			$area < $min_area_fits} {
		    set min_area_fits $area
		    set ncols_fits $nc
		}
	    }
	    if {$ncols_fits ne ""} {
		return $ncols_fits
	    } else {
		return $ncols
	    }
	}
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
	{allow_overlay 0}
    } {
        global Plot_nao::${window_id}::main_palette
	global Plot_nao::${window_id}::mapping
	global Plot_nao::${window_id}::overlay_nao
        global Plot_nao::${window_id}::overlay_palette
	upvar $name_result u
	set rank [$nao rank]
	if {$rank == 2} {
	    nap "u = u8((slope * nao + intercept) >>> y0 <<< y1)"
	} else {
	    nap "s = shape(nao)"
	    set n_layers [[nap "3 <<< s(0)"]]
	    nap "u = reshape(0u8, 0 // s{1 2})"
	    nap "slope = reshape(slope, n_layers)";         # In case scalar
	    nap "intercept = reshape(intercept, n_layers)"; # In case scalar
	    for {set i 0} {$i < $n_layers} {incr i} {
		nap "u = u // u8((slope(i) * nao(i,,) + intercept(i)) >>> y0 <<< y1)"
	    }
	}
	if {$mapping ne ""} {
	    nap "u = mapping(u)"
	}
	if {$main_palette ne ""  &&  $rank == 2} {
	    nap "rgb_mat = palette3(main_palette)"
	    if {[$rgb_mat nels] == 0} {
		handle_error "error calling NAP function palette3()"
		return
	    }
	    nap "u = (rgb_mat(,0))(u) /// (rgb_mat(,1))(u) // (rgb_mat(,2))(u)"
	}
	if {$allow_overlay} {
	    set_overlay $window_id $nao
	    if {$overlay_nao != ""} {
		nap "ov_rgb_mat = palette3(overlay_palette)"
		nap "ip = isPresent(overlay_nao)"
		if {[$u rank] == 2} {
		    nap "u = (ip ? (ov_rgb_mat(,0))(overlay_nao) : u) ///
			     (ip ? (ov_rgb_mat(,1))(overlay_nao) : u) //
			     (ip ? (ov_rgb_mat(,2))(overlay_nao) : u)"
		} else {
		    nap "n_layers = 3 <<< (shape(u))(0)"
		    nap "u = (ip ? (ov_rgb_mat(,0))(overlay_nao) : u(0,,)) ///
			     (ip ? (ov_rgb_mat(,1))(overlay_nao) : u(n_layers-2,,)) //
			     (ip ? (ov_rgb_mat(,2))(overlay_nao) : u(n_layers-1,,))"
		}
	    }
	}
    }

}
