package require nap
namespace import ::NAP::*
set ext hdf
set hdf_nc hdf
    file delete unlimited.$ext
    nap "time = f32 {}"
    $time set dim time
    $time $hdf_nc -unlimited unlimited.$ext time

    nap "time = f32{2}"
    $time set dim time
    $time $hdf_nc unlimited.$ext time

