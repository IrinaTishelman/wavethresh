\name{wvrelease}
\alias{wvrelease}
\title{
Identify version of wavelet software.
}
\description{
Prints a message identifying the version of the wavelet software.
}
\usage{
wvrelease()
}
\value{
  a list list with components
  \item{major}{the major release number}
  \item{R.minor}{the R port version (of the major release)}
}
\section{Side Effects}{
  Prints a message identifying the version of the wavelet software.
}
\details{
When attaching the wavelet software directory to your own data directory
it is useful to put a "wvrelease()" function call just after the
attach. This ensures that you have attached to the correct directory
and that you are using the most up to date software.
(This function is mainly useful to those of you that have received
earlier versions of this software).
}
\seealso{
}
\examples{
str(r <- wvrelease())
}
\keyword{smooth}
\keyword{nonlinear}
% Converted by Sd2Rd version 0.3-3.
