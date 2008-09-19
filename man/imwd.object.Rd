\name{imwd.object}
\alias{imwd.object}
\title{2d Wavelet Decomposition Object}
\description{
  These are objects of class \code{"imwd"}.
  They represent a decomposition of a 2D function with respect
  to a 2D wavelet basis.
}
\section{GENERATION}{
This class of objects is typically returned from \code{\link{imwd}(.)}
to represent a wavelet decomposition of an image (or other 2D function).
}
\section{METHODS}{
  The \code{"imwd"} class of objects has methods for the following generic
  functions:
  \code{plot}, \code{threshold}, \code{summary}, \code{print},
  \code{draw}, \code{imwr}, \code{compress}.
}
\value{
The following components must be included in a legitimate \code{imwd} object.
\item{nlevels}{
  number of levels in wavelet decomposition. If you raise 2 to the power
  of nlevels then you get the dimension of the image that you originally
  started with.
}
\item{fl.dbase}{
  The first last database associated with the decomposition.  For images,
  this list is not very useful as each level's components is stored as
  a list component, rather than being packaged up in a single vector
  as in the 1D case.  Nevertheless the internals still need to know
  about fl.dbase to get the computations correct.
}
\item{filter}{
  A filter object as returned by "filter.select".  This component records
  the filter used in the decomposition.  The reconstruction routines
  use this component to find out what filter to use in reconstruction.
}
\item{wNLx}{
  The object will probably contain many components with names of
  this form.  These are all the wavelet coefficients of the decomposition.
  In "wNLx" the "N" refers to the level number and the "x" refers to
  the direction of the coefficients with "1" being horizontal,
  "2" being vertical and "3" being diagonal.  Note that the levels
  should be in numerically decreasing order, so if nlevels is 5, then
  there will be w5L1, w5L2, w5L3 first, then down to w1L1, w1L2, and
  w1L3.  Note that these coefficients store their data according to
  the first.last database \code{fl.dbase$first.last.d}, so refer to
  them using this, see \code{\link{first.last}}.
}
\item{w0Lconstant}{
  This is the coefficient of the bottom level scaling function coefficient.
  So for example, if you used Haar wavelets this would be the sample
  mean of the data (scaled by some factor depending on the number
  of levels, nlevels).
}
\item{bc}{This component details how the boundaries were treated in the
  decomposition.}
}
\details{
  In previous releases the original image was stored as the "original"
  component of a imwd object. This is not done now as the resulting
  objects were excessively large.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{imwd}} for examples;
  \code{\link{compress}}, \code{\link{draw}}.
}
\keyword{classes}
\keyword{methods}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
