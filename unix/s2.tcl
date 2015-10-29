h
sou stdin.tcl
nap "x = open_box(xy 0)"
nap "y = open_box(xy 1)"
nap "xv = 401 ... -2e7 .. 2e7"
nap "yv = 201 ... 1e7 .. -1e7"
nap "ym = transpose(reshape(yv, {401 201}))"
nap "b = cart_proj_inv(xv, ym, 'proj=sinu')"
nap "lons = open_box(b 0)"
nap "lats = open_box(b 1)"
plot_nao lats
plot_nao lons
nap "i = lat @ lats"
nap "j = lon @ lons"
plot_nao i
plot_nao j
nap "ij = transpose(i /// j, {1 2 0})"
$ij a
plot_nao "m(ij)"
h