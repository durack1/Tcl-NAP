source gshhs.tcl
source plot_nao_procs.tcl
source proj4.tcl
nap "in = [nap_get net ../uv.nc u 0,0,,]"
time {plot_nao in}
