\name{threshold.wd}
\alias{threshold.wd}
\title{Threshold a `wd' Object (1D Wavelet)}
}
\description{
Applies hard or soft thresholding with different policies to a wavelet
decomposition object.
}
\usage{
threshold.wd(wd, levels=3:(wd$nlevels-1), type="hard",
    policy="universal", by.level=FALSE, value=0, dev=var, boundary=FALSE,
    verbose=FALSE, return.threshold=FALSE)
}
\arguments{
  \item{wd}{Object of class \code{"wd"}, typically from a wavelet decomposition
    using the \code{\link{wd}} function.}
  \item{levels}{integer vector determining which levels are thresholded in
    the decomposition.}
  \item{type}{character, determining the type of thresholding; either
    "hard" or "soft".}
  \item{policy}{character indicating the threshold to use,
    can be "universal", "manual", or "probability".}
  \item{by.level}{logical; if \code{FALSE} then a global threshold is
    applied to \emph{all} the levels specified by \code{levels},
    otherwise a threshold is computed and applied separately to each level.
  }
  \item{value}{numeric user-supplied threshold for the \code{"manual"}
    \code{policy}, or the user-supplied quantile level for the
    \code{"probability"} policy.}
  \item{dev}{deviance function.  The default \code{var} is to use the
    variance, but you can insert your own measure of deviance.  }
  \item{boundary}{logical, if true then the boundary correction values
    are included for thresholding, otherwise not.}
  \item{verbose}{logical, if true then \code{threshold()} spurts informative
    messages at you.}
  \item{return.threshold}{logical, if true then the actual threshold is
    returned, otherwise the thresholded object is returned.}
}
\value{An object of class "wd" that has been thresholded.
}
\details{
Thresholding modifies the coefficients within a wd wavelet
decomposition object. The modification can be performed either
with a "hard" or "soft" thresholding selected by the "type" argument.


Hard thresholding simply compares a coefficient with a threshold.
If it is larger in absolute magnitude it is left alone, if it is
smaller it is set to zero.
The "soft threshold" formula is

soft(w) = sgn(w)*max(|w| - t, 0)

where "w" is the wavelet coefficient, "t" is the threshold and
"sgn" is the sign of w. Soft thresholding causes w to be replaced
by soft(w).

There are many ways that the threshold can be computed,
we term this the "policy". A universal policy computes
a threshold based on Donoho and Johnstone's "universal thresholds".
The threshold is sqrt(2*log(n))*noise, where noise is computed
as sqrt(dev(w)), i.e. some measure of the variability of the coefficients,
and n is the number of data points (or number of wavelet coefficients).
By default "dev" is "var", so the noise level is estimated using the
sample standard deviation. You can use any other such estimate by writing
your own function and supplying it as the "dev" argument. For example
you could create the function "myvar" by

myvar <- function(d)
mad(d)^2


This computes the square of the mean absolute deviation of the data.
It is squared because "dev" should be a measure on the variance scale,
not the standard deviation (you know what I mean).
If you make the "by.levels" argument T, then a separate threshold is
computed for each level in the "levels" vector. This means that
the variance is estimated separately for each level.


The "manual" policy is simple. You supply a threshold value ("value")
and hard or soft thresholding is performed using that value.
The "value" argument is a vector. If it is of length 1 then
it is replicated to be the same length as the "levels" vector,
otherwise it is repeated as many times as necessary to be the
length vector's length. In this way, different thresholds can be
given for different levels. Note that the "by.level" argument has
no effect with this policy.


The "probability" policy works as follows. All coefficients that
are smaller than the "value"th quantile of the coefficients are
set to zero. If "by.level" is false, then the quantile is computed
for all coefficients in the levels specified by the "levels" vector;
if "by.level" is true, then each level's quantile is estimated separately.

This function is a method for the generic function
\code{threshold()} for class \code{wd}.
It can be invoked by calling \code{threshold(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{threshold.wd(x)} regardless of the
class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\references{see \code{\link{wd}} for a list.
}
\section{BUGS}{
There should be an optimal policy as well, although universal comes
close.
}
\seealso{
\code{\link{wr}}, \code{\link{wd}}
}
\examples{
# "Standard" example:
example(wd)
#
# Threshold it
#
(thH.wds <- threshold(wds))
thS.wds <- threshold(wds, type="soft")
#
# Reconstruct from the thresholded coefficients
#
str(    trecH <- wr(thH.wds))
summary(trecS <- wr(thS.wds))
#
# Plot the reconstructed functions
#
plot(x, trecH, type="l", col=2)
lines(x,trecS, col=3)
lines(x, fx, col="gray", lty=2, lwd=1.5)# true function
}
\keyword{nonlinear}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
