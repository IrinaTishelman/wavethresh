\name{compressed.object}
\alias{compressed.object}
\title{Compressed (Wavelet) Object}
\description{
  These are objects of class \code{"compressed"}.
  They are lists with components representing a vector, see below.
}
\section{GENERATION}{
By \code{\link{compress.default}}
}
\section{METHODS}{
The \code{"compressed"} class of objects has methods for the following generic
functions:
\code{uncompress.default}
}
\value{
The following components must be included in a legitimate
\code{compressed} object.
\item{position}{ a vector containing the position of the non-zero
  elements in the original vector.}
\item{values}{a vector, corresponding position-by-position to the
  position vector, containing the values of the original vector.}
\item{original.length}{the original length of the uncompressed vector.}
}
\details{
The \code{\link{compress.default}} function tries to compress a vector.
If it can it produces an object of class \code{compressed}, otherwise an
object of class \code{uncompressed}.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{compress}}.
}
\keyword{classes}
% Converted by Sd2Rd version 0.3-3.
