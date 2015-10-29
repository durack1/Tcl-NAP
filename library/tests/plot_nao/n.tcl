source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

set window [plot_nao [nap_get ne tsu1961.nc tsu 0,,] -geom -0+20]

tkwait window $window
