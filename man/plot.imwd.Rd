\name{plot.imwd}
\alias{plot.imwd}
\title{Plot Method for an `imwd' object}
\description{
Images Wavelet Coefficients of a imwd class object
}
\usage{
\method{plot}{imwd}(imwd, scaling="by.level", co.type="abs",
     plot.type="mallat", arrangement=c(3,3),
     plot = exists("image", mode="function"),
     transform = FALSE, tfunction = sqrt,
     col = heat.colors(32), \dots)
}
\arguments{
  \item{imwd}{object of class "imwd" containing a wavelet decomposition of
    an image.}
  \item{scaling}{character string, determining the scaling applied to
    each sub-image.  The values can be
    "by.level" which means each image is scaled independently to the whole
    dynamic range of the image, otherwise the whole image is scaled as a whole
    (as in previous versions).  This argument only takes effect when the
    \code{plot.type} is \code{"mallat"}.
  }
  \item{co.type}{character string, specifying a transform to be applied to
    the coefficients before display. \cr
    If \code{co.type=="abs"}, then the absolute values of the coefficients
    will be displayed,\cr
    if \code{co.type=="mabs"}, then the negative of the absolute values
    will be displayed.  These two arguments ensure that large coefficients,
    whether positive or negative, will look different to small coefficients.\cr
    If co.type=="none", then no transforming will take place (as in previous
    releases).}
  \item{plot}{logical; if \code{TRUE}, \code{\link{image}} is used to
    display the result.}
  \item{plot.type}{
    If plot.type=="mallat", then the image within image type of plot as
    exemplified within Mallat (1989) will be produced. If plot.type=="rows",
    then the individual level/orientation plots are produced in an array
    according to the arrangement argument.
  }
  \item{arrangement}{
    Determines the parameter to pass to mfrow to set up the display for
    multiple plots per page. The default, c(3,3) specifies 3 rows and 3 columns.
  }
  \item{transform}{logical; if \code{TRUE}, then the function given by
    argument \code{tfunction} is applied.
  }
  \item{tfunction}{a (vectorizing) function; a transform to apply to the
    coefficients if \code{transform} is true.}
  \item{col}{vector of colors to use for \code{\link{image}}.}
}
\value{
  The matrix of wavelet coefficients packed in Mallat form,
  returned \code{\link{invisible}} if \code{plot} is true.
}
\section{Side Effects}{
  An image of the wavelet coefficients is produced if \code{plot} is true.
}
\details{
If plot.type=="mallat" then
the picture produced is the same as the one described by
Mallat 1989. After a decomposition there will be exactly the same
number of coefficients as there were pixels in the original image.
This function is a good way of plotting all the coefficients, but it means
that you can't really see some of the lower resolution images very clearly.

If plot.type=="rows", then each sub-image of the decomposition is plotted
at the same size so you can see the lower resolution images. By default
the arrangement of each of the sub-images is on a 3x3 array, so three levels
can fit onto one plot. If you are using a screen device then it may be
desirable to turn on the "ask before you plot" option with dev.ask(),
since the coefficients plot may run to a few pages with the "rows"
plot.type.

It is not always easy to see exactly what's going on, so there are
a few arguments that try to manipulate the (sub)image(s). The scaling
argument only works when the plot.type=="mallat" is in force. If scaling
is by.level then each subimage is scaled independently, if not then
the whole image is scaled at once. The co.type works for both plot
types and causes absolute values, negative absolute values or just
the coefficients to be plotted - this is useful for enhancing various
effects. The most flexible transformation is provided when transform==TRUE,
then the function tfunction is applied to all the coefficients and can
produce some useful contrast enhancing effects.

At each stage of the decomposition we decompose an image into
four images, each of which are half the size of the original
(see "imwd" for what these are). Three of the images correspond
to wavelet coefficients in the horizontal, vertical and diagonal
directions and these form the bottom-right, top-left and
top-right sections of the displayed image. The fourth image
is further decomposed into another four subimages. Three of which
get put into the bottom-right, top-left, and
top-right sections OF THE BOTTOM-LEFT part of the previous image
and so on and so on. It is impossible to explain this properly
in a simple fashion, so the only way to really understand what
is going on is to do it yourself and see what happens.

This function is a method for the generic function
\code{plot()} for class \code{imwd}.
It can be invoked by calling \code{plot(x)} for an
object \code{x} of the appropriate class, or directly by
calling \code{plot.imwd(x)} regardless of the
class of the object.
}
\seealso{\code{\link{imwd}, for references and background.}
}
\examples{
example(imwd)
# See the wavelet coefficient in Mallat's form
c.gray <- gray(127:0 / 128)
plot(imwdL, col = c.gray)
plot(imwdL, col = c.gray, scaling = "none")
plot(imwdL, col = c.gray, scaling = "none", co.type = "none")
plot(imwdL, col = c.gray, plot.type = "cols")
}
\keyword{hplot}
\keyword{smooth}
\keyword{nonlinear}
% Converted by Sd2Rd version 0.3-3.
