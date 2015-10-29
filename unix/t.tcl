package require nap
namespace import ::NAP::*
for {set i 0} {$i < 999} {incr i} {
    puts $i
    nap "{3} ///  {2 9}"
}
