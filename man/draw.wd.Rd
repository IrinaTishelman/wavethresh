\name{draw.wd}
\alias{draw.wd}
\alias{draw.imwd}
\alias{draw.imwdc}
\title{Draw Wavelet Corresponding to Wavelet Object}
\description{
  Draws picture of the wavelet associated with (1D or 2D) wavelet decomposition
  object \code{wd}, as opposed to drawing \code{wd} itself (which is
  achieved by the corresponding \code{\link{plot}} method, such as
  \code{\link{plot.wd}}.
}
\usage{
draw.wd(wd, \dots)
draw.imwd (wd, resolution = 128, \dots)
draw.imwdc(wd, resolution = 128, \dots)
}
\arguments{
  \item{wd}{Object of class \code{wd}, \code{imwd}, or \code{imwdc},
    typically from a wavelet decomposition using
    the \code{\link{wd}}, \code{\link{imwd}}, or
    \code{\link{threshold}} function.}
  \item{\dots}{further arguments to \code{\link{draw.default}}.}
}
\details{
Sometimes it is more convenient to use this function rather than
\code{\link{draw.default}, since you want a picture of the wavelet that did your
decomposition.
}
\seealso{
\code{\link{draw.default}}, \code{\link{wd}}
}
\examples{
example(wd)
# Draw a picture of the wavelets that were used
draw(wds); abline(h=0,v=0, lty=3, lwd=.5)

example(imwd)
# Draw a picture of the 2D wavelet that used
draw(imwdL)
}
\keyword{hplot}
% Converted by Sd2Rd version 0.3-3.
