/* Access an element in an image */
#define ACCESS(image, size, i, j)       *(image + (i)*(size) + (j))

#include <stdio.h>
#include <stdlib.h>

#include "wavelet.h"

void StoIRS(
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    Sint *LengthCin, Sint *firstCin, Sint *lastCin,
    Sint *LengthDin, Sint *firstDin, Sint *lastDin,
    double *H,
    Sint *LengthH,
    Sint *LengthCout, Sint *firstCout, Sint *lastCout,
    double *ImOut,
    Sint *bc,
    Sint *ierr
    )
{
    *ierr = 0;

    ImageReconstructStep(ImCC, ImCD, ImDC, ImDD,
			 *LengthCin, *firstCin, *lastCin,
			 *LengthDin, *firstDin, *lastDin,
			 H, *LengthH,
			 *LengthCout, *firstCout, *lastCout,
			 ImOut, bc,
			 ierr);
}

void ImageReconstructStep(
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    Sint LengthCin, Sint firstCin, Sint lastCin,
    Sint LengthDin, Sint firstDin, Sint lastDin,
    double *H,
    Sint LengthH,
    Sint LengthCout, Sint firstCout, Sint lastCout,
    double *ImOut,
    Sint *bc,
    Sint *ierr
    )
{
    register int i,j;
    double *c_in;
    double *d_in;
    double *c_out;
    double *toC;
    double *toD;

/* Get memory for c_in and d_in */

    if ((c_in = (double *)malloc((unsigned)LengthCin*sizeof(double)))==NULL) {
	*ierr = 1;
	return;
    }

    if ((d_in = (double *)malloc((unsigned)LengthDin*sizeof(double)))==NULL) {
	*ierr = 2;
	return;
    }

    if ((c_out = (double *)malloc((unsigned)LengthCout*sizeof(double)))==NULL) {
	*ierr = 3;
	return;
    }

    if ((toC = (double *)malloc((unsigned)LengthCin*LengthCout*sizeof(double)))
	== NULL)	{
	*ierr = 4;
	return;
    }

/* Now apply C and D filters to CC and CD to obtain toC */

    for(i=0; i<LengthCin; ++i)	{

	for(j=0; j < LengthDin; ++j)
	    *(d_in + j) = ACCESS(ImCD, (int)LengthCin, j, i);

	for(j=0; j < LengthCin; ++j)
	    *(c_in + j) = ACCESS(ImCC, (int)LengthCin, j, i);

	conbar(c_in, (int)LengthCin, (int)firstCin, (int)lastCin,
	       d_in, (int)LengthDin, (int)firstDin, (int)lastDin,
	       H, (int)LengthH,
	       c_out, (int)LengthCout, (int)firstCout, (int)lastCout, (int)*bc);

	for(j=0; j < LengthCout; ++j)
	    ACCESS(toC, (int)LengthCout, i, j) = *(c_out+j);
    }

/* Now magically we can use c_in and d_in again, but we now need a toD
 * to store the answer in */

    if ((toD = (double *)malloc((unsigned)LengthDin*LengthCout*sizeof(double)))
	== NULL)	{
	*ierr = 5;
	return;
    }

/* Now apply C and D filters to DC and DD to obtain toD */

    for(i=0; i<LengthDin; ++i)      {

        for(j=0; j < LengthDin; ++j)
	    *(d_in + j) = ACCESS(ImDD, (int)LengthDin, j, i);

        for(j=0; j < LengthCin; ++j)
	    *(c_in + j) = ACCESS(ImDC, (int)LengthDin, j, i);

        conbar(c_in, (int)LengthCin, (int)firstCin, (int)lastCin,
               d_in, (int)LengthDin, (int)firstDin, (int)lastDin,
               H, (int)LengthH,
               c_out, (int)LengthCout, (int)firstCout, (int)lastCout, (int)*bc);

        for(j=0; j < LengthCout; ++j)
	    ACCESS(toD, (int)LengthCout, i, j) = *(c_out+j);
    }


/* Now apply C and D filters to toC and toD to get ImOut */

    for(i=0; i<LengthCout; ++i)	{

	for(j=0; j< LengthDin; ++j)
	    *(d_in + j) = ACCESS(toD, (int)LengthCout, j, i);

	for(j=0; j<LengthCin; ++j)
	    *(c_in + j) = ACCESS(toC, (int)LengthCout, j, i);

	conbar(c_in, (int)LengthCin, (int)firstCin, (int)lastCin,
               d_in, (int)LengthDin, (int)firstDin, (int)lastDin,
               H, (int)LengthH,
               c_out, (int)LengthCout, (int)firstCout, (int)lastCout, (int)*bc);

	for(j=0; j<LengthCout; ++j)
	    ACCESS(ImOut, (int)LengthCout, i, j)  = *(c_out+j);
    }
}
