#include <stdio.h>

#include "wavelet.h"

#define ACCESSC(l,r)    *(C + *(offsetC+(l)) + (r) - *(firstC+(l)))
#define ACCESSD(l,r)    *(D + *(offsetD+(l)) + (r) - *(firstD+(l)))

void wavedecomp(
    double *C,          /* Input data, and the subsequent smoothed data */
    Sint *LengthC,      /* Length of C array                            */
    double *D,          /* The wavelet coefficients                     */
    Sint *LengthD,      /* Length of D array                            */
    double *H,          /* The smoothing filter H                       */
    Sint *LengthH,      /* Length of smoothing filter                   */
    Sint *levels,       /* The number of levels in this decomposition   */
    Sint *firstC,       /* The first possible C coef at a given level   */
    Sint *lastC,        /* The last possible C coef at a given level    */
    Sint *offsetC,      /* Offset from C[0] for certain level's coeffs  */
    Sint *firstD,       /* The first possible D coef at a given level   */
    Sint *lastD,        /* The last possible D coef at a given level    */
    Sint *offsetD,      /* Offset from D[0] for certain level's coeffs  */
    Sint *bc,		/* Method of boundary correction		*/
    Sint *ierr         /* Error code                                   */
    )
{
    register int next_level, at_level;
    register int verbose; /* Controls message printing, passed in ierr var*/

    if (*ierr == 1)
	verbose = 1;
    else
	verbose = 0;

    if (verbose)	{
	if (*bc == PERIODIC)
	    printf("Periodic boundary method\n");
	else if (*bc == SYMMETRIC)
	    printf("Symmetric boundary method\n");
	else	{
	    printf("Unknown boundary correction method\n");
	    *ierr = 1;
	    return;
	}
	printf("Decomposing into level: ");
    }

    *ierr = 0;

    for(next_level = *levels - 1; next_level >= 0; --next_level)    {

	if (verbose)
	    printf("%d ", next_level);

	at_level = next_level + 1;

	convolveC( (C+*(offsetC+at_level)),
		   (int)(*(lastC+ at_level) - *(firstC+at_level)+1),
		   (int)(*(firstC+at_level)),
		   H,
		   (int)*LengthH,
		   (C+*(offsetC+next_level)),
		   (int)(*(lastC+next_level) - *(firstC+next_level)+1),
		   (int)(*(firstC+next_level)),
		   (int)(*(lastC+next_level)) , (int)*bc);

	convolveD( (C+*(offsetC+at_level)),
		   (int)(*(lastC+ at_level) - *(firstC+at_level)+1),
		   (int)(*(firstC+at_level)),
		   H,
		   (int)*LengthH,
		   (D+*(offsetD+next_level)),
		   (int)(*(lastD+next_level) - *(lastD+next_level)+1),
		   (int)(*(firstD+next_level)),
		   (int)(*(lastD+next_level)), (int)*bc );
    }
    if (verbose)
	printf("\n");
    return;
}
