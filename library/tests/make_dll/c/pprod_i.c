/*
 *  This file was generated by tcl procedure 'make_dll_i'
 *  on 2004-11-12 at 16:52.
 *  It defines interface between tcl command 'pprod' and
 *  C/Fortran function/subroutine 'pprod'.
 */

#define USE_TCL_STUBS 1
#include <nap.h>

#undef  TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT

#define NUM_ARGS 3

int
PprodInt(
    ClientData          clientData,
    Tcl_Interp          *interp,
    int                 objc,
    Tcl_Obj *CONST      objv[])
{
    NapClientData       *nap_cd = Nap_GetClientData(interp);
    Nap_NAO             *naoArgPtr;
    Nap_NAO             *naoPtr[NUM_ARGS];
    char                *arg;

    if (objc == NUM_ARGS + 1) {
        arg = Tcl_GetStringFromObj(objv[1], NULL);
        naoArgPtr = Nap_GetNumericNaoFromId(nap_cd, arg);
        if (naoArgPtr) {
            naoPtr[0] = Nap_CastNAO(nap_cd, naoArgPtr, NAP_I32);
            Nap_IncrRefCount(nap_cd, naoPtr[0]);
            Nap_IncrRefCount(nap_cd, naoArgPtr);
            Nap_DecrRefCount(nap_cd, naoArgPtr);
        } else {
            Tcl_SetResult(interp,
                "pprod: Argument 1 (n) is not NAO\n", NULL);
            return TCL_ERROR;
        }
        arg = Tcl_GetStringFromObj(objv[2], NULL);
        naoArgPtr = Nap_GetNumericNaoFromId(nap_cd, arg);
        if (naoArgPtr) {
            naoPtr[1] = Nap_CastNAO(nap_cd, naoArgPtr, NAP_F32);
            Nap_IncrRefCount(nap_cd, naoPtr[1]);
            Nap_IncrRefCount(nap_cd, naoArgPtr);
            Nap_DecrRefCount(nap_cd, naoArgPtr);
        } else {
            Tcl_SetResult(interp,
                "pprod: Argument 2 (x) is not NAO\n", NULL);
            return TCL_ERROR;
        }
        arg = Tcl_GetStringFromObj(objv[3], NULL);
        naoPtr[2] = Nap_GetNaoFromId(nap_cd, arg);
        if (naoPtr[2]) {
            if (naoPtr[2]->dataType != NAP_F32) {
                Tcl_SetResult(interp,
                    "pprod: Argument 3 (y) is not F32\n", NULL);
                return TCL_ERROR;
            }
        } else {
            Tcl_SetResult(interp,
                "pprod: Argument 3 (y) is not NAO\n", NULL);
            return TCL_ERROR;
        }
        (void) pprod(
                naoPtr[0]->data.I32,
                naoPtr[1]->data.F32,
                naoPtr[2]->data.F32);
        Nap_DecrRefCount(nap_cd, naoPtr[0]);
        Nap_DecrRefCount(nap_cd, naoPtr[1]);
    } else {
        Tcl_WrongNumArgs(interp, 1, objv, "n x y");
        return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    return TCL_OK;
}

EXTERN int
Pprod_Init(
    Tcl_Interp          *interp)
{
    int                 status;

    if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
        status = TCL_ERROR;
    } else {
        Tcl_CreateObjCommand(interp, "pprod",  PprodInt, NULL, NULL);
        Tcl_PkgProvide(interp, "pprod", "1.0");
        Tcl_SetVar(interp, "pprod_version", "1.0", TCL_GLOBAL_ONLY);
        status = TCL_OK;
    }
    return status;
}

