/*
 * ImageDecomposeStep	-	Take an image and do a one level decomp
 *
 * Error Codes
 *
 *	0	-	Ok.
 *
 *	1	-	Memory error for (afterC) temporary image
 *
 *	2	-	Memory error for (afterD) temporary image
 *
 *	3	-	Memory error for (ccopy) temporary row store
 *
 *	4	-	Memory error for (ccopy_out) temporary row store
 *
 *	5	-	Memory error for (dcopy_out) temporary row store
 *
 *	6-9	-	Memory errors for (afterCC,afterCD,afterDC,afterDD)
 *			store for the answers
 */

#include <stdio.h>
#ifndef Macintosh
#include <malloc.h>
#endif
#include "wavelet.h"

/* Access an element in an image */
#define ACCESS(image, size, i, j)       *(image + (i)*(size) + (j))

void ImageDecomposeStep(
    double *C,	/* Input data image					*/
    Sint Csize,	/* Size of image (side length)				*/
    Sint firstCin,/* Index number of first element in input "C" image	*/
    double *H,	/* Filter coefficients					*/
    Sint LengthH,	/* Length of filter				*/

/* Details about output image */
    Sint LengthCout,/* Length of C part of output image			*/
    Sint firstCout,/* Index number of first element in output "C" image */
    Sint lastCout,	/* Index number of last element			*/
    Sint LengthDout,/* Length of D part of output image			*/
    Sint firstDout,	/* Index number of first element in output "D" image */
    Sint lastDout,	/* Index number of last element			*/
    double **cc_out,/* Smoothed output image				*/
    double **cd_out,/* Horizontal detail				*/
    double **dc_out,/* Vertical detail					*/
    double **dd_out,/* Diagonal detail					*/
    Sint bc,	/* Method of boundary correction			*/
    Sint *ierr	/* Error code						*/
    )
{
register int j,row,col;
double *ccopy;	/* Used to copy input data to convolution routines	*/
double *ccopy_out;/* Used to copy output data to afterC after conv.	*/
double *dcopy_out;/* Used to copy output data to afterD after conv.	*/
double *afterC;	/* Temporary store for image data after C convolution	*/
double *afterD;	/* Temporary store for image data after D convolution	*/
double *afterCC,*afterCD,*afterDC,*afterDD;	/* Results		*/

*ierr = 0;

/* Get memory for afterC */

if ((afterC = (double *)malloc((unsigned)(Csize*LengthCout*sizeof(double))))
	==NULL){
	*ierr = 1;
	return;
	}

/* Get memory for afterD */

if ((afterD = (double *)malloc((unsigned)(Csize*LengthDout*sizeof(double))))
	==NULL){
        *ierr = 2;
        return;
        }

/* Get memory for row of image to pass to convolution routines */

if ((ccopy = (double *)malloc((unsigned)(Csize*sizeof(double)))) == NULL) {
	*ierr = 3;
	return;
	}

/* Get memory for output row after C convolution */

if ((ccopy_out = (double *)malloc((unsigned)(LengthCout*sizeof(double))))
	==NULL)	{
	*ierr = 4;
	return;
	}

/* Get memory for output row after D convolution */

if ((dcopy_out = (double *)malloc((unsigned)(LengthDout*sizeof(double))))
        ==NULL) {
        *ierr = 5;
        return;
        }

/* Do convolutions on rows of C */

for(row=0; row < (int)Csize; ++row)	{

	/* Copy row of C into ccopy */

	for(j=0; j<Csize; ++j)
		*(ccopy+j) = ACCESS(C, Csize, row, j);

	/* Now convolve this row with C filter */

	convolveC(ccopy, (int)Csize, (int)firstCin,H, (int)LengthH, ccopy_out,
		(int)LengthCout, (int)firstCout, (int)lastCout, (int)bc);

	/* Now convolve this row with D filter */

	convolveD(ccopy, (int)Csize, (int)firstCin, H, (int)LengthH, dcopy_out,
		(int)LengthDout, (int)firstDout, (int)lastDout, (int)bc);

	/* Copy answer back to arrays */

	for(j=0; j<(int)LengthCout; ++j)
		ACCESS(afterC, (int)LengthCout, row, j) = *(ccopy_out + j);

	for(j=0; j<(int)LengthDout; ++j)
		ACCESS(afterD, (int)LengthDout, row, j) = *(dcopy_out + j);

	}


/* Now we have to apply both the C and D filters to afterC and afterD.
 * We get four answers. First we get the necessary memory
 */

if ((afterCC = (double *)malloc((unsigned)(LengthCout*LengthCout*sizeof(double))
		))==NULL)	{
	*ierr = 6;
	return;
	}

if ((afterCD = (double *)malloc((unsigned)(LengthDout*LengthCout*sizeof(double))
		))==NULL)	{
	*ierr = 7;
	return;
	}

if ((afterDC = (double *)malloc((unsigned)(LengthCout*LengthDout*sizeof(double))
		))==NULL)	{
	*ierr = 8;
	return;
	}

if ((afterDD = (double *)malloc((unsigned)(LengthDout*LengthDout*sizeof(double))
		))==NULL)	{
	*ierr = 9;
	return;
	}

/* Link this memory to the returning pointers */

*cc_out = afterCC;
*cd_out = afterCD;
*dc_out = afterDC;
*dd_out = afterDD;


/* Apply the filters, first to afterC to get afterCC and afterCD */

for(col=0; col < (int)LengthCout; ++col)	{

	/* Copy column to ccopy */

	for(j=0; j<(int)Csize; ++j)
		*(ccopy + j) = ACCESS(afterC, (int)LengthCout, j, col);

	/* Apply C filter */

	convolveC(ccopy, (int)Csize, (int)firstCin, H, (int)LengthH, ccopy_out,
		(int)LengthCout, (int)firstCout, (int)lastCout, (int)bc);

	/* Apply D filter */

	convolveD(ccopy, (int)Csize, (int)firstCin, H, (int)LengthH, dcopy_out,
		(int)LengthDout, (int)firstDout, (int)lastDout, (int)bc);

	/* Copy answer back */

	for(j=0; j<(int)LengthCout; ++j)
		ACCESS(afterCC, (int)LengthCout, j, col) = *(ccopy_out+j);

	for(j=0; j<(int)LengthDout; ++j)
		ACCESS(afterCD, (int)LengthCout, j, col) = *(dcopy_out+j);
	}

/* Apply the filters, now to afterD to get afterDC and afterDD */

for(col=0; col < (int)LengthDout; ++col)	{

	/* Copy column to ccopy */

	for(j=0; j<(int)Csize; ++j)
		*(ccopy + j) = ACCESS(afterD, (int)LengthDout, j, col);

	/* Apply C filter */

	convolveC(ccopy, (int)Csize, (int)firstCin, H, (int)LengthH, ccopy_out,
		(int)LengthCout, (int)firstCout, (int)lastCout, (int)bc);

	/* Apply D filter */

	convolveD(ccopy, (int)Csize, (int)firstCin, H, (int)LengthH, dcopy_out,
		(int)LengthDout, (int)firstDout, (int)lastDout, (int)bc);

	/* Copy answer back */

	for(j=0; j<(int)LengthCout; ++j)
		ACCESS(afterDC, (int)LengthDout, j, col) = *(ccopy_out+j);

	for(j=0; j<(int)LengthDout; ++j)
		ACCESS(afterDD, (int)LengthDout, j, col) = *(dcopy_out+j);
	}

/* That should be it ! */

free((char *) afterD);
free((char *) afterC);
free((char *)dcopy_out);
free((char *)ccopy_out);
free((char *)ccopy);

return;
}
