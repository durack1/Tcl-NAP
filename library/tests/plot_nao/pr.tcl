nap "x = 200 ... 0 .. 4p"
nap "y = sin x"
$y set coo x
plot_nao y -print 1; # print on default printer
plot_nao y -print 1 -filename sin.ps; # write postscript file sin.ps
plot_nao y -print 1 -filename sin.jpeg; # write JPEG image file sin.jpeg
