\name{summary.imwd}
\alias{summary.imwd}
\alias{summary.imwdc}
\title{Summary Methods for `imwd' and `imwdc'  Object}
\usage{
summary.imwd(x)
summary.imwdc(x)
}
\arguments{
  \item{x}{
    The image wavelet decomposition of class "imwd" or "imwdc", respectively.
    This is assumed to be the result of some image wavelet decomposition.}
}
\details{
The number of levels, the dimension of the original image,
name of the filter and the type of boundary handling are printed.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{
\code{\link{summary}}, \code{\link{imwd.object}}, \code{\link{imwdc.object}}.
}
\examples{
example(imwd)
summary(imwdL)
}
\keyword{nonlinear}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
