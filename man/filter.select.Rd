\name{filter.select}
\alias{filter.select}
\title{Wavelet Filter Coefficients}
\usage{
filter.select(filter.number, family="DaubExPhase", constant=1)
}
\description{
This function stores the filter coefficients necessary for doing a discrete
wavelet transform (and its inverse).
}
\arguments{
  \item{filter.number}{integer, selecting the desired filter; takes a
    value dependent upon the family that you select.}
  \item{family}{character string, selecting the type of wavelet.}
  \item{constant}{numeric;
    is applied as a multiplier to all the coefficients.
    It can be a vector, and so you can adapt the filter coefficients
    to be whatever you want. (This is feature of negative utility.)}
}
\value{
A list is returned with four components describing the filter:
\item{H}{A vector containing the filter coefficients.}
\item{name}{A character string containing the name of the filter.}
\item{family}{A character string containing the family of the filter.}
\item{filter.number}{The filter number used to select the filter.}
}
\details{
This function contains three types of filter.
Two types can be selected with family set to DaubExPhase, these
wavelets are the Haar wavelet (selected by filter.number=1 within
this family) and Daubechies \code{`extremal phase}' wavelets selected by
filter.numbers ranging from 2 to 10) as proposed in Daubechies (1988).
Setting family to DaubLeAsymm gives you Daubechies least asymmetric
wavelets also from Daubechies (1988), but here the filter number ranges
from 4 to 10.

For Daubechies wavelets, \code{filter.number} corresponds to the
N of that paper, the wavelets become more regular as the filter.number
increases, but they are all of compact support.

This function is currently used by \code{\link{wr}} and \code{\link{wd}}
in decomposing and reconstructing, however you may wish to look at the
coefficients.
}
\section{NOTE}{
The filter coefficients should always sum to
\eqn{\sqrt{2}{sqrt(2)}. This is a useful check on their validity.
}
\seealso{
  \code{\link{wd}}, \code{\link{wr}}, for background information;
  \code{\link{accessC}}, \code{\link{accessD}},
  \code{\link{imwd}}, \code{\link{imwr}}, \code{\link{threshold}}.
}
\examples{
## look at the filter coefficients for N=2 :
str(f2 <- filter.select(2))
##- List of 4
##-  $ H            : num [1:4]  0.483  0.837  0.224 -0.129
##-  $ name         : chr "Daub cmpct on ext. phase N=2"
##-  $ family       : chr "DaubExPhase"
##-  $ filter.number: num 2

all.equal(sum(f2 $H), sqrt(2))# TRUE
}
\keyword{math}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
