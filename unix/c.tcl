package require nap
namespace import ::NAP::*

nap "vu = {1.5 -1 7.5}"
$vu set unit mm
$vu unit
[nap "count vu"] unit
