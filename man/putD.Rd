\name{putD}
\alias{putD}
\title{Put Wavelet Coefficients Into Wavelet Structure}
\description{
  Makes a copy of the wd object, replaces some wavelet coefficients
  into the copy, and then returns the copy.
}
\usage{
putD(wd, level, v, boundary=FALSE)
}
\arguments{
  \item{wd}{
    object of class \code{wd} that is to be copied and have wavelet
    coefficients replaced.}
  \item{level}{integer; the level at which the replacement is to take place.}
  \item{v}{the replacement coefficients which should be of the correct length.}
  \item{boundary}{logical; if \code{FALSE} then only the "real" coefficients
    are replaced (and it is easy to predict the required length of
    \code{v}, just the correct power of 2).
    \cr
    If boundary is \code{TRUE}, then you can replace the boundary
    coefficients as well (but it is hard to predict the required length
    of \code{v}, and the information has to be extracted from the
    \code{first.last} database component of \code{wd}).

    \code{boundary} has no meaning if \code{wd} was obtained with the
    periodic boundary handling method (\code{bc}).}
}
\value{A \code{wd} class object containing the replaced coefficients, see
  \code{\link{wd.object}}.
}
\details{
The function \code{\link{accessD}}obtains the wavelet coefficients for a
particular level.  This function, \code{putD} replaces coefficients at a
particular level and returns a modified wd object reflecting the change.

As opposed to the utility of \code{\link{putC}}, the \code{putD}
function is actually quite useful.  It is fun to replace coefficients,
since then you can dream up your own functions, get pictures of the
wavelets etc. etc.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{wd.object}}, \code{\link{accessD}}, \code{\link{draw}}
}
\examples{
example(wd)

## Set all the wavelet coefficients to zero
for(i in 0:(wds$nlevels - 1))
  wds <- putC(wds, level=i, v=rep(0,2^i))

## and now see what you've done
plot(wds)
matplot(x, cbind(wr(wd(y)), wr(wds)), type = 'l')
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
