\name{wd.object}
\alias{wd.object}
\title{Wavelet decomposition object (1D)}
\description{
These are objects of class "wd"
They represent a decomposition of a function with respect to
a wavelet basis.
}
\section{GENERATION}{
This class of objects is returned from the \code{wd} function
to represent a wavelet decomposition of a function.
Other functions also return a \code{wd.object}
}
\section{METHODS}{
The \code{"wd"} class of objects has methods for the following generic
functions:
\code{plot}, \code{threshold}, \code{summary}, \code{print}, \code{draw}.
}
\value{
  The following components must be included in a legitimate \code{wd} object.
  \item{C}{
    a vector containing each level's smoothed data.
    The wavelet transform works by applying both a smoothing filter
    and a bandpass filter to the previous level's smoothed data,
    the top level containing data at the highest resolution level.
    This the ``pyramid structure of Mallat''.
    Each of these levels are stored one after the other in this vector.
    The matrix \code{fl.dbase$first.last.c} determines exactly where each
    level is stored in the vector.\cr
    Usually, \code{\link{accessC}} should be used to extract \code{C}
    components.
  }
  \item{D}{wavelet coefficients.  If you were to write down the discrete
    wavelet transform of a function, then these D would be the
    coefficients of the wavelet basis functions.  Like the C, they are
    also formed in a pyramidal manner, but stored in a linear array.
    The storage details are to be found in \code{fl.dbase$first.last.d}.\cr
    Usually, \code{\link{accessD}} should be used to extract \code{D}
    components.
  }
  \item{nlevels}{
    The number of resolution levels in the pyramidal decomposition that produces
    the coefficients.  Therefore, \code{2^nlevels}\eqn{\equiv 2^m}{= 2^m} is the
    number of data points used in the decomposition.
    This means there will be \eqn{m} levels of wavelet coefficients (indexed
    \eqn{0,1,2,\dots, m-1}), and \eqn{m+1} levels of smoothed data
    (indexed \eqn{0,1,2,\dots{},m}).
  }
  \item{fl.dbase}{The first/last database associated with this decomposition.
    This is a list consisting of 2 integers, and 2 matrices. The matrices
    detail how the coefficients are stored in the C and D components
    of the \code{wd.object}.

    In the decomposition `extra' coefficients are generated that help take
    care of the boundary effects, this database lists where these start and
    finish, so the "true" data can be extracted.
    See \code{\link{first.last}} for more information.
  }
  \item{filter}{a list containing the details of the filter that did the
    decomposition}
  \item{bc}{how the boundaries were handled}
}
\details{
To retain your sanity the C and D coefficients should be extracted
by the \code{\link{accessC}} and \code{\link{accessD}} functions and put using
the \code{\link{putC}} and \code{\link{putD}} functions, rather than
by the \code{$} operator.

Mind you, if you want to muck about with coefficients directly,
then you'll have to do it yourself by working out what the \code{fl.dbase}
list means.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\seealso{\code{\link{wd}} for examples and background.
}
\keyword{classes}
\keyword{methods}
\keyword{smooth}
% Converted by Sd2Rd version 0.3-3.
