set s 1r32
nap "xv = 0 .. 8 ... s"
nap "yv = (1 .. 10 ... s)(-)"
nap "x = reshape(xv, nels(yv) // nels(xv))"
nap "y = reshape(nels(xv) # yv, nels(yv) // nels(xv))"
$x set value _ "0 .. 31, 0 .. 31"
$y set value _ "-1 .. -64, 0 .. 63"
$y set coo yv xv
nap "p = {
{7 4 _}
{3 4 _}
{6 7 _}
{6 9 _}
{5 7 _}
{3 7 _}
{2 9 _}
{3 5 _}
{1 2 _}
}"
nap "i = inPolygon(x, y, p)"
