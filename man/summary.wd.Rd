\name{summary.wd}
\alias{summary.wd}
\title{Summary Method for `wd' (1D Wavelet) Object}
\usage{
summary.wd(object, \dots)
}
\arguments{
  \item{object}{
    The wavelet decomposition of class \code{"wd"}.  This is assumed to
    be the result of some wavelet decomposition.}
  \item{\dots}{further arguments to be passed to or from methods.}
}
\description{
  The number of levels, the length of the original data sequence,
  name of the filter and type of boundary handling are printed.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{wd.object}}, \code{\link{summary}}.
}
\examples{
summary(wd(1:512)) # silly
}
\keyword{nonlinear}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
