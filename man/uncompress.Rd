\name{uncompress}
\alias{uncompress}
\title{Decompression - Generic Function (Wavelet)}
\description{
  Decompresses \code{x}  by padding with zeroes
  This is the generic function.
}
\usage{
uncompress(x, \dots)
}
\arguments{
  \item{x}{an \R object.}
  \item{\dots}{methods may have additional arguments.}
}
\value{an uncompressed version of the supplied argument.}
\details{Functions with names beginning in \code{uncompress.} will be
  methods for this function,

  See their individual help pages, e.g.,
  \code{\link{uncompress.imwdc}}, \code{\link{uncompress.default}},
  for operation.
}
\seealso{\code{\link{compress}}.}
\keyword{manip}
\keyword{utilities}

