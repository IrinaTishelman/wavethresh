\name{imwd}
\alias{imwd}
\title{2D Discrete Wavelet Transform (Image W. Decomposition)
}
\description{
This function performs the decomposition stage of Mallat's pyramid algorithm
i.e. the discrete wavelet transform for images.
}
\usage{
imwd(image, filter.number=2, bc="periodic", verbose=FALSE)
}
\arguments{
\item{image}{
Square matrix containing the image. The number of rows in the image
must be a power of 2. Since the matrix is square, this is also the number
of columns in the matrix.
}
\item{filter.number}{
The filter that you wish to use to decompose the function. The filters
are obtained from the "filter.select" function and are the compactly
supported orthonormal wavelets as described in Daubechies, I.
}
\item{bc}{
boundary treatment. The periodic (default) treatment causes the decomposition
to act as if the function you are trying to decompose is periodic (on it's
own interval). The other option is symmetric, which used to be the
default. This causes the decomposition to act as if the function extended
by symmetric reflection at each end.
}
\item{verbose}{logical; if true then informative messages are printed
whilst the computations are performed.
}}
\value{
An object of class "imwd", a list containing the wavelet coefficients
(see "imwd.object").
}
\details{
The 2D algorithm is essentially the application of many 1D filters.
First, the columns are attacked with the smoothing (H) and bandpass
(G) filters, and the rows of each of these resultant images are
attacked again with each of G and H, this results in 4 images.
Three of them, GG, GH, and HG correspond to the highest resolution
wavelet coefficients. The HH image is a smoothed version of the
original and can be further attacked in exactly the same way as the
original image to obtain GG(HH), GH(HH), and HG(HH), the wavelet
coefficients at the second highest resolution level and HH(HH)
the twice-smoothed image, which then goes on to be further attacked.

After each attack the dimension of the images is halved.
After many attacks
you will obtain four real numbers, one of which correspond to the
image smoothed many times.


Exact details of the algorithm are to be found in
Mallat 1989.
}
\seealso{\code{\link{wd}}, for background information;
  \code{\link{imwr} for reconstruction, \code{\link{plot.imwd}},
    \code{\link{draw.imwd}}
}
\examples{
# Do a decomposition of an image
#
data(lennon)
imwdL <- imwd(lennon)
# Look at the coefficients --> example(plot.imwd)
}
\keyword{smooth}
\keyword{nonlinear}
% Converted by Sd2Rd version 0.3-3.
