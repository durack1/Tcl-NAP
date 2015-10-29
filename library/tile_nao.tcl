# tile_nao.tcl --
#
# Copyright (c) 2002, CSIRO Australia
# Author: Harvey Davies, CSIRO.
# $Id: tile_nao.tcl,v 1.4 2002/11/29 00:09:40 dav480 Exp $

proc tile_nao {
    args
} {
    eval ::Tile_nao::tile_nao_proc $args
}

namespace eval Tile_nao {
    variable help_usage \
	    "Plot 3-D NAO as grid of coloured 'tiles' corresponding to levels.\
	    \n\
	    \nUsage\
	    \n  tile_nao <NAP expression> ?options?\
	    \n\
	    \nOptions are:\
	    \n  -border <distance>: width of border on paper (Default: 20m i.e. 20mm)\
	    \n  -columns <int>: Number of columns of tiles (Default: automatic)\
	    \n  -fill <0 or 1>: 1 = Scale PostScript to fill page. (Default: 0)\
	    \n  -gap_width <pixels>: width of vertical gaps between tiles (Default: 10)\
	    \n  -gap_height <pixels>: height of horizontal gaps between tiles (Default: 20)\
	    \n  -geometry <string>: If specified then use to create new toplevel window.\
	    \n  -help: Display this page\
	    \n  -key <pixels>: width of image-key. (Default: 30)\
	    \n  -overlay <NAP expression>: NAO defining coastlines, etc. (Default: none)\
	    \n  -palette <NAP expression>: Matrix defining color map. This has 3 or 4\
	    \n      columns & up to 256 rows.  If there are 4 columns then the first gives\
	    \n      color indices in range 0 to 255.  Values can be whole numbers in range 0\
	    \n      to 255 or fractional values from 0.0 to 1.0. (Default: blue-to-red)\
	    \n  -paper_height <distance>: paper height (default: \"297m\" i.e. 297 mm (A4))\
	    \n  -paper_width  <distance>: paper width  (default: \"210m\" i.e. 210 mm (A4))\
	    \n  -parent <string>: parent window (Default: \"\" i.e. create toplevel window)\
	    \n  -print <0 or 1>: 1 = automatic printing (for batch processing) (Default: 0)\
	    \n  -printer <string>: name (Default: env(PRINTER) if defined, else any printer)\
	    \n  -range <NAP expression>: defines scaling (Default: auto scaling)\
	    \n  -standard_font <font family>: Main font family (Default: courier)\
	    \n  -sub_title <LIST>: List of tile titles (Default: coordinate variable values)\
	    \n  -tick <pixels>: length of axis tick marks (Default: 5)\
	    \n  -title <string>: title (Default: NAO label (if any) else <NAP expression>)\
	    \n  -title_height <pixels>: (Default: 30)"

    # palette_interpolate --
    #
    # Define palette by interpolating round colour wheel (with s = v = 1)
    # from & to are angles in degrees (Red = 0, green = -240, blue = 240)
    #
    # 255 colours followed by white & black (257 in all)

    proc palette_interpolate {
	from
	to
    } {
	nap "n = 255"
	nap "h = ap_n(f32(from), f32(to), n)"
	nap "s = v = n # 1f32"
	nap "mat = transpose(hsv2rgb(h /// s // v))"
	nap "white = 3 # 1f32"
	nap "black = 3 # 0f32"
	nap "u8(255.999f32 * (mat // white // black))"
    }

    proc nao2image {
	mat
	range_nao
	palette
	{overlay ""}
    } {
	if {$overlay == ""} {
	    nap "overlay  = 1nf + mat"
	}
	nap "tol = 0.01f32";	# tolerance for rounding error
	nap "y0 = tol"
	nap "y1 = 255f32 - tol"
	nap "span = range_nao(1) - range_nao(0)"
	nap "slope = span == 0f32 ? 1f32 : (y1 - y0) / span"
	nap "intercept = y0 - slope * range_nao(0)"
	nap "i = i32(intercept + slope * (mat >>> range_nao(0) <<< range_nao(1)))"
	nap "i = isPresent(overlay) ? 256 : isPresent(mat) ? i : 255"
	nap "r = palette(,0)"
	nap "g = palette(,1)"
	nap "b = palette(,2)"
	nap "u = r(i) /// g(i) // b(i)"
	set imageName [image create photo -format NAO -data $u]
	return $imageName
    }

    proc tile_nao_proc {
	{nao_expr ""}
	args
    } {
	if {![info exists ::tk_version]} {
	    error "No tk! You should be running wish not tclsh!"
	}
	if [catch "uplevel 2 nap \"$nao_expr\"" nao] {
	    if {$nao_expr == ""  ||  [regexp -nocase {^-h} $nao_expr]} {
		puts $::Tile_nao::help_usage
		return
	    } else {
		error $nao
	    }
	}
	nap "nao = pad(nao)"
	if [[nap "rank(nao) != 3"]] {
	    error "rank of NAO is not 3!"
	}
	set nlevels [[nap "(shape(nao))(0)"]]
	::Print_gui::init
	catch "package require Img"
	set auto_print 0
	set border 20m; # 20 mm on each side
	set gap_height 20
	set gap_width 10
	set geometry ""
	set key_width 30
	set ncols [expr int(sqrt($nlevels))]
	while {$nlevels % $ncols > 0} {
	    incr ncols -1
	}
	set overlay ""
	nap "palette = palette_interpolate(240, 0)"; # blue to red
	set parent "."
	nap "range_nao = nao"
	set standard_font courier
	set sub_title [[$nao coo 0] value]
	set tick_length 5
	set title [$nao label]
	if {$title == ""} {
	    set title "$nao_expr"
	}
	set title_height 30
	set title_font helvetica
	set ::Print_gui::maxpect 0
	set i [process_options {
		{-border   	{set border $option_value}}
		{-columns	{set ncols $option_value}}
		{-fill     	{set ::Print_gui::maxpect $option_value}}
		{-gap_width 	{set gap_width $option_value}}
		{-gap_height 	{set gap_height $option_value}}
		{-geometry 	{set geometry $option_value}}
		{-help     	{puts $::Tile_nao::help_usage}}
		{-key		{set key_width $option_value}}
		{-overlay 	{nap "overlay = [uplevel 3 "nap \"$option_value\""]"}}
		{-palette 	{nap "palette = [uplevel 3 "nap \"$option_value\""]"}}
		{-paper_height  {set ::Print_gui::paperheight $option_value}}
		{-paper_width   {set ::Print_gui::paperwidth $option_value}}
		{-parent   	{set parent $option_value}}
		{-print   	{set auto_print $option_value}}
		{-printer 	{set ::Print_gui::printer_name $option_value}}
		{-range 	{nap "range_nao = [uplevel 3 "nap \"$option_value\""]"}}
		{-standard_font	{set standard_font $option_value}}
		{-sub_title   	{set sub_title $option_value}}
		{-tick   	{set tick_length $option_value}}
		{-title   	{set title $option_value}}
		{-title_font	{set title_font $option_value}}
		{-title_height	{set title_height $option_value}}
	    } $args]
	if {$i != [llength $args]} {
	    error "Illegal option"
	}

	set nrows [expr ($nlevels + $ncols - 1) / $ncols]
	set standard_font "-family $standard_font -size [expr -$gap_height / 2]"
	set title_font "-family $title_font -weight bold -size [expr -$title_height / 2]"
	nap "range_nao = range(range_nao)"
	nap "axis = scaleAxis(range_nao(0), range_nao(1), 10)"
	set n_ticks [$axis nels]
	set tmp [split [[nap "reshape(axis, n_ticks // 1)"] value] "\n"]
	for {set i 0} {$i < $n_ticks} {incr i} {
	    lappend axis_text " [lindex $tmp $i] "
	}
	unset tmp
	set axis_text_width [font measure $standard_font [lindex $axis_text 0]]
	set all [create_window tile_nao $parent $geometry tile_nao]
	set can $all.c
	for {set level 0} {$level < $nlevels} {incr level} {
	    set row [expr $level / $ncols]
	    set col [expr $level % $ncols]
	    nap "mat = nao(level,,)"
	    set img [nao2image $mat $range_nao $palette $overlay]
	    if {$level == 0} {
		# Create canvas & key
		set image_width  "[image width $img]"
		set image_height "[image height $img]"
		set can_height [expr $title_height + $nrows * ($image_height + $gap_height)]
		set can_width  [expr "$key_width + $tick_length + $axis_text_width
			+ $ncols * ($image_width + $gap_width)"]
		canvas $can -background white -width  $can_width -height $can_height
		set key_height [expr ($can_height - $title_height) / 2]
		nap "key_y = ap_n(range_nao(1), range_nao(0), key_height)"
		nap "key = transpose(reshape(key_y, key_width // key_height))"
		set key_img [nao2image $key $range_nao $palette]
		set x [expr $can_width - $tick_length - $axis_text_width]
		set y [expr $title_height + ($can_height - $title_height - $key_height) / 2]
		$can create image $x $y -image $key_img -anchor ne
		set xx [expr $x + $tick_length]
		for {set i 0} {$i < $n_ticks} {incr i} {
		    set yy [[nap "y + (key_y @@ axis(i))"]]
		    $can create line $x $yy $xx $yy
		    $can create text $can_width $yy -text [lindex $axis_text $i] -anchor e \
			    -font $standard_font
		}
	    }
	    set x [expr ($image_width + $gap_width) * $col]
	    set y [expr $title_height + ($image_height + $gap_height) * $row]
	    $can create image $x $y -image $img -anchor nw
	    set x [expr $x + $image_width / 2]
	    set y [expr $y + $image_height + $gap_height * 5 / 12]
	    $can create text $x $y -text [lindex $sub_title $level] -font $standard_font
	}
	set x [expr $can_width / 2]
	set y [expr $title_height / 2]
	$can create text $x $y -text $title -font $title_font
	pack $can
	set command "::Print_gui::canvas2ps $can $border $can_height $can_width"
	if {$auto_print} {
	    update idletasks
	    ::Print_gui::print $command
	    update idletasks
	    destroy $all
	} else {
	    ::Print_gui::widget $command
	}
    }

}
