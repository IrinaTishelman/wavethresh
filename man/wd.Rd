\name{wd}
\alias{wd}
\title{
Discrete wavelet transform (decomposition).
}
\description{
This function performs the decomposition stage of Mallat's pyramid algorithm
(Mallat 1989),
i.e. the discrete wavelet transform. The actual transform is performed
by some C code, this is dynamically linked into S (if your machine can
do this, if it can't then tough!).
}
\usage{
wd(data, filter.number=2, family="DaubExPhase", bc="periodic",
	verbose=FALSE)
}
\arguments{
  \item{data}{a vector containing the data you wish to decompose. The
    length of this vector must be a power of 2.}
  \item{filter.number}{
    This selects the wavelet that you want to use in the decomposition.
    By default this is 2, the Daubechies orthonormal compactly supported
    wavelet N=2 (Daubechies (1988)), extremal phase family.
  }
  \item{family}{
    specifies the family of wavelets that you want to use. The options are
    "DaubExPhase" and "DaubLeAsymm". The "DaubExPhase" wavelets were provided
    with previous versions of wavethresh.
  }
  \item{bc}{character, specifying the boundary handling.
    If \code{bc=="periodic"} the default, then the
    function you decompose is assumed to be periodic on its interval of
    definition,\cr
    if \code{bc == "symmetric"}, the function beyond its boundaries is
    assumed to be a symmetric reflection of the function in the
    boundary.
  }
  \item{verbose}{logical, controlling the printing of `informative'
    messages whilst the computations progress.
    turned off by default.
  }
}
\value{
  An object of class \code{wd}, see \code{\link{wd.object}} for details.
  Basically, this object is a list with the following components
  \item{C}{
    Vector of sets of successively smoothed data. The pyramid structure
    of Mallat is stacked so that it fits into a vector.
    \code{\link{accessC}} should be used to extract these.}
  \item{D}{
    Vector of sets of wavelet coefficients at different resolution levels,
    stacking Mallat's pyramid structure into a vector.
    The function \code{\link{accessD}} should be used to extract the
    coefficients for a particular resolution level.}
  \item{nlevels}{
    The number of resolution levels, depending on the length of the data
    vector. If \code{length(data) = 2^m}, then there will be m
    resolution levels.}
  \item{fl.dbase}{The first/last database associated with this
    decomposition, see \code{\link{wd.object}} and
    \code{\link{first.last}} for details.}
  \item{filter}{A list containing information about the filter}
  \item{bc}{How the boundaries were handled.}
}
\details{
The code implements Mallat's pyramid algorithm (Mallat 1989).
Essentially it works like this: you start off with some data cm,
which is a real vector of length 2^m, say.

Then from this you obtain two vectors of length 2^(m-1). One of these
is a set of smoothed data, c(m-1), say. This looks like a smoothed version
of cm. The other is a vector, d(m-1), say.
This corresponds to the detail removed
in smoothing cm to c(m-1). More precisely, they are the coefficients of the
wavelet expansion corresponding to the highest resolution wavelets in the
expansion. Similarly, c(m-2) and d(m-2) are obtained from c(m-1), etc. until
you reach c0 and d0.

All levels of smoothed data are stacked into a single vector for memory
efficiency and ease of transport across the SPlus-C interface.

The smoothing is performed directly by convolution with the wavelet filter
(filter.select(n)$H, essentially low-pass filtering), and then dyadic
decimation (selecting every other datum, see Vaidyanathan (1990)).
The detail extraction is performed by the mirror filter of H, which
we call G and is a bandpass filter.
G and H are also known quadrature mirror filters.

There are now two methods of handling "boundary problems". If you know
that your function is periodic (on it's interval) then use the
bc="periodic" option, if you think that the function is symmetric
reflection about each boundary then use bc="symmetric".
If you don't know then it is wise to experiment with both methods,
in any case, if you don't have very much data don't infer too much about
your decomposition! If you have loads of data then don't infer too much
about the boundaries. It can be easier to interpret the wavelet coefficients
from a bc="periodic" decomposition, so that is now the default.
Numerical Recipes implements some of the wavelets code, in particular
we have compared our code to "wt1" and "daub4" on page 595. We are
pleased to announce that our code gives the same answers!
The only difference that you might notice is that one of the coefficients,
at the beginning or end of the decomposition,
always appears in the "wrong" place. This is not so, when you assume
periodic boundaries you can imagine the function defined on a circle
and you can basically place the coefficient at the beginning or the
end (because there is no beginning or end, as it were).
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\references{
Any book on wavelets, especially

Chui, C. K. (1992).  \emph{An Introduction to Wavelets};
Academic Press, London.

Daubechies, I. (1988).
\emph{Orthonormal bases of compactly supported wavelets};
Communications on Pure and Applied Mathematics, \bold{41}, 909-996.

Daubechies, I. (1992).
\emph{Ten Lectures on Wavelets};
CBMS-NSF Regional Conference Series in Applied Mathematics.

Donoho, D and Johnstone, I. (1994).
\emph{Ideal Spatial Adaptation by Wavelet Shrinkage};
Biometrika; \bold{81}, 425-455.

Mallat, S. G. (1989).
\emph{A theory for multiresolution signal decomposition: the wavelet
  representation};
IEEE Transactions on Pattern Analysis and Machine Intelligence,
\bold{11}, No. 7, 674-693.

Vaidyanathan, P. P. (1990).
\emph{Multirate digital filters, filter banks, polyphase networks and
  applications: A tutorial};
Proceedings of the IEEE, \bold{78}, No.~1, 56-93
}
\seealso{\code{\link{wr}}, \code{\link{threshold}}, \code{\link{plot.wd}},
  \code{\link{accessC}}, \code{\link{accessD}},
  \code{\link{filter.select}}.
}
\examples{
## Example from Nason's 1993 report
f.ssl <- function(x) sin(x) + sin(2*x) + log(1+x)
m <- 10 ; n <- 2^m
x <- seq(0, 10*pi, length = n)
fx <- f.ssl(x)
y <- fx + rnorm(n, s= .3)

## Decompose the test data
summary(wds <- wd(y))
}
\keyword{math}
\keyword{smooth}
\keyword{nonlinear}
% Converted by Sd2Rd version 0.3-3.

