source ~/.tclshrc
source ~/tcl/nap/library/land.tcl
nap "lat = 90 .. -90"
nap "lon = -180 .. 180"
nap "m = is_land(lat, lon)"
nap "latmat = transpose(reshape(lat, {361 181}))"
nap "xy = cart_proj_fwd(lon, latmat, 'proj=sinu')"
