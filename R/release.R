wvrelease <- function(do.cat = interactive())
{
    wv <- list(major = 2.2, R.minor = 8)
    ##                 ---            -
    if(do.cat)
	cat("S/R wavelet software, release ", wv$major,", installed\n",
	    "Copyright Guy Nason 1993\n",
	    "R version ", wv$major,"-", wv$R.minor,
	    ": Arne Kovac 1997; Martin Maechler, 1999-2004\n", sep="")
### Don't forget the                             ^^^^^^^^^  year range  !
    invisible(wv)
}

wvrelease()
