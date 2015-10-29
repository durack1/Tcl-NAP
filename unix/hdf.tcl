package require nap
namespace import ::NAP::*

set hdf_nc netcdf
set ext nc

nap "a = {{100f 110f}{100.5f 109f}}"
$a $hdf_nc geog.$ext scaled_mat -datatype i16 -scale 0.1 -offset 5
nap_get $hdf_nc geog.$ext scaled_mat {} 1
