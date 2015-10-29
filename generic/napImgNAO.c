/*
 * napImgNAO.c --
 *
 *      A photo image file handler for Numeric Array Objects (NAO's).
 *      At present there is no write function.
 *
 * NAO's are structures containing binary data. They are only available when
 * Tcl/Tk has the Numerical Array Processor (NAP) extension.
 *
 * Copyright (c) 1998, CSIRO Australia
 *
 * Author:     P.J. Turner, CSIRO Atmospheric Research
 */

#ifndef lint
static char *rcsid="@(#) $Id: napImgNAO.c,v 1.24 2002/05/14 00:32:03 dav480 Exp $";
#endif /* not lint */

#include <tk.h>
#include "nap.h"
#include "nap_check.h"

/*
 * StringMatchNAO --
 *
 *  This procedure is invoked by the photo image type to see if
 *  a string contains image data in NAO format.
 *
 * Results:
 *  The return value is 1 if the first characters in the string
 *  are like NAO, and 0 otherwise.
 *
 * Side effects:
 *  the size of the image is placed in widthPtr and heightPtr.
 */

static int
StringMatchNAO(
    Tcl_Obj	*nap_expr,	/* string containing NAP expression */
    Tcl_Obj	*format,	/* not used */
    int		*widthPtr,
    int		*heightPtr,
    Tcl_Interp	*interp)
{
    Nap_NAO *nao;
    NapClientData *nap_cd = Nap_GetClientData(interp);

    nao = Nap_GetNaoFromObj(nap_cd, nap_expr);
    if (!nao) {
	return 0;
    }
    switch (nao->rank) {
    case 2:
	assert(nao->shape);
        *widthPtr = nao->shape[1]; 
        *heightPtr = nao->shape[0]; 
	break;
    case 3:
	assert(nao->shape);
        *widthPtr = nao->shape[2]; 
        *heightPtr = nao->shape[1]; 
	break;
    default:
	return 0;
    }
    return 1;
}


/*
 * StringReadNAO -- --
 *
 *	This procedure is called by the photo image type to read
 *	NAO data and give it to the photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	new data is added to the image given by imageHandle.  This
 *	procedure calls FileReadGif by redefining the operation of
 *	fprintf temporarily.
 */

static int
StringReadNAO(
    Tcl_Interp		*interp,
    Tcl_Obj		*nap_expr,	/* string containing NAP expression */
    Tcl_Obj		*format,	/* format string not used */
    Tk_PhotoHandle	imageHandle,
    int			destX,
    int			destY,
    int			width,
    int			height,
    int			srcX,
    int			srcY)
{
    int			naoWidth;
    int			naoHeight;
    int			naoDepth;
    int			rank;
    Tk_PhotoImageBlock	block;
    Nap_NAO		*oldnao;
    Nap_NAO		*newnao;
    NapClientData	*nap_cd = Nap_GetClientData(interp);

/*
 * Open the NAO and return the dimensions!
 */

    oldnao = Nap_GetNaoFromObj(nap_cd, nap_expr);
    if(!oldnao) return(0);

    rank = oldnao->rank;

    switch (rank) {
    case 2:
        naoWidth = oldnao->shape[1]; 
        naoHeight = oldnao->shape[0]; 
	break;
    case 3:
        naoWidth = oldnao->shape[2]; 
        naoHeight = oldnao->shape[1]; 
        naoDepth = oldnao->shape[0];
	break;
    default:
	return TCL_ERROR;
    }

/*
 * If the nao is not a type byte then make a new nao of type byte
 */

    if(oldnao->dataType == NAP_U8) {
        newnao = oldnao;
    } else {
        newnao = Nap_CastNAO(nap_cd, oldnao, NAP_U8);
    }

/*
 * Setup the dimensions for the display
 */

    if ((srcX + width) > naoWidth) {
        width = naoWidth - srcX;
    }  
    if ((srcY + height) > naoHeight) {
        height = naoHeight - srcY;
    }
    if ((width <= 0) || (height <= 0)
            || (srcX >= naoWidth) || (srcY >= naoHeight)) {
        return TCL_OK;
    }

/*
 * Get the output window open to the correct size
 */

    Tk_PhotoExpand(imageHandle, destX + width, destY + height);


/*
 * setup the supporting image data structure
 */

    block.width = naoWidth;
    block.height = naoHeight;
    block.pitch = naoWidth;     /* Address difference between corresponding
                                 * pixels in successive lines */
    block.pixelSize = 1;	/* Address difference successive pixels
                                 * in the same line */
      /* Address differences between the red, green
                                 * and blue components of the pixel and the
                                 * pixel as a whole. */

    block.offset[0] = 0;  
    block.offset[1] = 0;
    block.offset[2] = 0;
    if (rank == 3) {
        if(naoDepth >= 3) {
            block.offset[1] = naoHeight*naoWidth;
            block.offset[2] = 2 * naoWidth*naoHeight;
        } else if(naoDepth == 2) {
            block.offset[2] =  naoWidth*naoHeight;
        }
    }   

    /* Pointer to the first part of the first pixel */
    block.pixelPtr = (unsigned char *) newnao->data.U8;

    Tk_PhotoPutBlock(imageHandle, &block, destX, destY, naoWidth, naoHeight);
    if(newnao != oldnao) {
        Nap_FreeNAO(nap_cd, newnao);
    }

    return TCL_OK;
}

/*
 * FileWriteNAO --
 *
 *	This procedure is called by the photo image type to write
 *	photo image data into a NAO.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	a new NAO is created.
 */

static int
FileWriteNAO(
    Tcl_Interp		*interp,
    CONST char		*naoName,
    Tcl_Obj		*format,
    Tk_PhotoImageBlock	*blockPtr)
{
    register long w, h,pixelSize;
    long greenOffset, blueOffset;
    unsigned char *pixelPtr, *pixLinePtr;
    char *str;
    Nap_NAO *naoPtr; 
    size_t shape[3];
    register Nap_u8 *red,*green,*blue;
    NapClientData *nap_cd = Nap_GetClientData(interp);
 
    shape[0] = 3;
    shape[1] = blockPtr->height;
    shape[2] = blockPtr->width;
    naoPtr = Nap_NewNAO(nap_cd, NAP_U8, 3, shape);
    CHECK2(naoPtr,"FileWriteNAO: error calling Nap_NewNAO");
    str = Nap_Assign(nap_cd, (char *) naoName, naoPtr->id);
    CHECK2(str,"FileWriteNAO: error calling Nap_Assign");
    pixLinePtr = blockPtr->pixelPtr + blockPtr->offset[0];
    greenOffset = blockPtr->offset[1] - blockPtr->offset[0];
    blueOffset = blockPtr->offset[2] - blockPtr->offset[0];
    red = naoPtr->data.U8; 
    green = red + shape[1]*shape[2];
    blue = green + shape[1]*shape[2];

/* red,green,blue,red,green,blue,red.... */

/*
 * Terribly inefficient write process
 */

    pixelSize = blockPtr->pixelSize;
    for (h = blockPtr->height; h > 0; h--) {
        pixelPtr = pixLinePtr;
        for (w = blockPtr->width; w > 0; w--) {
            *red = pixelPtr[0];
            *green = pixelPtr[greenOffset];
            *blue = pixelPtr[blueOffset];
            pixelPtr = pixelPtr + pixelSize;
            red++; green++; blue++;
        }
        pixLinePtr = pixLinePtr + blockPtr->pitch;
    }
    return TCL_OK;
}


/*
 *  Nap_CreatePhotoImageFormat --
 */

EXTERN void
Nap_CreatePhotoImageFormat(void)
{
    Tk_PhotoImageFormat napImgFmtNAO = {
	    "nao",		/* name */
	    NULL,		/* fileMatchProc  not applicable to NAO's */
	    StringMatchNAO,	/* stringMatchProc */
	    NULL,		/* fileReadProc  not applicable to NAO's */
	    StringReadNAO,	/* stringReadProc */
	    FileWriteNAO,	/* fileWriteProc */
	    NULL		/* stringWriteProc not implimented */
    };
    Tk_CreatePhotoImageFormat(&napImgFmtNAO);
}
