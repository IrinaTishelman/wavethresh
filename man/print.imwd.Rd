%%% $Id: print.imwd.Rd,v 1.7 2001/12/17 07:27:12 maechler Exp maechler $
\name{print.imwd}
\alias{print.imwd}
\alias{print.imwdc}
\title{Print an `imwd' or `imwdc' object}
\description{
  Prints out information about the object and then calls \code{summary()}
  on it.
}
\usage{
\method{print}{imwd}(x, \dots)
%not \method{} -- the two lines would look silly:
print.imwdc(x, \dots)
}
\arguments{
  \item{x}{an object of class \code{imwd} or \code{imwdc}, respectively.}
  \item{\dots}{further arguments to be passed to or from methods.}
}
\details{
  Contributed in release 2.2 by Martin Maechler
}
\seealso{\code{\link{imwd}}, \code{\link{imwd.object}},
  \code{\link{imwdc.object}}.
}
\keyword{utilities}

