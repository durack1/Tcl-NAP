#!/bin/ksh
# $Id: cif2nc.sh,v 1.1 2002/11/20 04:36:42 dav480 Exp $
# Author: Harvey Davies, CSIRO Atmospheric Research, Melbourne

wish << END-OF-FILE
nap "in = [nap_get netcdf $1 $2 $3]"
plot_nao in -print 1 -filename tmp.ps
lpr tmp.ps
exit
END-OF-FILE
lpr tmp.ps
