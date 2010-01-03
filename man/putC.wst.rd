\name{putC.wst}
\alias{putC.wst}
\title{Puts a whole resolution level of father wavelet coeffients into wst wavelet object.}
\description{
Makes a copy of the \code{\link{wst}} object, replaces a whole resolution level of father wavelet coefficients data in the copy, and then returns the copy. 
}
\usage{
\method{putC}{wst}(wst, level, value, \dots)
}
\arguments{
\item{wst}{Packet-ordered non-decimated wavelet object into which you wish to insert the father wavelet coefficients.}
\item{level}{the resolution level at which you wish to replace the father wavelet coefficients.}
\item{value}{the replacement data, this should be of the correct length.}
\item{\dots}{any other arguments}
}
\details{
The function \code{\link{accessC.wst}} obtains the father wavelet coefficients for a particular level. The function \code{putC.wst} replaces father wavelet coefficients at a particular resolution level and returns a modified wst object reflecting the change. 

For the non-decimated wavelet transforms the number of coefficients at each resolution level is the same and equal to \code{2^nlevels} where \code{nlevels} is the number of levels in the \code{\link{wst.object}}. The number of coefficients at each resolution level is also, of course, the number of data points used to initially form the \code{\link{wst}} object in the first place. 

Use the \code{\link{accessC.wst}} to extract whole resolution levels of father wavelet coefficients. Use \code{\link{accessD.wst}} and \code{\link{putD.wst}} to extract/insert whole resolution levels of mother wavelet coefficients. Use the \code{\link{getpacket.wst}} and \code{\link{putpacket.wst}} functions to extract/insert packets of coefficients into a packet-ordered non-decimated wavelet object. 
}
\value{
A \code{\link{wst}} class object containing the modified father wavelet coefficients
}
\section{RELEASE}{Version 3.5.3 Copyright Guy Nason 1994 }
\seealso{
\code{\link{wst.object}}, \code{\link{wst}}, \code{\link{putC}}, \code{\link{accessD.wst}}, \code{\link{putD.wst}}, \code{\link{getpacket.wst}}, \code{\link{putpacket.wst}}. 
}
\examples{
#
# Generate an EMPTY wst object:
#
zero <- rep(0, 16)
zerowst <- wst(zero)
#
# Put some random father wavelet coefficients into the object at
# resolution level 2. For the non-decimated wavelet transform there
# are always 16 coefficients at every resolution level. 
#
mod.zerowst <- putC( zerowst, level=2, v=rnorm(16))
#
# If you use accessC  on mod.zerowd you would see that there were only
# coefficients at resolution level 2 where you just put the coefficients.
}
\keyword{manip}
\author{G P Nason}
