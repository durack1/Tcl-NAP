package require nap
namespace import ::NAP::*

nap "new = [nap_get hdf newchunk.hdf warpedInterpolated_satelliteAzimuthGrid]"
nap "p = prune(new)"
$p hdf full_out.hdf warpedInterpolated_satelliteAzimuthGrid
