#!/bin/sh
# $Header: /cvsroot/tcl-nap/tcl-nap/unix/pr_alloc.sh,v 1.2 2005/11/04 14:17:15 dav480 Exp $
# author: Harvey Davies, CSIRO Marine and Atmospheric Research, Melbourne

# Process stdout from "make test0" or "make test2" with napLib.c,m4 macro PR_MALLOC defined
# Uses pr_alloc.awk

tr -d '\015\032' | awk '{printf("%s %10d %s\n", $11, NR, $0)}' | sort | 
    awk -f pr_alloc.awk | awk '{print $9,"line",$6,$3,$10,"bytes. line",$2}' | sort |
    awk '{if ($0 == old) ++n; else {print n, "repeats of: ", old; old=$0; n=1}}'
