\name{compress.imwd}
\alias{compress.imwd}
\title{`Compress' Method for `imwd' Object}
\description{
  Compresses a (thresholded) imwd object (\code{\link{imwd.object}}) by
  removing zero elements.
}
\usage{
compress.imwd(imwd, verbose=FALSE)
}
\arguments{
  \item{imwd}{class \code{imwd} object to compress.}
  \item{verbose}{logical; if true then report on compression activity.}
}
\value{
  An object of class "imwdc" representing the compressed imwd object,
  see \code{\link{imwdc.object}}.
}
\details{
Thresholded imwd objects are usually very large and contain many zero
elements. This function compresses these objects into smaller "imwdc"
objects by using the \code{\link{compress.default}} function and
removing the zeroes.

This function is a method for the generic function
\code{\link{compress}} for class \code{imwd}.

The user shouldn't need to use this function.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
  \code{\link{compress.default}}, \code{\link{threshold}},
  \code{\link{imwdc.object}}.
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
