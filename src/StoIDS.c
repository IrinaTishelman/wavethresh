#include "wavelet.h"

/* Access an element in an image */
#define ACCESS(image, size, i, j)       *(image + (i)*(size) + (j))

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
    )
{
    register int i,j;
    int Dlen = (int)*LengthDout,
	Clen = (int)*LengthCout;
    double *cc_out, *cd_out, *dc_out, *dd_out;

    ImageDecomposeStep(C, *Csize, *firstCin, H, *LengthH,
		       *LengthCout, *firstCout, *lastCout,
		       *LengthDout, *firstDout, *lastDout,
		       &cc_out, &cd_out, &dc_out, &dd_out, *bc,
		       ierr);

    /* Copy images */

    for(i=0; i < Dlen; ++i)	{
	for(j=0; j < Dlen; ++j)
	    ACCESS(ImDD, Dlen, i, j) = ACCESS(dd_out, Dlen, i, j);

	for(j=0; j < Clen; ++j)
	    ACCESS(ImDC, Dlen, j,i) = ACCESS(dc_out, Dlen, j,i);
    }

    for(i=0; i < Clen; ++i)	{
	for(j=0; j < Dlen; ++j)
	    ACCESS(ImCD, Clen, j,i) = ACCESS(cd_out, Clen, j,i);

	for(j=0; j < Clen; ++j)
	    ACCESS(ImCC, Clen,j,i) = ACCESS(cc_out, Clen, j,i);
    }
}
