\name{compress.imwd}
\alias{compress.imwd}
\alias{uncompress.imwdc}
\title{Compression and Decompression for `imwd' Objects}
\description{
  Compresses or decompresses a (thresholded) imwd object
  (\code{\link{imwd.object}}) by removing or padding with zero elements.
}
\usage{
\method{compress}{imwd}(x, verbose = getOption("verbose"), \dots)
\method{uncompress}{imwdc}(x, verbose = getOption("verbose"), \dots)
}
\arguments{
  \item{x}{class \code{imwd} object to compress or class \code{imwdc} to
    decompress.}
  \item{verbose}{logical; if true then report on compression activity.}
  \item{\dots}{further arguments to be passed to or from methods.}
}
\value{
  An object of class "imwdc" representing the compressed imwd object,
  see \code{\link{imwdc.object}}.
}
\details{
Thresholded imwd objects are usually very large and contain many zero
elements. This function compresses these objects into smaller "imwdc"
objects by using the \code{\link{compress.default}} function and
removing the zeroes.

\code{compress.imwd} is a method for the generic function
\code{\link{compress}} for class \code{imwd}.
The user shouldn't need to use this function directly.

\code{uncompress.imwd} uncompresses a \code{imwdc} object back into a
\code{imwd} one.  It is a method for the generic function
\code{uncompress()} for class \code{imwdc}.
It can be invoked by calling \code{uncompress(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{uncompress.imwdc(x)} regardless of the class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
  \code{\link{compress.default}}, \code{\link{uncompress.default}},
  \code{\link{threshold}},
  \code{\link{imwd.object}},\code{\link{imwdc.object}}.
}
\examples{
%% add examples!!
}
\keyword{manip}

