\name{pack8bit}
\alias{pack8bit}
\alias{unpack8bit}
\title{Packing of 8-bit Integers}
\description{
  In image processing, often pictures are stored as long array of values
  in \code{0:255}.  For (file) storage, these can be packed into 32 bit
  integers.  These functions are for packing and unpacking.
}
\usage{
pack8bit(v8)
unpack8bit(v)
}
\arguments{
  \item{v8}{integer vector with 8-bit elements in 0..255.}
  \item{v}{integer vector (at least 32 bits).}
}
\details{
  If the length of \code{v8} is \emph{not} a multiple of 4,  \code{v8}
  is effectively padded with one to three \code{0}s.

  The implementation is straightforward and short; look at the function
  definitions.
}
\value{
  \code{pack8bit(v8)} returns an integer vector of length
  \code{ceiling(length(v8) / 4)}.

  \code{unpack8bit(v)} returns a vector of values from \code{0:255} of
  length \code{4 * length(v)}.
}
\author{Martin Maechler}
\seealso{\code{\link{compress}} etc for wavelet compression.}
\examples{
pack8bit(0:11)
all(pack8bit(0:11) == pack8bit(0:9))
all(0:255 == unpack8bit(pack8bit(0:255)))
}
\keyword{utilities}

