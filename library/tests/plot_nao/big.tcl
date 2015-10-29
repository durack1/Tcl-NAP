source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

nap "n = 1500"
nap "x = n ... 0.0 .. 50.0"
nap "y = n ... 0.0 .. 50.0"
nap m = reshape(x, 2 # n)
$m set coo y x
set window [plot_nao m]

tkwait window $window
