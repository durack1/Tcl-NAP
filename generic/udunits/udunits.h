/*
 * $Id: udunits.h,v 1.4 2005/11/06 22:27:58 dav480 Exp $
 *
 * Public header-file for the Unidata units(3) library.
 */

#ifndef UT_UNITS_H_INCLUDED
#define UT_UNITS_H_INCLUDED

#define UT_NAMELEN              32      /* maximum length of a unit string
					 * (including all prefixes and EOS) */

/*
 *	Macro for declaring functions regardless of the availability of 
 *	function prototypes.  NB: will need double parens in actual use (e.g.
 *	"int func PROTO((int a, char *cp))").
 */
#ifndef	PROTO
#	define	PROTO(a)	a
#endif


#define	UT_EOF		 1	/* end-of-file encountered */
#define	UT_ENOFILE	-1	/* no units-file */
#define	UT_ESYNTAX	-2	/* syntax error */
#define	UT_EUNKNOWN	-3	/* unknown specification */
#define	UT_EIO		-4	/* I/O error */
#define	UT_EINVALID	-5	/* invalid unit-structure */
#define	UT_ENOINIT	-6	/* package not initialized */
#define	UT_ECONVERT	-7	/* two units are not convertable */
#define	UT_EALLOC	-8	/* memory allocation failure */
#define UT_ENOROOM	-9	/* insufficient room supplied */
#define UT_ENOTTIME	-10	/* not a unit of time */
#define UT_DUP		-11	/* duplicate unit */

#define UT_MAXNUM_BASE_QUANTITIES	10

typedef double	UtOrigin;	/* origin datatype */
typedef double	UtFactor;       /* conversion-factor datatype */

/*
 *  Unit-structure:
 */
typedef struct utUnit {
    UtOrigin	origin;		/* origin */
    UtFactor    factor;         /* multiplicative scaling factor (e.g. the 
				 * "2.54" in "2.54 cm") */
    int		hasorigin;	/* unit has origin? */
    double      power[UT_MAXNUM_BASE_QUANTITIES];
				/* exponents of basic units */
} utUnit;


/*
 *  Initialize the units(3) package.
 */
extern int	utInit		PROTO((
    const char	*path
));

/*
 *	Return pointer to string message corresponding to error n.
 */
    char *
utStrError(
    int		n)
;

/*
 *	Decode a formatted unit specification into a unit-structure.
 */
extern int	utScan		PROTO((
    const char	*spec,
    utUnit	*up
));

/*
 *	Convert a temporal value into a UTC Gregorian date and time.
 */
extern int	utCalendar	PROTO((
    double	value,
    utUnit	*unit,
    int		*year,
    int		*month,
    int		*day,
    int		*hour,
    int		*minute,
    float	*second
));

/*
 *	Convert a date into a temporal value.  The date is assumed to
 *	use the Gregorian calendar if on or after noon, October 15, 1582;
 *	otherwise, the date is assumed to use the Julian calendar.
 */
extern int	utInvCalendar	PROTO((
    int		year,
    int		month,
    int		day,
    int		hour,
    int		minute,
    double	second,
    utUnit	*unit,
    double	*value
));

/*
 *	Indicate if a unit structure refers to a unit of time.
 */
extern int	utIsTime	PROTO((
    const utUnit	*up
));

/*
 *	Indicate if a unit structure has an origin.
 */
extern int	utHasOrigin	PROTO((
    const utUnit	*up
));

/*
 *	Clear a unit structure.
 */
extern utUnit*	utClear		PROTO((
    utUnit	*unit
));

/*
 *  Check whether unit structure has above clear state corresponding to the dimensionless
 *  identity unit structure.
 */
extern int utIsClear		PROTO((
    utUnit	*unit
));

/*
 *	Copy a unit-strcture.
 */
extern utUnit*	utCopy		PROTO((
    const utUnit	*source,
    utUnit		*dest
));

/*
 *	Multiply one unit-structure by another.
 */
extern utUnit*	utMultiply	PROTO((
    utUnit	*term1,
    utUnit	*term2, 
    utUnit	*result
));

/*
 *	Divide one unit-structure by another.
 */
extern utUnit*	utDivide	PROTO((
    utUnit	*numer,
    utUnit	*denom, 
    utUnit	*result
));

/*
 *	Form the reciprocal of a unit-structure.
 */
extern utUnit*	utInvert	PROTO((
    utUnit	*source,
    utUnit	*dest
));

/*
 *	Raise a unit-structure to a power.
 */
extern utUnit*	utRaise		PROTO((
    utUnit	*source,
    double	power,
    utUnit	*result
));

/*
 *	Shift the origin of a unit-structure by an arithmetic amount.
 */
extern utUnit*	utShift		PROTO((
    utUnit	*source,
    double	amount,
    utUnit	*result
));

/*
 *	Scale a unit-structure.
 */
extern utUnit*	utScale		PROTO((
    utUnit	*source,
    double	factor,
    utUnit	*result
));

/*
 *	Compute the conversion factor between two unit-structures.
 */
extern int	utConvert	PROTO((
    const utUnit	*from,
    const utUnit	*to,
    double		*slope,
    double		*intercept
));

/*
 *	Encode a unit-structure into a formatted unit-specification.
 */
extern int	utPrint		PROTO((
    const utUnit	*unit,
    char		**buf
));

/*
 *  Add a unit-structure to the units-table.
 */
extern int	utAdd		PROTO((
    char	*name,
    int		HasPlural,
    utUnit	*unit
));

/*
 *  Return the unit-structure corresponding to a unit-specification.
 *
 */
extern int	utFind		PROTO((
    char	*spec,
    utUnit	*up
));

/*
 *	Terminate use of this package.
 */
extern void	utTerm		PROTO(());

#endif	/* UT_UNITS_H_INCLUDED not defined */
