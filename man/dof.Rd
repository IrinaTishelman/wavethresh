\name{dof}
\alias{dof}
\title{Degrees of Freedom of Wavelet}
\usage{
dof(wd)
}
\description{Compute degrees of freedom for wavelet thresholding model.}
\arguments{
  \item{wd}{The wavelet object}
}
\value{The number of degrees of freedom.
}
\details{
  The wavelet thresholding is a non-linear transform and \code{dof} returns
  the approximate number of degrees of freedom.
}
\references{see \code{\link{wd}} for a list.
}
\seealso{
\code{\link{threshold}}
}
\examples{
example(wd)
threshy <- threshold(wds)

# Compare degrees of freedom
dof(wds)	# 1024
dof(threshy)    # about 23
}
\keyword{models}

