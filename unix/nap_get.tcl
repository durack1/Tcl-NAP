package require nap
namespace import ::NAP::*
nap "in = [nap_get netcdf ../library/T.nc T "0, 0, @@(0 .. 120 ... 20)"]"
puts [$in v]
puts [[$in coo] v]
