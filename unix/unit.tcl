package require nap
namespace import ::NAP::*
nap "x = 3.0"
$x set unit feet
[nap "x + 2 'yard'"] q
$x a
nap "x = 3.0"
$x set unit feet
[nap "2 'yard' + x"] q
$x a

