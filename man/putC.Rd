\name{putC}
\alias{putC}
\title{Put Smoothed Data Into Wavelet Structure}
}
\description{
  Makes a copy of the wd object, replaces some smoothed data in
  the copy, and then returns it.
}
\usage{
putC(wd, level, v, boundary=FALSE)
}
\arguments{
  \item{wd}{object of class \code{wd} that is to be copied and have
    smoothed data replaced.}
  \item{level}{integer; the level at which the replacement is to take place.}
  \item{v}{the replacement data which should be of the correct length.}
  \item{boundary}{logical; if \code{FALSE} then only the "real" data is
    replaced (and it is easy to predict the required length of \code{v}).
    \cr
    If boundary is \code{TRUE}, you can replace the boundary values at a
    particular level as well (but it is hard to predict the required
    length of \code{v}, and the information has to be obtained from the
    \code{first.last} database component of \code{wd}).

    \code{boundary} has no meaning if \code{wd} was obtained with the
    periodic boundary handling method (\code{bc}).}
}
\value{A \code{wd} class object containing the replaced data, see
  \code{\link{wd.object}}.
}
\details{
The function \code{\link{accessC}} obtains the smoothed data for a particular
level. This function, \code{putC} replaces data at a particular level and
returns a modified wd object reflecting the change.

This function is probably not particularly useful, but it is present
for completeness.  It is required because of the pyramidal nature of
the smoothed data points being packed into a vector.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{wd.object}}, \code{\link{accessC}}
}
\examples{
example(wd)
## Put the numbers 1:64 into level 6
summary(newds <- putC(wds, level=6, v=1:64, boundary=FALSE))
#
# If you look at the C component of new, you will see that
# some numbers have changed at the appropriate position.
all.equal(wds,newds)
##>[1] "Component C: ... difference: 2.1912"
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
