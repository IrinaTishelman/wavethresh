\name{draw}
\alias{draw}
\title{Draw Wavelets - Generic function}
\description{
  Draw a picture of a wavelet.  This is a generic function.
  There are methods for 1D and 2D wavelets, see below.
}
\usage{
draw(x, \dots)
}
\arguments{
  \item{x}{an \R object.}
  \item{\dots}{methods may have additional arguments.
    In addition, the high-level graphics control arguments
    described under \code{\link{par}} and the arguments to
    \code{\link{title}} may be supplied to this function.
  }
}
\section{Side Effects}{
  a plot is created on the current graphics device.
}
\seealso{\code{\link{draw.default}}, \code{\link{draw.wd}},
  \code{\link{draw.imwd}},\code{\link{draw.imwdc}} for examples and
  \code{\link{wd.object}} for background.
}
\keyword{hplot}
% Converted by Sd2Rd version 0.3-3.
