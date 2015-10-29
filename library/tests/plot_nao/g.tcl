source ../../plot_nao.tcl
source ../../plot_nao_procs.tcl

nap "m = {100#{100#0}100#{100#255}}"
nap "x = 101 .. 200"
nap "y = 501 .. 700"
$m set coo y x
plot_nao m

nap "mm = +m"
$mm set coo -y -x
plot_nao mm
