package require nap
namespace import ::NAP::*

proc lookup {
    i
} {
    nap "ich0  = u32('0'(0))"
    nap "ich9  = u32('9'(0))"
    nap "ichcz = u32('Z'(0))"
    nap "ichca = u32('A'(0))"
    nap "ichla = u32('a'(0))"
    nap "u32(i - (i < ich0 ? i : i <= ich9 ? ich0 : i <= ichcz ? ichca - 10 : ichla - 36))"
}

nap "l = lookup(0..255)"
nap "i = #l"

