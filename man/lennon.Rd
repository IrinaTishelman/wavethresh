\name{lennon}
\alias{lennon}
\title{Image of John Lennon}
\description{
  The \code{lennon} matrix has 256 rows and 256 columns and
  integer values in \code{0:192} which are \emph{inverted} image gray
  scales, i.e., 0 means white and 192 is dark.
  There are a few dark speckles on the image.

  John Lennon (19xx-19xx) was \emph{the} composer/leader of the
  legendary Beatles.
}
\source{
  From Guy Nason, \email{G.P.Nason@bristol.ac.uk}
}
\author{\R format and 8bit packing by Martin Maechler}
\examples{
data(lennon)
str(lennon)

tlennon <- table(lennon)
plot(names(tlennon), sqrt(tlennon), type = "h",
     ylab = "tlennon __ sqrt scaled", yaxt = "n",
     main = "Gray value distribution of `Lennon'")
atl <- pretty(tlennon, 8)
axis(2, at=sqrt(atl), labels = formatC(atl,wid=1), las=2)

image(lennon, zlim = c(0, 192), col = gray(127:0/128))# white to dark
image(lennon, zlim = c(-10, 240), col = gray(127:0/128))
}
\keyword(datasets)
