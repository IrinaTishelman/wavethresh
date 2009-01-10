\name{accessD}
\alias{accessD}
\title{Get wavelet expansion coefficients from wavelet structure.}
\description{
  The coefficients from a wavelet expansion in a wavelet decomposition
  structure (returned from \code{\link{wd}} or \code{\link{wr}}) are
  packed into a single vector in that structure.
  This function extracts the coefficients corresponding to a particular
  resolution level.
}
\usage{
accessD(wd.obj, level, boundary=FALSE)
}
\arguments{
\item{wd.obj}{Wavelet decomposition structure from which you wish to
  extract the expansion coefficients.}
\item{level}{The level that you wish to extract. If the "original" data has
  \eqn{2^m} data points then there are m possible levels that you could want
  to access, indexed by 0,1,\dots{},(m-1).}
\item{boundary}{
  If this argument is TRUE then all of the boundary correction values
  will be returned as well (note: the length of the returned vector
  may not be a power of 2). If boundary is false, then just the
  coefficients will be returned. If the decomposition (or reconstruction)
  was done using periodic boundary handling then this option has no
  effect.}
}
\value{
  A vector of the extracted coefficients.
}
\details{
  The wd (wr) function produces a \bold{w}avelet \bold{d}ecomposition
  (\bold{r}econstruction) structure.

  The need for this function is a consequence of the pyramidal structure
  of Mallat's algorithm and the memory efficiency gain achieved by
  storing the pyramid as a linear vector.  AccessD obtains information about
  where the coefficients appear from the fl.dbase component of
  wd.obj, in particular the array \code{fl.dbase$first.last.d} which
  gives a complete specification of index numbers and offsets for
  \code{wd.obj$D}.

  Note that this function and accessC only work on objects of class
  \code{wd}. Also, you have to use \code{\link{putD}} to put wavelet
  coefficients into a wd object.
}
\seealso{
  \code{\link{wr}} and \code{\link{wd}} for background information;
  \code{\link{accessC}}, \code{\link{filter.select}},
  \code{\link{threshold}}, \code{\link{putC}}, \code{\link{putD}}.
}
\examples{
example(wd)

## Get the 3rd level coefficients of a decomposition
accessD(wds, level=3)

## Do a qqnorm plot to assess the normality of some coefficients
qqnorm(accessD(wds, level=8))
}
\keyword{manip}

