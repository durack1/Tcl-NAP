switch $::tcl_platform(platform) {
    unix	{load ./libpprod.so}
    windows	{load ./pprod.dll}
}

proc partialProd x {
    set result [nap "reshape(0f, shape(x))"]
    pprod  "nels(x)" x result
    return $result
}

puts_file out.txt [[nap "partialProd({2 1.5 3 0.5})"]]
