nap "n = 200"
nap "x = n ... 0.0 .. 10.0"
nap "y = x(-)"
nap "z = sin(x) * sin(reshape(n#y, 2#n))"
$z set coo y x
plot_nao z
plot_nao z -zticks "-1 .. 1 ... 0.2" -discrete 1
plot_nao "nint(z+1)" -zlabels {{zero (0)} {one (1)} {two}}
