%%% $Id: plot.wd.Rd,v 1.10 2003/11/11 10:44:58 maechler Exp $
\name{plot.wd}
\alias{plot.wd}
\title{Plot Method for a `wd' object}
\description{Plot wavelet coefficients of an object of class \code{"wd"}.
}
\usage{
\method{plot}{wd}(x, xlabels, first.level = 1,
     main = "Wavelet Decomposition Coefficients", sub = x$filter$name,
     xlab = "Translate", ylab = "Resolution Level",
     scaling="by.level", rhlab = FALSE,
     col = par("fg"), lty = par("lty"), lwd = par("lwd"), \dots)
}
\arguments{
  \item{x}{object of class \code{wd}, containing a wavelet decomposition of
    a function.}
  \item{xlabels}{if supplied, this argument should be a vector containing
    the x-axis for the plot. For example, if you are trying to regress y
    on x, then you might want to put "x" in as the x-axis. Otherwise, the
    translates will be plotted.}
  \item{first.level}{integer, determining how many of the low resolution
    levels are plotted.  The default, \code{first.level=1} means that 1
    coefficient is plotted.}
  \item{main, sub, xlab, ylab}{main and sub-title, x- and y- axis label of plot}
  \item{scaling}{type of scaling applied to levels within the plot.
    Either \code{"by.level"} or \code{"global"}.}
  \item{rhlab}{logical; determines whether the scale factors applied to
    each level before plotting are printed as the right hand axis.}
  \item{col, lty, lwd}{graphical parameters, passed to \code{\link{segments}}.}
  \item{\dots}{other arguments to be supplied to \code{plot.wd}, see
    \code{\link{plot}}.}
}
\value{
  Axis labels to the right of the picture.  These values are the maximum
  of the absolute value of the coefficients at that resolution level.
  They are returned because they are sometimes hard to read on the plot.
}
\section{Side Effects}{
  A plot of the wavelet coefficients at each resolution level is produced.
}
\details{
The picture produced is similar to those in Donoho and Johnstone
1992. Wavelet coefficients for each resolution level are plotted
one above the other, with the high resolution coefficients at the
bottom, and the low resolution at the top. The coefficients are
plotted using the "segment" function, with a large positive coefficient
being plotted above an imaginary horizontal centre line, and a large
negative coefficient plotted below it. The position of a coefficient
along a line is indicative of the wavelet basis function's translate
number.

The resolution levels are labelled on the left-hand side axis,
and the maximum values of the absolute values of the coefficients
for the particular level form the right-hand side axis.

The levels of coefficients can be scaled in two ways. If you are
not interested in comparing the relative scales of coefficients
from different levels, then the default "scaling" option, "by.level"
is what you need. This computes the maximum of the absolute value
of the coefficients at a particular level and scales the so that
the fit nicely onto the plot. For this option, each level is scaled
DIFFERENTLY. To obtain a uniform scale for all the levels specify
the "global" option to the "scaling" argument. This will allow you
to make inter-level comparisons.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{wd}} and \code{\link{wd.object}}
}
\examples{
example(wd)

plot(wds, rhlab = TRUE) # plotting the wavelet coefficients
}
\keyword{hplot}
\keyword{smooth}

