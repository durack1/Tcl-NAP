package require nap
namespace import ::NAP::*

file delete v.nc
[nap 3..4] net v.nc v
nap "in = [nap_get net v.nc v]"
file delete v.nc
