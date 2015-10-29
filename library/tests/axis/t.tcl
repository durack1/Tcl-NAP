set x0 0
set f scaleAxis
set f scaleAxisSpan
set w(0) " "
set w(1) "*"
for {set nmax 2} {$nmax < 9} {incr nmax} {
    for {set x1 1.2} {$x1 < 2.001} {set x1 [expr $x1 + 0.1]} {
	# set x0 -$x1
	nap "a = f(x0, x1, nmax)"
	nap "r = (a(-1) - a(0)) / (x1 - x0)"
	set n [$a nels]
	set over [expr $n > $nmax]
	puts "$w($over) $x0 $x1 $nmax $n [$r]: [$a v]"
    }
}
