package require nap
namespace import ::NAP::*

    nap "lat = {{-40 -50 -60}{-30 -40 -50}{-20 -30 -40}}"
    nap "line = {40 50 60}"
    nap "pixel = {1 11 21}"
    $lat set coo line pixel
    nap "latc = {-40}"
    nap "lon = {{200 180 160}{180 160 140}{160 140 120}}"
    $lon set coo line pixel
    $lon set unit degrees_east
    nap "lonc = {200}"
    nap "yi = invert_grid(lat, latc, lon, lonc)"
    $yi v
