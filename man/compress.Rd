\name{compress}
\alias{compress}
\title{Compression - Generic function (wavelet)}
\usage{
compress(x, \dots)
}
\arguments{
  \item{x}{an \R object.}
  \item{...}{methods may have additional arguments.}
}
\description{
  Compresses \code{x} by removing zeroes.
  This is the generic function.
}
\details{Functions with names beginning in \code{compress.} will be
  methods for this function,

  See their individual help pages, e.g.,
  \code{\link{compress.imwd}}, \code{\link{compress.default}},
  for operation.
}
\value{a compressed version of the supplied argument.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{threshold}}, \code{\link{uncompress}}.}
\keyword{manip}
\keyword{utilities}
% Converted by Sd2Rd version 0.3-3.
