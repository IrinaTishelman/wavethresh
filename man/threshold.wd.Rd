%%% $Id: threshold.wd.Rd,v 1.6 2001/12/17 08:18:33 maechler Exp maechler $
\name{threshold.wd}
\alias{threshold.wd}
\title{Threshold a `wd' Object (1D Wavelet)}
\description{
  Applies hard or soft thresholding with different policies to a wavelet
  decomposition object.
}
\usage{
threshold.wd(x, levels=3:(wd$nlevels-1), type="hard",
    policy="universal", by.level=FALSE, value=0, dev=var, boundary=FALSE,
    verbose = getOption("verbose"), return.threshold=FALSE, \dots)
}
\arguments{
  \item{x}{Object of class \code{"wd"}, typically from a wavelet decomposition
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
  \item{\dots}{further arguments to be passed to or from methods.}
}
\value{An object of class "wd" that has been thresholded.
}
\details{%
%%__FIXME___ These are VERY wordy --- and almost identical to those in
%%           ./threshold.imwd.Rd (and probably even other places) !!
%%
Thresholding modifies the coefficients within a \code{wd} wavelet
decomposition object. The modification can be performed either
with a "hard" or "soft" thresholding selected by the \code{type} argument.

Hard thresholding simply compares a coefficient with a threshold.  If it
is larger in absolute magnitude it is left alone, if it is smaller it is
set to zero.
The "soft threshold" formula is
\deqn{\mbox{soft}(w) = \mbox{sgn}(w) \max(\left|w\right| - t, 0)}{%
             soft(w) = sgn(w)*max(|w| - t, 0)}
where \eqn{w} is the wavelet coefficient, \eqn{t} is the threshold and
\eqn{\mbox{sgn}(w)}{sgn(w)} is the sign of \eqn{w}.  Soft thresholding
causes \eqn{w} to be replaced by \eqn{soft(w)}.

There are many ways that the threshold can be computed; we term this the
"policy".  A universal policy computes a threshold based on Donoho and
Johnstone's "universal thresholds".  The threshold is
sqrt(2*log(n))*noise, where noise is computed as sqrt(dev(w)), i.e. some
measure of the variability of the coefficients, and n is the number of
data points (or number of wavelet coefficients).  By default "dev" is
"var", so the noise level is estimated using the sample standard
deviation. You can use any other such estimate by writing your own
function and supplying it as the "dev" argument. For example you could
create the function \code{myvar} by
\cr \code{myvar <- function(d) mad(d)^2}

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
\references{see \code{\link{wd}} for a list.}
\section{BUGS}{
  There should be an optimal policy as well, although universal comes close.
}
\seealso{\code{\link{wr}}, \code{\link{wd}}}
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
# Plot the data, the true & reconstructed functions
#
plot(x,y, col = "gray", cex = .6) # the data
lines(x, fx, col="blue", lwd=1)# true function
lines(x, trecH, col= "orchid", lty=2, lwd=2)
lines(x, trecS, col= "tomato", lty=4, lwd=2)
legend(0,5.6, c("true", paste(c("hard","soft")," thresh.")),
       col = c("blue","orchid","tomato"), lwd= c(1,2,2), lty = c(1,2,4))
}
\keyword{nonlinear}
\keyword{smooth}
