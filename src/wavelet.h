#include <R.h>

#define PERIODIC	1
#define SYMMETRIC	2

int reflect(int n, int lengthC, int bc);

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
    );

void convolveC(
    double *c_in,	/* Input data				*/
    int LengthCin,	/* Length of this array			*/
    int firstCin,	/* 1st index of input			*/

    double *H,		/* Filter				*/
    int LengthH,	/* Length of filter			*/

    double *c_out,	/* Output data				*/
    int LengthCout,	/* Length of above array		*/
    int firstCout,	/* First index of C array		*/
    int lastCout,	/* Last index of C array		*/
    int bc		/* Method of boundary correction:
			   PERIODIC, SYMMETRIC			*/
    );

void convolveD(
    double *c_in,	/* Input data				*/
    int LengthCin,	/* Length of this array			*/
    int firstCin,	/* 1st index of input			*/

    double *H,		/* Filter				*/
    int LengthH,	/* Length of filter			*/

    double *d_out,	/* Output data				*/
    int LengthDout,	/* Length of above array		*/
    int firstDout,	/* First index of D array		*/
    int lastDout,	/* Last index of D array		*/
    int bc		/* Method of boundary correction:
			   PERIODIC or SYMMETRIC		*/
    );

void wavedecomp(
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
    Sint *bc,		/* Method of boundary correction		*/
    Sint *ierr		/* Error code					*/
    );

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
    Sint *bc,		/* Which boundary handling are we doing		*/
    Sint *ierr		/* Error code					*/
    );

void StoIDS(
    double *C,
    Sint *Csize,
    Sint *firstCin,
    double *H,
    Sint *LengthH,
    Sint *LengthCout,
    Sint *firstCout,
    Sint *lastCout,
    Sint *LengthDout,
    Sint *firstDout,
    Sint *lastDout,
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    Sint *bc,
    Sint *ierr
    );

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
    );

void ImageDecomposeStep(
    double *C,		/* Input data image				*/
    Sint Csize,		/* Size of image (side length)			*/
    Sint firstCin,	/* Index number of first element in input "C" image */
    double *H,		/* Filter coefficients				*/
    Sint LengthH,	/* Length of filter				*/

/* Details about output image */
    Sint LengthCout,	/* Length of C part of output image		*/
    Sint firstCout,	/* Index number of first element in output "C" image */
    Sint lastCout,	/* Index number of last element			*/
    Sint LengthDout,	/* Length of D part of output image		*/
    Sint firstDout,	/* Index number of first element in output "D" image */
    Sint lastDout,	/* Index number of last element			*/
    double **cc_out,	/* Smoothed output image			*/
    double **cd_out,	/* Horizontal detail				*/
    double **dc_out,	/* Vertical detail				*/
    double **dd_out,	/* Diagonal detail				*/
    Sint bc,		/* Method of boundary correction		*/
    Sint *ierr		/* Error code					*/
    );

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
    );
