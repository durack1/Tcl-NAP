package require nap
namespace import ::NAP::*
source ../library/bin_io.tcl
source ../library/nap_proc_lib.tcl
nap "m = reshape(1 .. 6, {2 3})"
$m set coo "{20 30}" "{60.0 70 90}"
set f [open m.cif w]
put_cif1 $m $f
close $f
