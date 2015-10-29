/* 
 * nap_check.h --
 *
 * Define macros for error handling using macros CHECK, CHECK2, CHECK3, ...
 * Also define memory allocation macros MALLOC, MALLOC0, REALLOC, FREE.
 *
 * Copyright (c) 1997, CSIRO Australia
 *
 * Author: Harvey Davies, CSIRO Mathematical and Information Sciences
 *
 * $Id: nap_check.h,v 1.17 2002/05/14 00:32:03 dav480 Exp $
 */

#include <tcl.h>
#include "nap.h"

#ifndef _NAP_CHECK
#define _NAP_CHECK

#ifndef TRUE
#define TRUE 1
#endif /* TRUE */

#ifndef FALSE
#define FALSE 0
#endif /* FALSE */

#ifndef TCL_OK
#define TCL_OK 0
#endif /* TCL_OK */

#ifndef TCL_ERROR
#define TCL_ERROR 1
#endif /* TCL_ERROR */

#ifndef MALLOC
#define MALLOC(n) Nap_Alloc(n)
#endif /* MALLOC */

#ifndef MALLOC0
#define MALLOC0(n) Nap_Alloc0(n)
#endif /* MALLOC0 */

#ifndef REALLOC
#define REALLOC(p, n)	Nap_Realloc((void *) p), n)
#endif /* REALLOC */

#ifndef FREE
#define FREE(p) Nap_Free((void *) p)
#endif /* FREE */

/*
 *  CHECK_PRE & CHECK_POST can be defined to do error handling, etc.
 *  See nap_hdf.c,m4 for example
 */

#ifndef CHECK_PRE
#define CHECK_PRE
#endif /* CHECK_PRE */

#ifndef CHECK_POST
#define CHECK_POST
#endif /* CHECK_POST */

#define CHECK(OK) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, ""); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK2(OK, FORMAT) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK3(OK, FORMAT, A) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK4(OK, FORMAT, A, B) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK5(OK, FORMAT, A, B, C) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK6(OK, FORMAT, A, B, C, D) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK7(OK, FORMAT, A, B, C, D, E) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D, E); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK8(OK, FORMAT, A, B, C, D, E, F) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D, E, F); \
	CHECK_POST \
	return TCL_ERROR; \
    }

#define CHECK1NULL(OK) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, ""); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK2NULL(OK, FORMAT) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK3NULL(OK, FORMAT, A) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK4NULL(OK, FORMAT, A, B) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK5NULL(OK, FORMAT, A, B, C) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK6NULL(OK, FORMAT, A, B, C, D) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK7NULL(OK, FORMAT, A, B, C, D, E) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D, E); \
	CHECK_POST \
	return NULL; \
    }

#define CHECK8NULL(OK, FORMAT, A, B, C, D, E, F) \
    if (! (OK)) { \
	CHECK_PRE \
	Nap_Check(nap_cd, __FILE__, __LINE__, FORMAT, A, B, C, D, E, F); \
	CHECK_POST \
	return NULL; \
    }

/* Nap_error is error handler called by yacc/bison */
#define Nap_error(message) \
    Nap_Check(Nap_param, __FILE__, __LINE__, message)

/*
 *  CHECK_NUM_ARGS provides interface to Tcl_WrongNumArgs.
 *  Assume objv contains arguments.
 *  Error message contains first N elements of objv followed by MSG.
 *  Example:
 *    CHECK_NUM_ARGS(objc > 1, 1, "<SUB-COMMAND> ...");
 */

#define CHECK_NUM_ARGS(OK, N, MSG) \
    if (! (OK)) { \
	Tcl_WrongNumArgs(nap_cd->interp, N, objv, MSG); \
	CHECK3(0, "%s", Tcl_GetStringResult(nap_cd->interp)); \
    }

EXTERN void	Nap_Check(NapClientData *nap_cd, const char *file, const int line,
			const char *format, ...);
EXTERN void	Nap_CheckAppendLine(NapClientData *nap_cd, const char *str);
EXTERN void	*Nap_Alloc(size_t size);
EXTERN void	*Nap_Alloc0(size_t size);
EXTERN void	Nap_Free(void *p);

#endif /* _NAP_CHECK */
