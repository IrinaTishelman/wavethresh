\name{imwdc.object}
\alias{imwdc.object}
\title{Compressed 2D wavelet decomposition object}
\description{
  These are objects of class \code{"imwdc"}.
  They represent a compressed decomposition of a 2D function with respect
  to a 2D wavelet basis.
}
\section{GENERATION}{
This class of objects is returned from the \code{\link{threshold}} and
\code{\link{compress}} functions
to represent a wavelet decomposition of a image (or other 2D function).
}
\section{METHODS}{
The \code{"imwdc"} class of objects has methods for the following generic
functions:
\code{plot}, \code{threshold}, \code{summary}, \code{print}, \code{draw}, \code{imwr}, \code{uncompress}.
}
\value{
  The imwdc object is the same as a imwd object (see
  \code{\link{imwd.object}}), except that the \code{wNLx} and
  \code{w0Lconstant} components have been compressed using
  \code{\link{compress.default}}.
}
\seealso{\code{\link{imwd.object}}, \code{\link{uncompress}}.
}
\keyword{classes}
\keyword{methods}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
