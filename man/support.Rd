\name{support}
\alias{support}
\title{Compute support of wavelet}
\description{
  Computes the support of a wavelet
}
\usage{
support(filter.number = 2, family = c("DaubExPhase", "DaubLeAsymm"),
        m = 0, n = 0)
}
\arguments{
  \item{filter.number}{integer; the number within the wavelet family whose
    support you wish to compute.}
  \item{family}{character string giving the family of wavelets that should
    be used.}
  \item{m}{the dilation number.}
  \item{n}{the translation number.}
}
\value{
  A list containing the support of the wavelets.  The list contains
  the following components:
  \item{lh}{The left-hand end of the interval of the support of the wavelet.}
  \item{rh}{The right-hand end}
  \item{psi.lh}{The left-hand end of the support of the mother wavelet}
  \item{psi.rh}{The right-hand end}
  \item{phi.lh}{The left-hand end of the support of the scale function
    (father wavelet)}
  \item{phi.rh}{The right-hand end}
}
\details{
To draw a wavelet it is important to know it's support.  \code{support}
provides this information. If a new family of wavelets is added then their
support needs to be determined and this function modified.
This function needn't be called by the user in normal use.
If the wavelet's aren't compactly supported then the support will not
be a simple closed interval!
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\section{BUGS}{
As the example shows below, when m=0 and n=0 the lh and rh don't show
the mother wavelet's support, but the wavelet above the mother wavelet.
The calling functions allow for this.
}
\seealso{\code{\link{wr}}, \code{\link{draw}}.
}
\examples{
str(support())
## List of 6
##  $ lh    : num -2
##  $ rh    : num 4
##  $ psi.lh: num -1
##  $ psi.rh: num 2
##  $ phi.lh: num 0
##  $ phi.rh: num 3
}
\keyword{dplot}
% Converted by Sd2Rd version 0.3-3.
