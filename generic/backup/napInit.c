/* 
 * napInit.c --
 *
 * Copyright (c) 1999, CSIRO Australia
 *
 * Author: Harvey Davies, CSIRO Atmospheric Research
 */

#ifndef lint
static char *rcsid="@(#) $Id: napInit.c,v 1.21 2005/10/31 01:26:13 dav480 Exp $";
#endif /* not lint */

#include <signal.h>
#include "nap.h"
#include "nap_check.h"
#include "napInt.h"

#define DEBUG	/* So D(printf("stuff");) prints */
#undef DEBUG	/* So D(printf("stuff");) does nothing */
#ifdef DEBUG
#  define D(x) x
#else
#  define D(x)
#endif

/*
 * Nap_Divide --
 *
 *      Used to define infinity & NaN without compiler complaining
 *      about division by 0.
 */

static double
Nap_Divide(
    double              x,
    double              y)
{
    return x/y;
}

/*
 *  Nap_Init --
 *	Create 'nap' command.
 */

EXTERN int
Nap_Init(
    Tcl_Interp          *interp)
{
    Tcl_CmdDeleteProc   *d = NULL;
    NapClientData	*nap_cd;
    int			status;
    CONST char		*str;
    Tcl_Obj		*tcl_result;

    if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	return TCL_ERROR;
    }

    /*
     * Ignore floating-point errors, allowing infinity arithmetic.
     * Effect on integer arithmetic is platform-dependent.
     */

    signal(SIGFPE, SIG_IGN);

    napF32Inf = napF64Inf = Nap_Divide(1.0, 0.0);
    napF32NaN = napF64NaN = Nap_Divide(0.0, 0.0);
    nap_cd = Nap_CreateClientData(interp);
    Nap_CreateStandardMissingValues(nap_cd);
    (void) Tcl_CreateObjCommand(interp, "::NAP::nap",      Nap_Cmd,     (ClientData) nap_cd, d);
    (void) Tcl_CreateObjCommand(interp, "::NAP::nap_get",  Nap_GetCmd,  (ClientData) nap_cd, d);
    (void) Tcl_CreateObjCommand(interp, "::NAP::nap_info", Nap_InfoCmd, (ClientData) nap_cd, d);
    status = Tcl_Eval(interp, "namespace eval ::NAP:: {namespace export nap nap_get nap_info}");
    assert(status == TCL_OK);
    status = Tcl_PkgProvide(interp, "nap", VERSION);
    assert(status == TCL_OK);
    str = Tcl_SetVar(interp, "nap_version", VERSION, TCL_GLOBAL_ONLY);
    assert(str);
    str = Tcl_SetVar(interp, "nap_patchLevel", VERSION PATCHLEVEL, TCL_GLOBAL_ONLY);
    assert(str);

    /*
     * Tk stuff
     */

    if (Tcl_GetVar(interp, "tk_version", 0)) {
        Nap_CreatePhotoImageFormat();
    }

    /*
     * Initialize land_flag
     */

    status = Land_flag_Init(interp);
    assert(status == TCL_OK);

    /*
     * Initialize proj.4
     */

    if (! getenv("PROJ_LIB")) {
	status = Tcl_Eval(interp,
	    "set env(PROJ_LIB) [file join [file dirname $tcl_library] nap$nap_version data proj]");
	assert(status == TCL_OK);
    }

    /*
     * Initialize udunits
     *
     * Unit definitions are read from the file defined by the env. var. UDUNITS_PATH.
     * If this is not defined then unit definitions are read from the default file
     * "lib/nap?.?/data/udunits/udunits.dat".
     * Unit conversion can be suppressed by setting env. var. UDUNITS_PATH to "".
     */

    str = Nap_StrDup(getenv("UDUNITS_PATH"));
    if (!str) {
	status = Tcl_Eval(interp,
	    "file join [file dirname $tcl_library] nap$nap_version data udunits udunits.dat");
	assert(status == TCL_OK);
	tcl_result = Tcl_GetObjResult(interp);
	Tcl_IncrRefCount(tcl_result);
	str = Nap_StrDup(Tcl_GetString(tcl_result));
	Tcl_DecrRefCount(tcl_result);
    }
    if (str[0] && ! utIsInit()) {
	status = utInit(str);
	if (status) {
	    fprintf(stderr, "\nNo unit conversion will be done\n");
	}
    }
    FREE(str);

    return TCL_OK;
}
