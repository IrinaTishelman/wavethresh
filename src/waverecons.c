/*
 * waverecons:	Do 1D wavelet reconstruction
 */
#include <stdio.h>
#include "wavelet.h"

#define ACCESSC(l,r)    *(C + *(offsetC+(l)) + (r) - *(firstC+(l)))
#define ACCESSD(l,r)    *(D + *(offsetD+(l)) + (r) - *(firstD+(l)))


void waverecons(
    double *C,		/* Input data, and the subsequent smoothed data */
    long *LengthC,	/* Length of C array				*/
    double *D,		/* The wavelet coefficients			*/
    long *LengthD,	/* Length of D array				*/
    double *H,		/* The smoothing filter H			*/
    long *LengthH,	/* Length of smoothing filter			*/
    long *levels,	/* The number of levels in this decomposition	*/
    long *firstC,	/* The first possible C coef at a given level	*/
    long *lastC,	/* The last possible C coef at a given level	*/
    long *offsetC,	/* Offset from C[0] for certain level's coeffs	*/
    long *firstD,	/* The first possible D coef at a given level	*/
    long *lastD,	/* The last possible D coef at a given level	*/
    long *offsetD,	/* Offset from D[0] for certain level's coeffs	*/
    long *bc,		/* Which boundary handling are we doing	   */
    long *error		/* Error code					*/
    )
{
    register int next_level, at_level;
    register int verbose;	/* Printing messages, passed in error */

    if (*error == 1l)
	verbose = 1;
    else
	verbose = 0;

    if (verbose)	{
	if ((int)*bc == PERIODIC)
	    printf("Periodic boundary handling\n");
	else if ((int)*bc == SYMMETRIC)
	    printf("Symmetric boundary handling\n");
	else	{
	    printf("Unknown boundary handling\n");
	    *error = 2l;
	    return;
	}
	printf("Building level: ");
    }

    *error = 0l;

    for(next_level = 1; next_level <= *levels; ++next_level)	{


	if (verbose)
	    printf("%d ", next_level);

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
	printf("\n");

    return;
}
