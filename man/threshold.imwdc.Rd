\name{threshold.imwdc}
\alias{threshold.imwdc}
\title{Threshold an `imwdc' Object (2D Wavelet)}
\description{
Applies hard or soft thresholding to wavelet decomposition object
of class \code{imwdc}.
}
\usage{
threshold.imwdc(imwdc, verbose=FALSE, \dots)
}
\arguments{
\item{imwdc}{Object of class "imwdc", maybe after a previous thresholding.}
\item{verbose}{print information messages about what's going on}
\item{...}{other arguments to threshold}}
\value{
  An object of class \code{"imwdc"}, containing the thresholded object
}
\details{
This function thresholds just like \code{\link{threshold.imwd}}, except that the
input is an "imwdc" object, not a "imwd" one, which suggests that
the object has already been thresholded (because \code{\link{threshold.imwd}}
returns an "imwdc" object).  Because the object is likely to have
been thresholded a warning message stating this is printed.

However, it is entirely possible that you would wish to impose a higher
threshold on an already thresholded object, and so this function does
just this.

%% FIXME: "Everyone" should know the following :
%% =====  Don't say this in all the *.Rd files, rather "see \link{...}"...
This function is a method for the generic function
\code{\link{threshold}()} for class \code{imwdc}.
It can be invoked by calling \code{threshold(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{threshold.imwdc(x)} regardless of the
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
\seealso{For examples, see \code{\link{imwr.imwd}}.
  \code{\link{imwr}}, \code{\link{imwd}}, \code{\link{compress}},
  \code{\link{uncompress}}, \code{\link{imwd.object}},
  \code{\link{imwdc.object}}
}
\keyword{nonlinear}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
