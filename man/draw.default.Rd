\name{draw.default}
\alias{draw.default}
\title{Draw a Picture of a Wavelet}
\description{
Draws pictures of wavelets associated with the wavethresh package
}
\usage{
draw.default(filter.number=2, family="DaubExPhase",
    resolution=1024, verbose=FALSE, plot=TRUE, main="Wavelet Picture",
    sub=zwd$filter$name, xlab="x", ylab=expression(psi(x)), dimension=1,
    twodplot=persp, enhance=TRUE, efactor=0.05, \dots)
}
\arguments{
  \item{filter.number}{integer; number of the filter in the wavelet
    family specified.  The range of possible numbers depends on the family.}
  \item{family}{character, the family of wavelets to use, can be
    "DaubExPhase" or "DaubLeAsymm" for Release 2.2.}
  \item{resolution}{integer specifying the resolution to use in drawing
    pictures.  A higher resolution gives a better quality picture but
    will take longer to draw (especially in two-dimensions).}
  \item{verbose}{logical, if \code{TRUE}, report the progress of drawing.}
  \item{plot}{logical, if true then plot the
    appropriate wavelet on the current active graphics device, otherwise
    the information about the wavelet is returned.}
  \item{main}{main title}
  \item{sub}{subtitle}
  \item{xlab, ylab}{labels for the x and y axis.}
  \item{dimension}{
    If this is 1, then a one-dimensional version of the wavelet is drawn,
    if this is 2, then a two-d picture is drawn with the twodplot function.
  }
  \item{twodplot}{function such as \code{\link{persp}} that can do
    something interesting with a matrix!}
  \item{enhance}{logical; with Daubechies' wavelets their effective
    support is much less than their actual support.
    If \code{enhance=TRUE} then the function tries to draw
    the wavelet on its effective support.}
  \item{efactor}{numeric, defining the effective support.
    Define z0 to be efactor times the maximum absolute value of the
    wavelet w(x). Define the set A=\{ x: |w(x)| > z0 \}, and the
    effective support is the smallest interval (1D), (square - 2D)
    containing A.
  }
  \item{\dots}{further arguments to \code{plot} or \code{twodplot}.}
}
\value{
If \code{plot} is false then no actual drawing is done, however, a list is
returned. If \code{dim=1} the list has two components x and y, representing the
domain of definition (or effective support) of the wavelet and the
value of the wavelet at x. If \code{dim=2}, the list has three components
x,y and z.
}
\section{Side Effects}{
a picture of a wavelet is drawn on the currently active graphics device
if plot=TRUE.
}
\details{
For Daubechies' compactly supported wavelets there is no known closed form
expression. However, it is possible to make use of the inverse wavelet
transform to draw pictures of the wavelets. The idea is to set
all but one wavelet coefficient equal to zero and that one coefficient
equal to one in a wavelet expansion.
Then the inverse transform (reconstruction) is applied to the expansion
and a picture of one wavelet is produced.

A method similar to the one we present here is presented in Daubechies (1992)
in Section~6.5 on the cascade algorithm.

The principle is simple, but the implementation to get good pictures is
surprisingly tricky. Ideally you want to put in the non-zero coefficient
at the lowest resolution level as possible, this will give you as much
detail as possible. However, the support of some of the large-scale
wavelets is greater than the union of the supports of all the high-resolution
small-scale wavelets and so it may not be possible to draw a complete wavelet.

This function analyses the supports of the wavelets at different levels
and finds a coefficient to set to one by choosing the wavelet at the lowest
possible resolution and whose support is within the union of supports of
the highest resolution wavelets. If there is
a choice of such wavelets, then the middle-most one is selected.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{draw}}, \code{\link{draw.wd}} etc.
}
\examples{
par(mfrow=c(3,2))
for(fn in 1:6) {
   draw.default(filter.number= fn, col = "blue")
   abline(h=0,v=0, lty=3, lwd=.5, col = "gray")
}
par(mfrow=c(1,1))

# Draw a 2-dimensional Daubechies least asymmetric wavelet
draw.default(filter.number=6, family="DaubLeAsymm", dim=2, resolution=128)
}
\keyword{hplot}
% Converted by Sd2Rd version 0.3-3.
