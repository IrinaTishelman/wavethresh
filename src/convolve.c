/*
 * CONVOLVE	-	Do filter H filter convolution with boundary
 */

#include <stdio.h>

#include "wavelet.h"


/*
 * ACCESSC handles negative accesses, as well as those that exceed the number
 * of elements
 */

#define	ACCESSC(c, firstC, lengthC, ix, bc) \
	*(c+reflect(((ix)-(firstC)),(lengthC),(bc)))


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
    )
{
    double sum;
    register int k;
    register int count_out;
    register int m;

    count_out = 0;
    for(k=firstCout; k <= lastCout; ++k)	{

	sum = 0.0;
	for(m=0; m < LengthH; ++m)
	    sum += *(H+m) * ACCESSC(c_in, firstCin, LengthCin, (m+2*k),bc);

	*(c_out + count_out) = sum;
	++count_out;
    }
}

void convolveD(
    double *c_in,	/* Input data				*/
    int LengthCin,	/* Length of this array			*/
    int firstCin,	/* 1st index of input			*/

    double *H,		/* Filter				*/
    int LengthH,	/* Length of filter		        */

    double *d_out,	/* Output data			        */
    int LengthDout,	/* Length of above array	        */
    int firstDout,	/* First index of D array		*/
    int lastDout,	/* Last index of D array		*/
    int bc		/* Method of boundary correction:
			   PERIODIC or SYMMETRIC		*/
    )
{
    double sum;
    register int k;
    register int count_out;
    register int m;

    count_out = 0;

    for(k=firstDout; k<=lastDout; ++k)	{

	sum = 0.0;
	for(m=0; m < LengthH; ++m)	{

	    if (m & 1)	/* odd */
		sum += *(H+m) * ACCESSC(c_in, firstCin, LengthCin,(2*k+1-m),bc);
	    else
		sum -= *(H+m) * ACCESSC(c_in, firstCin, LengthCin,(2*k+1-m),bc);
	}

	*(d_out + count_out) = sum;
	++count_out;
    }
}


/* Works out reflection, as REFLECT, but reports access errors */
int reflect(
    int n,
    int lengthC,
    int bc)
{

/* do not really exit()! -- would take down S/R as well!
 * the return() is just for -Wall .. */
#define Exit(i) { error("convolveC: error exit (%d)", i); return(-1); }

    if ((n >= 0) && (n < lengthC))
	return(n);
    else if (n<0)	{
	if (bc==PERIODIC)	{
	    /*
	      n = lengthC+n;
	    */
	    n = n%lengthC + lengthC*((n%lengthC)!=0);
	    if (n < 0)      {
		REprintf("reflect: access error (%d,%d)\n", n,lengthC);
		REprintf("reflect: left info from right\n");
		Exit(2);
	    }
	    else
		return(n);
	}

	else if (bc==SYMMETRIC)	{
	    n = -1-n;
	    if (n >= lengthC)       {
		REprintf("reflect: access error (%d,%d)\n",
			 n,lengthC);
		Exit(3);
	    }
	    else
		return(n);
	}

	else	{
	    REprintf("reflect: Unknown boundary correction");
	    REprintf(" value of %d\n", bc);
	    Exit(4);
	}

    }
    else	{
	if (bc==PERIODIC)	{
	    /*
	      printf("periodic extension, was %d (%d) now ",n,lengthC);
	      n = n - lengthC;
	    */
	    n %= lengthC;
	    /*
	      printf("%d\n", n);
	    */
	    if (n >= lengthC)	{
		REprintf("reflect: access error (%d,%d)\n",
			n,lengthC);
		REprintf("reflect: right info from left\n");
		Exit(5);
	    }
	    else
		return(n);
	}
	else if (bc==SYMMETRIC)	{
	    n = 2*lengthC - n - 1;
	    if (n<0)        {
		REprintf("reflect: access error (%d,%d)\n",
			n,lengthC);
		Exit(6);
	    }
	    else
		return(n);
	}
	else    {
	    REprintf("reflect: Unknown boundary correction\n");
	    Exit(7);
	}
    }

/* Safety */
    REprintf("reflect: SHOULD NOT HAVE REACHED THIS POINT\n");
    Exit(8);
}
