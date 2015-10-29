source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

nap "m = reshape({0 255}, {5 5})"
nap "x = 1 .. 5"
nap "y = 1 .. 5"
$m set coo y x
plot_nao m -ty z -menu 0 -scaling 0
