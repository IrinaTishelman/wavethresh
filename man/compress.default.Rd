\name{compress.default}
\alias{compress.default}
\title{Compress a (Wavelet) Vector}
\description{
  Compression of a vector by removal of zero elements.
}
\usage{
\method{compress}{default}(x, verbose = getOption("verbose"), \dots)
}
\arguments{
  \item{x}{numeric vector to compress}
  \item{verbose}{logical; if true then report on compression activity.}
  \item{\dots}{further arguments to be passed to or from methods.}
}
\value{
  An object of class \code{compressed} if compression took place, otherwise a
  an object of class \code{uncompressed}
}
\details{
Images are large objects.  Thresholded 2d wavelet objects (imwd) are also
large, but many of their elements are zero.  Compress takes a vector,
decides whether compression is necessary and if it is makes an object
of class \code{compressed} containing the nonzero elements and their position
in the original vector.

The decision whether to compress the vector or not depends on two
things, first the number of non-zero elements in the vector (r, say),
and second the length of the vector (n, say). Since the position and value
of the non-zero elements is stored we will need to store 2r values
for the non-zero elements. So compression takes place if 2r < n.

This function is a method for the generic function
\code{compress()} for class \code{default}.
It can be invoked by calling \code{compress(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{compress.default(x)} regardless of the
class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\section{BUGS}{
Sometimes the compressed object can be larger than the original.
This usually only happens for small objects, so it doesn't really
matter.
}
\seealso{
  \code{\link{compressed.object}}, \code{\link{uncompressed.object}};
  \code{\link[base]{rle}} for another kind of compression.
}
\examples{
#
# Compress a vector with lots of zeroes
#
str(compress(c(rep(0,100),99)))
## List of 3
##  $ position       : int 101
##  $ values         : num 99
##  $ original.length: int 101
##  - attr(*, "class")= chr "compressed"

## Try to compress a vector with not many zeroes
compress(1:10)
## (uncompressed)
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
