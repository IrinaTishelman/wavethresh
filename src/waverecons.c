/*
 * waverecons:	Do 1D wavelet reconstruction
 */
#include <stdio.h>

#include "wavelet.h"

#define ACCESSC(l,r)    *(C + *(offsetC+(l)) + (r) - *(firstC+(l)))
#define ACCESSD(l,r)    *(D + *(offsetD+(l)) + (r) - *(firstD+(l)))


void waverecons(
    double *C,		/* Input data, and the subsequent smoothed data */
    Sint *LengthC,	/* Length of C array				*/
    double *D,		/* The wavelet coefficients			*/
    Sint *LengthD,	/* Length of D array				*/
    double *H,		/* The smoothing filter H			*/
    Sint *LengthH,	/* Length of smoothing filter			*/
    Sint *levels,	/* The number of levels in this decomposition	*/
    Sint *firstC,	/* The first possible C coef at a given level	*/
    Sint *lastC,	/* The last possible C coef at a given level	*/
    Sint *offsetC,	/* Offset from C[0] for certain level's coeffs	*/
    Sint *firstD,	/* The first possible D coef at a given level	*/
    Sint *lastD,	/* The last possible D coef at a given level	*/
    Sint *offsetD,	/* Offset from D[0] for certain level's coeffs	*/
    Sint *bc,		/* Which boundary handling are we doing	   */
    Sint *ierr		/* Error code					*/
    )
{
    register int next_level, at_level;
    register int verbose;	/* Printing messages, passed in ierr */

    if (*ierr == 1)
	verbose = 1;
    else
	verbose = 0;

    if (verbose)	{
	if ((int)*bc == PERIODIC)
	    Rprintf("Periodic boundary handling\n");
	else if ((int)*bc == SYMMETRIC)
	    Rprintf("Symmetric boundary handling\n");
	else	{
	    Rprintf("Unknown boundary handling\n");
	    *ierr = 2;
	    return;
	}
	Rprintf("Building level: ");
    }

    *ierr = 0;

    for(next_level = 1; next_level <= *levels; ++next_level)	{


	if (verbose)
	    Rprintf("%d ", next_level);

	at_level = next_level - 1;

	conbar( (C+*(offsetC+at_level)),
		(int)(*(lastC+at_level) - *(firstC+at_level) + 1),
		(int)(*(firstC+at_level)),
		(int)(*(lastC+at_level)),
		(D+*(offsetD+at_level)),
		(int)(*(lastD+at_level) - *(firstD+at_level) + 1),
		(int)(*(firstD+at_level)),
		(int)(*(lastD+at_level)),
		H,
		(int)*LengthH,
		(C+*(offsetC+next_level)),
		(int)(*(lastC+next_level) - *(firstC+next_level)+1),
                (int)(*(firstC+next_level)),
                (int)(*(lastC+next_level)),
		(int)(*bc) );
    }
    if (verbose)
	Rprintf("\n");

    return;
}
