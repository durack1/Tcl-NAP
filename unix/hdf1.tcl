package require nap
namespace import ::NAP::*

set hdf_nc hdf
set ext hdf

nap "b = [nap_get $hdf_nc hdf1.$ext abc "0 .. 1"]"
