package require nap
namespace import ::NAP::*
    nap "mat = {
	{0.3 0 0.9}
	{0.5 1 0.8}
	{0.6 0 0.6}
	{0.8 2 0.0}
    }"
    $mat set coo "1 .. 4" "{10 20 40}"
    nap "y = {
        {0.3 0.3 0.3}
        {0.4 0.5 0.8}
    }"
    $y set coo "{3 5}" "{5 10 15}"
    nap "result = mat @ y"
    puts "result=[$result a]"


