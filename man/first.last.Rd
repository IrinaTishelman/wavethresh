\name{first.last}
\alias{first.last}
\title{Build a first/last database for wavelet transforms}
\description{
This function is not intended for user use, but is used by various
functions involved in computing and displaying wavelet transforms.
}
\usage{
first.last(LengthH, DataLength, bc="periodic")
}
\arguments{
  \item{LengthH}{length of the filter used to produce a wavelet decomposition.}
  \item{DataLength}{length of the data before transforming; must be a
    power of 2, say \eqn{2^m}.}
  \item{bc}{character string, determining how the boundaries of the the
    function are to be handled;
    one of \code{"periodic"} or \code{"symmetric"}.}
}
\value{
A first/last database structure, a list with the
following components:

\item{first.last.c}{
  A (m+1) x 3 matrix.  The first column specifies the real index of the first
  coefficient of the smoothed data at a level, the 2nd column is the
  real index of the last coefficient, the last column specifies the offset
  of the first smoothed datum at that level.  The offset is used by the
  C code to work out where the beginning of the sequence is within a packed
  vector of the pyramid structure.  The first and 2nd columns can be used
  to work out how many numbers there are at a level.

  If \code{bc="periodic"} then
  the pyramid is a true power of 2 pyramid, that is it starts with a
  power of 2, and the next level is half of the previous.
  If \code{bc="symmetric"} then the pyramid is nearly exactly a power of 2, but
  not quite, see the Details section for why this is so.
}
\item{ntotal}{The total number of smoothed data/original data points.}
\item{first.last.d}{
  A mx3 matrix. As for first.last.c but for the wavelet coefficients packed
  as the D component of a wavelet structure.
}
\item{ntotal.d}{The total number of wavelet coefficients.}
}
\details{
  Suppose you begin with \eqn{2^m=2048} coefficients.  At the next level you
  would expect 1024 smoothed data coefficients, and 1024 wavelet coefficients,
  and if \code{bc="periodic"} this is indeed what happens.
  However, if \code{bc="symmetric"} you actually need more than 1024 (as
  the wavelets extend over the edges). The first/last database keeps track
  of where all these "extras" appear and also where they are located in
  the packed vectors C and D of pyramidal coefficients within wavelet
  structures.

  For example, given a first.last.c row of \cr
  \code{-2 3 20}\cr

  The actual coefficients would be\cr
  \eqn{c_{-2}, c_{-1}, c_{0}, c_{1}, c_{2}, c_{3}}{%
    c_\{-2\}, c_\{-1\}, c_\{0\}, c_\{1\}, c_\{2\}, c_\{3\} \
    (in LaTeX notation where _\{x\} denotes subscript x)}.

  In other words, there are 6 coefficients, starting at -2 and ending at 3,
  and the first of these (\eqn{c_{-2}}{c\{-2\}}) appears at an offset of
  20 from the beginning of the \code{* $ C} component vector of the
  wavelet structure.

  You can ``do'' first.last in your head for periodic boundary handling,
  but for more general boundary treatments (e.g. symmetric) \code{first.last}
  is indispensable.
}
\section{RELEASE}{
  Release 2.2
  Copyright Guy Nason 1993
}
\references{
  The numbers in first/last databases were worked out from inequalities
  derived from:

  Daubechies, I. (1988).
  \emph{Orthonormal bases of compactly supported wavelets};
  Communications on Pure and Applied Mathematics, \bold{41}, 909-996.
}
\seealso{
\code{\link{wr}}, \code{\link{accessC}}, \code{\link{accessD}},
\code{\link{filter.select}}, \code{\link{threshold}}, \code{\link{wd}},
\code{\link{imwd}}, \code{\link{imwr}}.
}
\section{BUGS}{
None, I hope. However, with hindsight, I should have implemented the
periodic version first.  The symmetric boundary stuff confused a lot
of people (including me)!
}
\examples{
## If you're twisted then you may just want to look at one of these.

first.last(length(filter.select(2)), 64)
}
\keyword{misc}
\keyword{utilities}
% Converted by Sd2Rd version 0.3-3.
