/*
 * CONBAR: Does the reconstruction convolution
 */
#include "wavelet.h"

#define ACCESSC(c, firstC, lengthC, ix, bc) \
	*(c+reflect(((ix)-(firstC)),(lengthC), (bc)))

#define CEIL(i)	( ((i)>0) ? ( ((i)+1)/2):((i)/2) )

void conbar(
    double *c_in,
    int LengthCin,
    int firstCin,
    int lastCin,	/* Code probably doesn't need this */
    double *d_in,
    int LengthDin,
    int firstDin,
    int lastDin,
    double *H,
    int LengthH,
    double *c_out,
    int LengthCout,
    int firstCout,	/* This determines summation over n	*/
    int lastCout,	/* and this does too			*/
    int bc
    )
{
    register int n,k;
    double sumC, sumD;

/* Compute each of the output C */

    for(n=firstCout; n <= lastCout; ++n) {

	/* We want  n+1-LengthH <= 2*k to start off */

	k = CEIL(n+1-LengthH);

	sumC = 0.0;
	while( 2*k <= n )	{
	    sumC += *(H + n - 2*k) * ACCESSC(c_in, firstCin, LengthCin, k, bc);
	    ++k;
	}

	/* Now do D part */

	k = CEIL(n-1);

	sumD = 0.0;
	while( 2*k <= (LengthH +n -2) )	{
	    sumD += *(H+1+2*k-n) * ACCESSC(d_in, firstDin, LengthDin, k, bc);
	    ++k;
	}

	if (n & 1)		/* n odd */
	    sumC -= sumD;
	else
	    sumC += sumD;

	ACCESSC(c_out, firstCout, LengthCout, n, bc) = sumC;
    }
}
