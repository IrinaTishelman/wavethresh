\name{uncompress.imwdc}
\alias{uncompress.imwdc}
\title{Uncompress an `imwdc' object}
\description{
  Decompresses a imwdc object by padding with zero elements.
}
\usage{
uncompress.imwdc(imwdc, verbose=FALSE)
}
\arguments{
\item{imwdc}{Object to decompress must be of class "imwdc".}
\item{verbose}{If this is true then report on compression activity}
}
\value{
  An object of type "imwd" representing the decompressed imwdc object.
}
\details{
  This uncompresses a "imwdc" object back into a "imwd" object.
  This function is a method for the generic function
  \code{uncompress()} for class \code{imwdc}.
  It can be invoked by calling \code{uncompress(x)} for an
  object \code{x} of the appropriate class, or directly by
  calling \code{uncompress.imwdc(x)} regardless of the
  class of the object.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{uncompress.default}}, \code{\link{imwdc.object}}
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
