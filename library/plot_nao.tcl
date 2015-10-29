# plot_nao.tcl --
# 
# Copyright (c) 2001, CSIRO Australia
# Author: Harvey Davies, CSIRO Atmospheric Research
# $Id: plot_nao.tcl,v 1.123 2002/01/24 06:58:41 dav480 Exp $
#
# This defines global cover procedure plot_nao which calls Plot_nao::plot_nao which
# is defined in file plot_nao_procs.tcl
#
# Usage
#   See proc help_usage
#
# This is defined in a separate file to facilitate re-definition (e.g. with different defaults)

proc plot_nao {
    args
} {
    eval ::Plot_nao::plot_nao $args
}
