
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
    long *bc,		/* Method of boundary correction		*/
    long *error		/* Error code					*/
    );

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
    long *bc,		/* Which boundary handling are we doing		*/
    long *error		/* Error code					*/
    );

void StoIDS(
    double *C,
    long *Csize,
    long *firstCin,
    double *H,
    long *LengthH,
    long *LengthCout,
    long *firstCout,
    long *lastCout,
    long *LengthDout,
    long *firstDout,
    long *lastDout,
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    long *bc,
    long *error
    );

void StoIRS(
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    long *LengthCin, long *firstCin, long *lastCin,
    long *LengthDin, long *firstDin, long *lastDin,
    double *H,
    long *LengthH,
    long *LengthCout, long *firstCout, long *lastCout,
    double *ImOut,
    long *bc,
    long *error
    );

void ImageDecomposeStep(
    double *C,		/* Input data image				*/
    long Csize,		/* Size of image (side length)			*/
    long firstCin,	/* Index number of first element in input "C" image */
    double *H,		/* Filter coefficients				*/
    long LengthH,	/* Length of filter				*/

/* Details about output image */
    long LengthCout,	/* Length of C part of output image		*/
    long firstCout,	/* Index number of first element in output "C" image */
    long lastCout,	/* Index number of last element			*/
    long LengthDout,	/* Length of D part of output image		*/
    long firstDout,	/* Index number of first element in output "D" image */
    long lastDout,	/* Index number of last element			*/
    double **cc_out,	/* Smoothed output image			*/
    double **cd_out,	/* Horizontal detail				*/
    double **dc_out,	/* Vertical detail				*/
    double **dd_out,	/* Diagonal detail				*/
    long bc,		/* Method of boundary correction		*/
    long *error		/* Error code					*/
    );

void ImageReconstructStep(
    double *ImCC, double *ImCD, double *ImDC, double *ImDD,
    long LengthCin, long firstCin, long lastCin,
    long LengthDin, long firstDin, long lastDin,
    double *H,
    long LengthH,
    long LengthCout, long firstCout, long lastCout,
    double *ImOut,
    long *bc,
    long *error
    );
