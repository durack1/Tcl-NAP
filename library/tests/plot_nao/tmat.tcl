source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

nap "m = reshape(ap(400,0,-2), {2 # 201})"
plot_nao m -geom -0+20 -range "{0 300}"
