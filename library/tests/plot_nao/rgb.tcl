source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

nap "m = reshape(0f32 .. 999f32, {3 2 # 102})"
set window [plot_nao m -geom -0+20]

tkwait window $window
