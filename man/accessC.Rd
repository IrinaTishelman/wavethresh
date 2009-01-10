\name{accessC}
\alias{accessC}
\title{Get Smoothed Data from Wavelet Structure}
\description{
  The smoothed and original data from a wavelet decomposition structure
  (returned from \code{\link{wd}}) are packed into a single vector in that
  structure.  This function extracts the data corresponding to a
  particular resolution level.
}
\usage{
accessC(wd.obj, level = wd.obj$nlevels, boundary=FALSE)
}
\arguments{
  \item{wd.obj}{
    wavelet decomposition structure from which you wish to extract the
    smoothed or original data if the structure is from a wavelet decomposition,
    or the reconstructed data if the structure is from a wavelet reconstruction.
  }
  \item{level}{
    the level that you wish to extract.  By default, this is the level with
    most detail (in the case of structures from a decomposition this is the
    original data, in the case of structures from a reconstruction this is the
    top-level reconstruction).
  }
  \item{boundary}{logical;
    if \code{TRUE} then all of the boundary correction values
    will be returned as well (note: the length of the returned vector
    may not be a power of 2).\cr
    If \code{boundary} is false, then just the coefficients will be returned.

    If the decomposition (or reconstruction)
    was done with periodic boundary conditions, this option has no effect.}
}
\value{A vector of the extracted data.
}
\details{
The wd (wr) function produces a wavelet decomposition (reconstruction)
structure.

For decomposition, the top level contains the original data, and
subsequent lower levels contain the successively smoothed data.
So if there are \eqn{2^m} original data points, there will be m+1 levels
indexed 0,1,\dots{},m. So

>  \code{accessC(wd.obj, level=m)}

pulls out the original data, as does

>  \code{accessC(wd.obj)}

To get hold of lower levels just specify the level that you're interested
in, e.g.

>  \code{accessC(wd.obj, level=2)}

gets hold of the second level.

For reconstruction, the top level contains the ultimate step in the
Mallat pyramid reconstruction algorithm, lower levels are intermediate
steps.

The need for this function is a consequence of the pyramidal structure
of Mallat's algorithm and the memory efficiency gain achieved by
storing the pyramid as a linear vector. AccessC obtains information about
where the smoothed data appears from the fl.dbase component of
wd.obj, in particular the array \code{fl.dbase$first.last.c} which
gives a complete specification of index numbers and offsets for
\code{wd.obj$C}.

Note that this and the \code{\link{accessD}} function only work with
objects of class \code{wd}, see \code{\link{wd.object}}.

Further note that this function only gets information from 'wd' class
objects. To put coefficients etc. into \code{wd} structures you have to
use the "putC" function.
}
\seealso{For background information, \code{\link{wr}} and
  \code{\link{wd}}.  Further, \code{\link{accessD}},
  \code{\link{filter.select}}, \code{\link{plot.wd}},
  \code{\link{threshold}}, \code{\link{putC}}, \code{\link{putD}}.
}
\examples{
## Get the 3rd level of smoothed data from a decomposition
accessC(wd(rnorm(2^7)), level=3)

example(wd)
str(accessC(wds))
## Plot the time series from a reconstruction
plot.ts(accessC(wr(wds, return.obj = TRUE)))
}
\keyword{manip}
% Converted by Sd2Rd version 0.3-3.
