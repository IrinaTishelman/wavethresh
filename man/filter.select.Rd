\name{filter.select}
\alias{filter.select}
\title{Provide wavelet filter coefficients.}
\description{
This function stores the filter coefficients necessary for doing a discrete wavelet transform (and its inverse).
}
\usage{
filter.select(filter.number, family="DaubLeAsymm", constant=1)
}
\arguments{
\item{filter.number}{This selects the desired filter, an integer that takes a value dependent upon the family that you select.} 
\item{family}{This selects the basic family that the wavelet comes from. The choices are \bold{DaubExPhase} for Daubechies' extremal phase wavelets, \bold{DaubLeAsymm} for Daubechies' ``least-asymmetric'' wavelets, \bold{Lawton} for Lawton's complex-valued wavelets, \bold{LittlewoodPaley} for a bad approximation to Littlewood-Paley wavelets.}
\item{constant}{This constant is applied as a multiplier to all the coefficients. It can be a vector, and so you can adapt the filter coefficients to be whatever you want. (This is feature of negative utility, or ``there is less to this than meets the eye'' as my old PhD supervisor would say [GPN]).} 
}
\details{
This function contains at least three types of filter. Two types can be selected with family set to DaubExPhase, these wavelets are the Haar wavelet (selected by filter.number=1 within this family) and Daubechies ``extremal phase'' wavelets selected by filter.numbers ranging from 2 to 10). Setting family to DaubLeAsymm gives you Daubechies least asymmetric wavelets, but here the filter number ranges from 4 to 10. For Daubechies wavelets, filter.number corresponds to the N of that paper, the wavelets become more regular as the filter.number increases, but they are all of compact support. 

Setting family equal to ``Lawton'' chooses complex-valued wavelets. The only wavelet available is the one with ``filter.number'' equal to 3. 

The function \code{\link{compare.filters}} can be used to compare two filters. 

}
\value{
Alist is returned with four components describing the filter: 

\item{H}{A vector containing the filter coefficients.} 
\item{G}{A vector containing filter coefficients (if Lawton wavelets are selected, otherwise this is NULL).} 
\item{name}{A character string containing the name of the filter.} 
\item{family}{A character string containing the family of the filter.} 
\item{filter.number}{The filter number used to select the filter from within a family.} 
}
\note{The (Daubechies) filter coefficients should always sum to sqrt(2). This is a useful check on their validity. }
\section{RELEASE}{Version 3.5.3 Copyright Guy Nason 1994 }
\seealso{
\code{\link{wd}}, \code{\link{wr}}, \code{\link{wr.wd}}, \code{\link{accessC}}, \code{\link{accessD}}, \code{\link{compare.filters}}, \code{\link{imwd}}, \code{\link{imwr}}, \code{\link{threshold}}, \code{\link{draw}}. 
}
\examples{
#This function is usually called by others. However, on occasion you may wish to look at the coefficients themselves.

#
# look at the filter coefficients for N=4 (by default Daubechies'
# least-asymmetric wavelets.)
#
filter.select(4)
#$H:
#[1] -0.07576571 -0.02963553  0.49761867  0.80373875  0.29785780
#[6] -0.09921954 -0.01260397  0.03222310
#
#$G:
#NULL
#
#$name:
#[1] "Daub cmpct on least asymm N=4"
#
#$family:
#[1] "DaubLeAsymm"
#
#$filter.number:
#[1] 4
}
\keyword{utilities}
\author{G P Nason}
