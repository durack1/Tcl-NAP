package require nap
namespace import ::NAP::*
load ./nap4_0.dll

puts [[nap "psum1({
        {2 _ 1}
        {0 -1 5}
        {7 3 2}
    }, 1)"]]
