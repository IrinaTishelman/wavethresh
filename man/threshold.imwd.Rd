\name{threshold.imwd}
\alias{threshold.imwd}
\title{Threshold an `imwd' Object (2D Wavelet)}
\description{
  Applies hard or soft thresholding to wavelet decomposition object
  of class \code{imwd}.
}
\usage{
threshold.imwd(imwd, levels=3:(wd$nlevels-1), type="hard",
    policy="universal", by.level=FALSE, value=0, dev=var,
    verbose=FALSE, return.threshold=FALSE, compression=T)
}
\arguments{
  \item{imwd}{object of class \code{"imwd"},  typically  from a wavelet
    decomposition using the \code{\link{imwd}} function.}
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
  \item{verbose}{logical, if true then \code{threshold()} spurts informative
    messages at you.}
  \item{return.threshold}{logical, if true then the actual threshold is
    returned, otherwise the thresholded object is returned.}
  \item{compression}{logical; if true the thresholded object is
    compressed and then returned, otherwise it is returned unaltered.}
}
\value{
  If \code{compression} is true then an object of class \code{"imwdc"}
  that has been thresholded and compressed,
  otherwise an uncompressed, but thresholded object of class \code{"imwd"}.
}
\details{
Thresholding modifies the coefficients within a \code{imwd} wavelet
decomposition object.  The modification can be performed either
with a "hard" or "soft" thresholding selected by the \code{type} argument.

%% ---> ./threshold.wd.Rd
See the ``Details'' section of \code{\link{threshold.wd}} for an
explanation of thresholding types and policies.

%% imwd specific :
The thresholding process forces many coefficients to zero. From release 2.2
onwards the thresholded "imwd" object is compressed by \code{\link{compress}}
and returned as a much smaller "imwdc" object.  An "imwdc" object is
easily converted into an "imwd" object by \code{\link{uncompress}}, but
all relevant functions will handle the "imwdc" object.

Note that the coefficients for the horizontal, diagonal and vertical
detail at a particular level are treated as one. In future releases
we may add the capability to treat the details differently, although
this would increase the complexity of the argument specification.

%% FIXME: "Everyone" should know the following :
%% =====  Don't say this in all the *.Rd files, rather "see \link{...}"...
This function is a method for the generic function
\code{threshold()} for class \code{imwd}.
It can be invoked by calling \code{threshold(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{threshold.imwd(x)} regardless of the
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
