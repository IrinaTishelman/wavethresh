\name{uncompress.default}
\alias{uncompress.default}
\title{Decompress a Compressed or Uncompressed Object}
\description{
  The \code{\link{compress}} function compresses a sparse vector by
  removing zeroes.  This function performs the inverse transformation.
}
\usage{
\method{uncompress}{default}(v, verbose=FALSE)
}
\arguments{
  \item{v}{The \code{compressed} or \code{uncompressed} object to
    uncompress.}
  \item{verbose}{logical; if true then informative messages are printed.}
}
\value{The uncompressed vector.
}
\details{
See \code{\link{compress.default}} to see what this function does to vectors.
The \code{uncompress.default} function takes objects that have been output
from \code{compress.default(.)} and restores them to their original values.
If the input to \code{compress.default} was a sparse vector, then an object
of class \code{compressed} would be returned.  This class of object
(see \code{\link{compressed.object}}) is a list containing the position
and values of all the non-zero elements of the original vector. The
\code{uncompress.default} function reconstitutes the original vector.

Sometimes compression is not worthwhile (i.e. the original vector is not
sparse enough). In this case \code{compress.default()} returns the original
vector in a list with class \code{uncompressed}. The \code{uncompress.default()}
function's task in this case is simple: only return the vector part of
\code{uncompressed}.
}
\seealso{\code{\link{compress}}, \code{\link{compressed.object}}.
}
\examples{
## Compress a sparse vector and look at it
str(cv <- compress( vv <- c(rep(0,100),564) ))

## Uncompress the vector, (uncompress.default is used)
str(ucv <- uncompress(cv))
all(ucv == vv)

## a bit less sparse:
vv[sample(seq(vv), 5)] <- 1:5
str(cv <- compress(vv))
all(vv == uncompress(cv))
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
