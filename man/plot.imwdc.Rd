\name{plot.imwdc}
\alias{plot.imwdc}
\title{Plot Method for an `imwdc' object}
\description{
Images wavelet coefficients of an imwdc class object
}
\usage{
\method{plot}{imwdc}(imwdc, verbose = getOption("verbose"),\dots)
}
\arguments{
  \item{imwdc}{object of class "imwdc", maybe from a thresholding using
    \code{\link{threshold}()}.}
  \item{verbose}{logical, passed to \code{\link{uncompress}}.}
  \item{\dots}{other arguments to \code{\link{plot.imwd}}.}
}
\section{Side Effects}{
A plot of image coefficients is performed
This function is a method for the generic function
\code{plot()} for class \code{imwdc}.
It can be invoked by calling \code{plot(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{plot.imwdc(x)} regardless of the
class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{plot.imwd}}, \code{\link{plot}}
}
\examples{
example(imwd)
# Look at the error
## Threshold after decomposing an image -- automagically compresses:
summary(tdi <- threshold(imwdL))
plot(tdi) # bug?
}
\keyword{hplot}
% Converted by Sd2Rd version 0.3-3.
