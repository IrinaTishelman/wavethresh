\name{wr}
\title{Discrete wavelet transform (reconstruction).}
\alias{wr}
\usage{
wr(wd.object, start.level=0, verbose=FALSE, return.object=FALSE)
}
\description{
This function performs the reconstruction stage of Mallat's pyramid algorithm,
i.e., the discrete inverse wavelet transform.
}
\arguments{
\item{wd.object}{
  A wavelet decomposition object as returned by \code{\link{wd}},
  see \code{\link{wd.object}}.}
\item{start.level}{integer; the level at which to start reconstruction.
  This is usually the first (level 0).
}
\item{verbose}{logical, controlling the printing of "informative"
  messages whilst the computations progress.  Such messages are
  generally annoying so it is turned off by default.}
\item{return.object}{logical;
If this is FALSE then the top level of the reconstruction is returned
(this is the reconstructed function at the highest resolution).
Otherwise if it is T the whole wd reconstructed object is returned.
}}
\value{
Either a vector containing the top level reconstruction or
an object of class "wd" containing the results of the reconstruction,
details to be found in help for "wd.object".
}
\section{Side Effects}{
The appropriate C object code is loaded if it isn't.
}
\details{
The code implements Mallat's pyramid algorithm (Mallat 1989).
In the reconstruction the quadrature mirror filters G and H are
supplied with c0 and d0, d1, \dots{} d(m-1) (the wavelet coefficients)
and rebuild c1,\dots{}, cm.

If wd.object was obtained directly from wd then the original function
can be reconstructued EXACTLY as cm and can be sought with

\code{accessC(wd.object, level=wd.object$levels)}

Usually, the wd.object has been modified in some way, for example,
some coefficients set to zero by threshold. Wr then reconstructs
the function with that set of wavelet coefficients.
}
\section{RELEASE}{
Release 2.2
Copyright Guy Nason 1993
}
\references{see \code{\link{wd}} for a list.
}
\seealso{\code{\link{wd}}, \code{\link{accessC}}, \code{\link{accessD}},
  \code{\link{filter.select}}, \code{\link{threshold}}.
}
\examples{
# Decompose and then exactly reconstruct test.data
example(wd)#-> wds has wd() ressult
rec.wds <- wr(wds)
rec.wds.obj <- wr(wds, return.object = TRUE)
rec.wds2 <- accessC(rec.wds.obj, level=rec.wds.obj$nlevels)
all(rec.wds == rec.wds2)# since wr() internally uses accessC()

# Look at accuracy of reconstruction
summary(abs(rec.wds - y)) #~ 10^-11

# Reconstruct a hard.thresholded object, look at the wavelet coefficients
summary(thr.wds <- wr(threshold(wds, type="hard") ))
}
\keyword{math}
\keyword{smooth}
\keyword{nonlinear}
% Converted by Sd2Rd version 0.3-3.
