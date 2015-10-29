package require nap
namespace import ::NAP::*
interp create i
load {} nap i
interp eval i {NAP::nap "a = 3"}
interp eval i {$a}
interp delete i
