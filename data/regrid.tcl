# Regridding to geographic (latitude/longitude) grid
# from some other grid (e.g. DARLAM, satellite)

# You set following variables
# File containg latitude & longitude of each grid point
set LAT_LON_FILE lat_lon_60km.nc
# File containg input data
set IN_FILE darlam.nc
# File containg output data
set OUT_FILE geog.nc
# netCDF variable name for both input & output
set VAR tscrn

# Read latitude & longitude of each grid point
nap "lat_grid = [nap_get netcdf $LAT_LON_FILE latitude]"
nap "lon_grid = [nap_get netcdf $LAT_LON_FILE longitude]"

# Define latitude coordinate variable
nap "latitude = floor(min(min(lat_grid))) .. 
	ceil(max(max(lat_grid))) ... 0.5"
$latitude set dim latitude
$latitude set unit degrees_north

# Define longitude coordinate variable
nap "longitude = floor(min(min(lon_grid))) .. 
	ceil(max(max(lon_grid))) ... 0.5"
$longitude set dim longitude
$longitude set unit degrees_east

# Define inverse grid
nap "ig = invert_grid(lat_grid, latitude, lon_grid, longitude)"
$ig set dim latitude longitude yx

# Define time coordinate variable
nap "time = [nap_get netcdf $IN_FILE time]"

# Create file $OUT_FILE
file delete $OUT_FILE
$time netcdf -unlimited $OUT_FILE time
$latitude netcdf $OUT_FILE latitude
$longitude netcdf $OUT_FILE longitude
nap "darlam = [nap_get netcdf $IN_FILE $VAR "0,,"]"
nap "geog = reshape(darlam, 0 // nels(latitude) // nels(longitude))"
$geog set coo time latitude longitude
$geog set dim time latitude longitude
$geog netcdf $OUT_FILE $VAR

# Regrid data & write it to $OUT_FILE
foreach t [$time value] {
    nap "darlam = [nap_get netcdf $IN_FILE $VAR "@@t,,"]"
    nap "geog = darlam(ig)"
    $geog netcdf -index "@@t,," $OUT_FILE $VAR
}
