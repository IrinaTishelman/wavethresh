\name{imwr.imwd}
\alias{imwr.imwd}
\alias{imwr.imwdc}%- both!
\title{2D Inverse Discrete Wavelet Transform (Image W. Reconstruction)}
\description{
  These functions perform the reconstruction stage of Mallat's
  pyramid algorithm, i.e. the inverse discrete wavelet transform for images.
}
\usage{
\method{imwr}{imwd}(imwd, bc=imwd$bc, verbose=FALSE)
\method{imwr}{imwdc}(imwdc,bc=imwd$bc, verbose=FALSE)
}
\arguments{
  \item{imwd,imwdc}{
    object of class \code{imwd} or \code{imwdc} respectively; typically
    returned by \code{\link{imwd}} and \code{\link{threshold.imwd}}.
  }
  \item{bc}{character, specifying the boundary handling. It is best left
    to be the boundary handling specified by that in the supplied argument.
  }
  \item{verbose}{logical; if true then informative messages are printed
    detailing the computations to be performed.}
}
\value{
A matrix, of dimension determined by the original data set supplied
to the initial decomposition (more precisely, determined by the nlevels
component of the imwd.object). This matrix is the highest resolution
level of the reconstruction. If a \code{imwd} (decomposition) is followed
immediately by a \code{imwr} (reconstruction) then the returned matrix
will be exactly the same as the original image.
}
\details{
Details of the algorithm are to be found in Mallat (1989).
As for "imwd" the algorithm works by applying many 1D reconstruction
algorithms to the coefficients. The filters used are those
described in Daubechies (1988).

This function is a method for the generic function
\code{imwr()} for class \code{imwd}.
It can be invoked by calling \code{imwr(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{imwr.imwd(x)} regardless of the
class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\references{see \code{\link{wd}} for a list.
}
\seealso{
\code{\link{imwd}}, \code{\link{plot}}, \code{\link{threshold}}
}
\examples{
example(imwd)
# Look at the error
summary( abs(c(imwr(imwdL) - lennon)))#around 1e-9

## Threshold after decomposing an image -- automagically compresses:
(tdi <- threshold(imwdL))

## Now reconstruct;  imwr calling imwr.imwdc directly
filled.contour(answer <- imwr(tdi))
}
\keyword{nonlinear}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
