#### $Id: wavethresh.R,v 1.13 2001/12/15 22:40:52 maechler Exp $

accessC <- function(wd.obj, level = wd.obj$nlevels, boundary = FALSE)
{
    ctmp <- class(wd.obj)
    if(is.null(ctmp) || all(ctmp != "wd"))
	stop("argument `wd.obj' is not of class \"wd\"")
    if(level < 0) stop("Must have a positive level")
    else if(level > wd.obj$nlevels)
	stop("Cannot exceed maximum number of levels")
    level <- level + 1
    first.last.c <- wd.obj$fl.dbase$first.last.c
    first.level <- first.last.c[level, 1]
    last.level	<- first.last.c[level, 2]
    off.l <- first.last.c[level, 3]
    if(boundary) {
	n <- last.level - first.level + 1
	wd.obj$C[(off.l + 1):(off.l + n)]
    }
    else {
	n <- 2^(level - 1)
	wd.obj$C[(off.l + 1 - first.level):
                 (off.l + n - first.level)]
    }
}

accessD <- function(wd.obj, level, boundary = FALSE)
{
    ctmp <- class(wd.obj)
    if(is.null(ctmp) || all(ctmp != "wd"))
	stop("argument `wd.obj' is not of class \"wd\"")
    if(level < 0) stop("Must have a positive level")
    else if(level > wd.obj$nlevels - 1)
	stop("`level' must be less than resolution (= nlevels)")
    level <- level + 1
    first.last.d <- wd.obj$fl.dbase$first.last.d
    first.level <- first.last.d[level, 1]
    last.level	<- first.last.d[level, 2]
    off.l <- first.last.d[level, 3]
    if(boundary) {
	n <- last.level - first.level + 1
	wd.obj$D[(off.l + 1):(off.l + n)]
    }
    else {
	n <- 2^(level - 1)
	wd.obj$D[(off.l + 1 - first.level):
                 (off.l + n - first.level)]
    }
}

###-- Consider making compress a generic
compress <- function(x, ...) UseMethod("compress")

###-- MM: We should use rle() additionally or even instead
compress.default <- function(x, verbose = getOption("verbose"), ...)
{
    ## compression for sparse vectors, i.e with many  0's
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))

    n <- length(x)
    r <- sum(x != 0)
    if(n > 2 * r) {
        position <- (1:n)[x != 0]
        values <- x[position]
        answer <- list(position = position, values = values,
                       original.length = n)
        class(answer) <- "compressed"
        if(verbose)
            cat("Compressed ", n, " into ", 2 * r, "(",
                signif((100 * 2 * r)/n, 3), "%)\n")
    }
    else {
        answer <- list(vector = x)
        class(answer) <- "uncompressed"
        if(verbose)
            cat("No compression\n")
    }
    return(answer)
}

compress.imwd <- function(x, verbose = getOption("verbose"), ...)
{
    if(verbose) cat("Argument checking\n")
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "imwd"))
	stop("argument `x' is not of class \"imwd\"")
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))

    squished <-
        list(nlevels = x$nlevels, fl.dbase = x$fl.dbase,
             filter = x$filter, w0Lconstant = x$w0Lconstant, bc = x$bc)
    ##
    ##	Go round loop compressing each set of coefficients
    ##
    for(level in 0:(x$nlevels - 1)) {
        if(verbose) cat("Level ", level, "\n\t")
        nm <- lt.to.name(level, "CD")
        nm.count <- length(names(squished))
        if(verbose) cat("CD\t")
        squished$xxxx <- compress.default(x[[nm]], ver = verbose)
        names(squished)[nm.count+1] <- nm
        nm <- lt.to.name(level, "DC")
        if(verbose) cat("\tDC\t")
        squished$xxxx <- compress.default(x[[nm]], ver = verbose)
        names(squished)[nm.count+2] <- nm
        nm <- lt.to.name(level, "DD")
        if(verbose) cat("\tDD\t")
        squished$xxxx <- compress.default(x[[nm]], ver = verbose)
        names(squished)[nm.count+3] <- nm
    }
    class(squished) <- "imwdc"
    if(verbose)
        cat("Overall compression: Was: ", w <- object.size(x),
            " Now:", s <- object.size(squished), " (",
            signif((100 * s)/w, 3), "%)\n")
    squished
}

dof <- function(wd)
{
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
	stop("argument `wd' is not of class \"wd\"")

    ## Count number of non-zero coefficients
    ##
    nlev <- wd$nlevels

    ##	nnonzero counts the number of nonzero coefficients
    ##	This is already 1, since the C contains first level constant
    nnonzero <- 1
    for(i in 0:(nlev - 1)) {
        nnonzero <- nnonzero + sum(accessD(wd, lev = i) != 0)
    }
    nnonzero
}

draw <- function(x, ...) UseMethod("draw")
## methods *MUST* now have first argument `x'

draw.default <-
  function(x = filter.number, filter.number = 2,
           family = c("DaubExPhase", "DaubLeAsymm"),
	   resolution = 1024, verbose = FALSE, plot = TRUE,
	   main = paste("Wavelet Picture", if(enhance) " (Enhanced)", sep=""),
           sub = zwd$filter$name,
	   xlab = "x", ylab = expression(psi(x)),
           dimension = 1, twodplot = persp,
           enhance = TRUE, efactor = 0.05, ...)
{
    family <- match.arg(family)# one of the args, maybe abbreviated in call
    if(missing(filter.number)) filter.number <- x
    else if(filter.number != x)
        stop("`filter.number' must be identical to 1st argument `x'")
    filter.number <- as.integer(filter.number)

  resolution <- resolution/2
  ##
  ## First obtain support widths
  ##
  sp <- support(filter.number = filter.number, family = family, m = 0, n = 0)
  lh <- c(sp$phi.lh, sp$phi.rh)
  lh <- lh[1]
  rh <- sp$phi.rh + 2 * resolution - 1
  if(verbose)
    cat("Support of highest resolution wavelets is [", lh, ", ", rh, "]\n")

  pic.support <- support(filter.number = filter.number, family = family,
			 m = 0, n = 0)
  pic.support <- c(pic.support$psi.lh, pic.support$psi.rh)#
  ##
  ## Now go through all levels and see what is the lowest resolution wavelet
  ## that we can use to get the whole wavelet in the support range of the
  ## highest resolution wavelets.
  ##
  lowest.level <- log(resolution)/log(2)
  if(verbose) cat("Lowest level is: ", lowest.level, "\n")
  selection <- candidates <- NULL
  for(m in lowest.level:0) {
    if(verbose) cat("Level ", m, " testing\n")#
    ##
    ## Go through each wavelet at this level and find out
    ## it's support. Then check to see if it lies in the
    ## union of the supports of the highest resolution
    ## wavelets, and select it if it does.
    ##
    ## If fact we examine all the ones that will fit, and choose one that
    ## is near the middle - to get a nice picture.
    ##
    for(n in 0:(2^(lowest.level - m) - 1)) {
        lhs <- support(filter.number = filter.number, family = family, m = m, n = n)
        rhs <- lhs$rh
        lhs <- lhs$lh
        if(verbose) cat("LHS: ", lhs, " RHS: ", rhs, "\n")
        if(lhs >= lh && rhs <= rh) {
            candidates <- c(candidates, n)
            if(verbose) cat("Level ", m, " Position: ", n, " selected\n")
        }
    }
    if(!is.null(candidates)) {
      if(verbose) {
	cat("Candidates are \n")
	print(candidates)
      }
      n <- floor(median(candidates))
      if(verbose) cat("Choosing ", n, "\n")
      selection <- list(m = m, n = n)
      lhs <- support(filter.number = filter.number, family = family, m = m, n = n)
      rhs <- lhs$rh
      lhs <- lhs$lh
      break
    }
    if(!is.null(selection))
      break
  }
  ##
  ##
  ##	If we haven't selected anything, then set the coefficient to
  ##	be one of the highest resolution coefficients. ALL of these
  ##	are guaranteed to be in the union of all their supports!
  ##	The picture will be crap though!
  ##
  if(is.null(selection)) selection <- list(m = 0, n = 0)#
  ##
  ##	Build a wd object structure consisting solely of zeroes.
  ##
  zwd <- wd(rep(0, length = resolution * 2),
            filter.number = filter.number, family = family, bc = "symmetric")#
  ##
  ##	Insert a vector containing a 1 where we want to put the coefficient
  ##
  wd.lev <- lowest.level - selection$m
  if(verbose) cat("Coefficient insertion at wd level: ", wd.lev, "\n")
  if(wd.lev == 0)
    pickout <- 1
  else {
    pickout <- rep(0, 2^wd.lev)
    pickout[selection$n + 1] <- 1
  }
  zwd <- putD(zwd, level = wd.lev, v = pickout)#
  ##
  ##	Reconstruct
  ##
  zwr <- wr(zwd)			#
  ##
  ##	Scales
  ##
  if(verbose) {
    cat("ps: ", pic.support[1], pic.support[2], "\n")
    cat("lh,rh: ", lh, rh, "\n")
    cat("lhs,rhs: ", lhs, rhs, "\n")
  }
  aymax <- ((pic.support[2] - pic.support[1]) * (rh - lh))/(rhs - lhs)
  ax <- pic.support[1] - (aymax * (lhs - lh))/(rh - lh)
  ay <- ax + aymax
  if(verbose) cat("ax,ay ", ax, ay, "\n")#
  ##
  ##	Scale up y values, because we're actually using a higher "resolution"
  ##	wavelet than psi(x)
  ##
  zwr <- zwr * sqrt(2)^(selection$m + 1)#
  ##
  ##	Plot it if required
  ##
  x <- seq(from = ax, to = ay, length = resolution * 2)
  if(enhance) {
    sv <- (abs(zwr) > efactor * range(abs(zwr))[2])
    sv <- (1:length(sv))[sv]
    tr <- range(sv)
    sv <- tr[1]:tr[2]
    x <- x[sv]
    zwr <- zwr[sv]
  }
  if(plot) {
    if(dimension == 1)
      plot(x = x, y = zwr, main = main, sub = sub, xlab =
	   xlab, ylab = ylab, type = "l", ...)
    else if(dimension == 2) {
      twodplot(x = x, y = x, z = outer(zwr, zwr), xlab = xlab,
	       ylab = xlab, zlab = ylab, ...)
      title(main = main, sub = sub)
      invisible()
    }
    else stop("Can only do 1 or 2 dimensional plots")
  }
  else {
    if(dimension == 1)
      return(list(x = x, y = zwr))
    else if(dimension == 2)
      return(list(x = x, y = x, z = outer(zwr, zwr)))
    else stop("Can only do 1 or 2 dimensional plots")
  }
}

draw.wd <- function(x, ...)
{
    filter <- x$filter
    draw.default(filter.number = filter$filter.number,
                 family = filter$family, ...)
}

draw.imwdc <- #.Alias(draw.imwd)
draw.imwd <- function(x, resolution = 128, ...)
    draw.wd(x, resolution = resolution, dim = 2, ...)

filter.select <-
    function(filter.number, family = c("DaubExPhase", "DaubLeAsymm"),
	     constant = 1)
{
    family <- match.arg(family)# one of the two, maybe abbrev. in call
    if((filter.number <- as.integer(filter.number)) <= 0)
	stop("invalid `filter.number'")
    if(family == "DaubExPhase") {
	##
	##	The following wavelet coefficients are taken from
	##	Daubechies, I (1988) Orthonormal Bases of Wavelets
	##	Communications on Pure and Applied Mathematics. Page 980
	##	or Ten Lectures on Wavelets, Daubechies, I, 1992
	##	CBMS-NSF Regional Conference Series, page 195, Table 6.1
	##
	##	Comment from that table reads:
	##	 "The filter coefficients for the compactly supported wavelets
	##	  with extremal phase and highest number of vanishing moments
	##	  compatible with their support width".
	##
	filter.name <-
	    switch(filter.number,
	       { ## filter.number  -- 1 --
		   ## This is for the Haar basis. (not in Daubechies).
		   H <- rep(1/sqrt(2), 2)
		   "Haar wavelet"
	       },
	       { ## filter.number  -- 2 --
		   H <- c(0.48296291314500001,
			  0.83651630373800001,
			  0.22414386804200001,
			  -0.12940952255099999)
		   "Daub cmpct on ext. phase N=2"
	       },
	       { ## filter.number  -- 3 --
		   H <- c(0.33267055294999998,
			  0.80689150931099995,
			  0.45987750211799999,	# 3
			  -0.13501102001000001,
			  -0.085441273882,
			  0.035226291882000001) # 6
		   "Daub cmpct on ext. phase N=3"
	       },
	       { ## filter.number  -- 4 --
		   H <- c(0.23037781330900001,
			  0.71484657055300005,
			  0.63088076793000003,	# 3
			  -0.027983769417,
			  -0.18703481171899999,
			  0.030841381836,	# 6
			  0.032883011667000001,
			  -0.010597401785)	# 8
		   "Daub cmpct on ext. phase N=4"
	       },
	       { ## filter.number  -- 5 --
		   H <- c(0.160102397974,
			  0.60382926979700002,
			  0.72430852843799998,	# 3
			  0.138428145901,
			  -0.242294887066,
			  -0.032244869585000002,# 6
			  0.07757149384,
			  -0.006241490213,
			  -0.012580751999,	# 9
			  0.003335725285)
		   "Daub cmpct on ext. phase N=5"
	       },
	       { ## filter.number  -- 6 --
		   H <- c(0.11154074335,
			  0.49462389039799998,
			  0.751133908021,	# 3
			  0.31525035170900001,
			  -0.22626469396500001,
			  -0.12976686756700001, # 6
			  0.097501605586999995,
			  0.02752286553,
			  -0.031582039318000001,# 9
			  0.000553842201,
			  0.004777257511,
			  -0.001077301085)	# 12
		   "Daub cmpct on ext. phase N=6"
	       },
	       {  ## filter.number -- 7 --
		   H <- c(0.077852054084999997,
			  0.396539319482,
			  0.72913209084599995,	# 3
			  0.469782287405,
			  -0.14390600392899999,
			  -0.22403618499399999,	# 6
			  0.071309219267,
			  0.080612609151000006,
			  -0.038029936935000001,# 9
			  -0.016574541631,
			  0.012550998556,
			  0.000429577973,	# 12
			  -0.001801640704,
			  0.0003537138)		# 14
		   "Daub cmpct on ext. phase N=7"
	       },
	       { ## filter.number  -- 8 --
		   H <- c(0.054415842243000001,
			  0.31287159091400002,
			  0.67563073629699999,	# 3
			  0.58535468365400001,
			  -0.015829105256,
			  -0.28401554296199999,	# 6
			  0.000472484574,
			  0.12874742662,
			  -0.017369301002000001,# 9
			  -0.044088253931,
			  0.013981027917,
			  0.008746094047,	# 12
			  -0.004870352993,
			  -0.000391740373,
			  0.000675449406,	# 15
			  -0.000117476784)	# 16
		   "Daub cmpct on ext. phase N=8"
	       },
	       { ## filter.number  -- 9 --
		   H <- c(0.038077947363999998,
			  0.24383467461300001,
			  0.60482312369000002,	# 3
			  0.65728807805099998,
			  0.13319738582499999,
			  -0.293273783279,	# 6
			  -0.096840783222999993,
			  0.14854074933799999,
			  0.030725681479000001, # 9
			  -0.067632829061000002,
			  0.000250947115,
			  0.022361662124,	# 12
			  -0.004723204758,
			  -0.004281503682,
			  0.001847646883,	# 15
			  0.000230385764,
			  -0.000251963189,
			  3.934732e-05)		# 18
		   "Daub cmpct on ext. phase N=9"
	       },
	       { ## filter.number -- 10 --
		   H <- c(0.026670057901000001,
			  0.188176800078,
			  0.52720118893199996,	# 3
			  0.688459039454,
			  0.28117234366100002,
			  -0.24984642432699999, # 6
			  -0.19594627437699999,
			  0.127369340336,
			  0.093057364604000006, # 9
			  -0.071394147165999997,
			  -0.029457536822,
			  0.033212674058999997, # 12
			  0.003606553567,
			  -0.010733175483,
			  0.001395351747,	# 15
			  0.001992405295,
			  -0.000685856695,
			  -0.000116466855,	# 18
			  9.358867e-05,
			  -1.3264203e-05)	# 20
		   "Daub cmpct on ext. phase N=10"
	       }
		   )#  switch ( filter.number )
	if(is.null(filter.name))
	    stop(paste("Unknown filter number (not in {1:10}) for", family,
		       "(Daubechies wavelets with extremal phase...)"))

    }
    else { ## if(family == "DaubLeAsymm")
	##
	##	The following wavelet coefficients are taken from
	##	Ten Lectures on Wavelets, Daubechies, I, 1992
	##	CBMS-NSF Regional Conference Series, page 198, Table 6.3
	##
	##	Comment from that table reads:
	##	"The low pass filter coefficients for the "least-asymmetric"
	##	compactly supported wavelets with maximum number of
	##	vanishing moments, for N = 4 to 10
	##

	filter.name <-
	    switch(filter.number,
		   NULL, # 1
		   NULL, # 2
		   NULL, # 3,
	       { ## filter.number  -- 4 --
		   H <- c(-0.107148901418,
			  -0.041910965125,
			  0.703739068656,	# 3
			  1.136658243408,
			  0.421234534204,
			  -0.140317624179,	# 6
			  -0.017824701442,
			  0.045570345896)	# 8
		   "Daub cmpct on least asymm N=4"
	       },
	       { ## filter.number  -- 5 --
		   H <- c(0.038654795955,
			  0.041746864422,
			  -0.055344186117,	# 3
			  0.281990696854,
			  1.023052966894,
			  0.89658164838,	# 6
			  0.023478923136,
			  -0.247951362613,
			  -0.029842499869,	# 9
			  0.027632152958)	# 10
		   "Daub cmpct on least asymm N=5"
	       },
	       { ## filter.number  -- 6 --
		   H <- c(0.021784700327,
			  0.004936612372,
			  -0.166863215412,	# 3
			  -0.068323121587,
			  0.694457972958,
			  1.113892783926,	# 6
			  0.477904371333,
			  -0.102724969862,
			  -0.029783751299,	# 9
			  0.06325056266,
			  0.002499922093,
			  -0.011031867509)	# 12
		   "Daub cmpct on least asymm N=6"
	       },
	       { ## filter.number  -- 7 --
		   H <- c(0.003792658534,
			  -0.001481225915,
			  -0.017870431651,	# 3
			  0.043155452582,
			  0.096014767936,
			  -0.070078291222,	# 6
			  0.024665659489,
			  0.758162601964,
			  1.085782709814,	# 9
			  0.408183939725,
			  -0.198056706807,
			  -0.152463871896,	# 12
			  0.005671342686,
			  0.014521394762)	# 14
		   "Daub cmpct on least asymm N=7"
	       },
	       { ## filter.number  -- 8 --
		   H <- c(0.002672793393,
			  -0.0004283943,
			  -0.021145686528,	# 3
			  0.005386388754,
			  0.069490465911,
			  -0.038493521263,	# 6
			  -0.073462508761,
			  0.515398670374,
			  1.099106630537,	# 9
			  0.68074534719,
			  -0.086653615406,
			  -0.202648655286,	# 12
			  0.010758611751,
			  0.044823623042,
			  -0.000766690896,	# 15
			  -0.004783458512)	# 16
		   "Daub cmpct on least asymm N=8"
	       },
	       { ## filter.number  -- 9 --
		   H <- c(0.001512487309,
			  -0.000669141509,
			  -0.014515578553,	# 3
			  0.012528896242,
			  0.087791251554,
			  -0.02578644593,	# 6
			  -0.270893783503,
			  0.049882830959,
			  0.873048407349,	# 9
			  1.015259790832,
			  0.337658923602,
			  -0.077172161097,	# 12
			  0.000825140929,
			  0.042744433602,
			  -0.016303351226,	# 15
			  -0.018769396836,
			  0.000876502539,
			  0.001981193736)	# 18
		   "Daub cmpct on least asymm N=9"
	       },
	       { ## filter.number  -- 10 --
		   H <- c(0.001089170447,
			  0.00013524502,
			  -0.01222064263,	# 3
			  -0.002072363923,
			  0.064950924579,
			  0.016418869426,	# 6
			  -0.225558972234,
			  -0.100240215031,
			  0.667071338154,	# 9
			  1.0882515305,
			  0.542813011213,
			  -0.050256540092,	# 12
			  -0.045240772218,
			  0.07070356755,
			  0.008152816799,	# 15
			  -0.028786231926,
			  -0.001137535314,
			  0.006495728375,	# 18
			  8.0661204e-05,
			  -0.000649589896)	# 20
		   "Daub cmpct on least asymm N=10"
	       }
		   ) ## switch ( filter.number )

	if(is.null(filter.name))
	    stop(paste("Unknown filter number (not in {4:10}) for", family,
		       "\n (Daubechies wavelets with least asymmetry...)"))
	H <- H/sqrt(2)

    } # ""DaubLeAsymm" family

    H <- H/constant
    return(list(H = H, name = filter.name, family = family,
		filter.number = filter.number))
}

first.last <- function(LengthH, DataLength, bc = "periodic")
{
    levels <- log(DataLength)/log(2)
    first.last.c <- matrix(0, nrow = levels + 1, ncol = 3,
			   dimnames = list(NULL, c("First", "Last", "Offset")))
    first.last.d <- matrix(0, nrow = levels, ncol = 3,
			   dimnames = list(NULL, c("First", "Last", "Offset")))
    if(bc == "periodic") {
	## Periodic boundary correction
	first.last.c[, 1] <- rep(0, levels + 1)
	first.last.c[, 2] <- 2^(0:levels) - 1
	first.last.c[, 3] <- rev(c(0, cumsum(rev(1 + first.last.c[, 2])
					     )[1:levels]))
	first.last.d[, 1] <- rep(0, levels)
	first.last.d[, 2] <- 2^(0:(levels - 1)) - 1
	first.last.d[, 3] <- rev(c(0, cumsum(rev(1 + first.last.d[, 2])
					     )[1:(levels - 1)]))
	ntotal <- 2 * DataLength - 1
	ntotal.d <- DataLength - 1
    }
    else if(bc == "symmetric") {
	## Symmetric boundary reflection
	first.last.c[levels + 1, 1] <- 0
	first.last.c[levels + 1, 2] <- DataLength - 1
	first.last.c[levels + 1, 3] <- 0
	ntotal <- first.last.c[levels + 1, 2] - first.last.c[levels + 1,
							     1] + 1
	ntotal.d <- 0
	for(i in levels:1) {
	    first.last.c[i, 1] <- trunc(0.5 * (1 - LengthH +
					       first.last.c[i + 1, 1]))
	    first.last.c[i, 2] <- trunc(0.5 * first.last.c[i + 1, 2
							   ])
	    first.last.c[i, 3] <- first.last.c[i + 1, 3] +
		first.last.c[i + 1, 2] - first.last.c[i + 1, 1] +
		    1
	    first.last.d[i, 1] <- trunc(0.5 * (first.last.c[i + 1,
							    1] - 1))
	    first.last.d[i, 2] <- trunc(0.5 * (first.last.c[i + 1,
							    2] + LengthH - 2))
	    if(i != levels) {
		first.last.d[i, 3] <- first.last.d[i + 1, 3] +
		    first.last.d[i + 1, 2] - first.last.d[i + 1,
							  1] + 1
	    }
	    ntotal <- ntotal + first.last.c[i, 2] - first.last.c[i,
								 1] + 1
	    ntotal.d <- ntotal.d + first.last.d[i, 2] -
		first.last.d[i, 1] + 1
	}
    }
    else {
	stop("Unknown boundary correction method")
    }
    names(ntotal) <- NULL
    names(ntotal.d) <- NULL
    list(first.last.c = first.last.c, ntotal = ntotal,
	 first.last.d = first.last.d, ntotal.d = ntotal.d)
}

imwd <- function(image, filter.number = 2,
                 bc = c("periodic","symmetric"),
                 verbose = getOption("verbose"))
{
    if(verbose) cat("Argument checking...")
    bc <- match.arg(bc)
    if(nrow(image) != ncol(image))
        stop("Number of rows and columns in image are not identical")
    if(verbose) cat("...done\nFilter...")
    ##	Select wavelet filter -- MM: why no choice for family?
    filter <- filter.select(filter.number)
    Csize <- nrow(image)

    ## Check that Csize is a power of 2
    ##
    nlevels <- log(Csize)/log(2)
    if(round(nlevels) != nlevels)
        stop("The image size is not a power of 2")

    ## Set-up first/last database
    ##
    if(verbose) cat("...selected\nFirst/last database...")
    fl.dbase <- first.last(LengthH = length(filter$H),
                           DataLength = Csize, bc = bc)#
    first.last.c <- fl.dbase$first.last.c
    first.last.d <- fl.dbase$first.last.d#

    ## Set up answer list
    ##
    image.decomp <-
        list(nlevels = nlevels, fl.dbase = fl.dbase, filter = filter)
    ## We used to return the original image as well, but this is huge.
    ##  image.decomp <- c(image.decomp, list(original = as.vector(image)))

    if(verbose) cat("...built\n")

    ## Ok, go round loop doing decompositions
    ##
    nbc <- switch(bc,
                  periodic = 1,
                  symmetric = 2)
    if(is.null(nbc))
        stop("Unknown boundary handling")
    smoothed <- as.vector(image)
    if(verbose) {
        cat(bc, " boundary handling\n")
        cat("Decomposing...")
    }
    for(level in seq(nrow(first.last.d), 1, -1)) {
        if(verbose) cat(level - 1, "")
        LengthCin  <- first.last.c[level+1, 2] - first.last.c[level+1, 1] + 1
        LengthCout <- first.last.c[level,   2] - first.last.c[level,   1] + 1
        LengthDout <- first.last.d[level,   2] - first.last.d[level,   1] + 1
        z <- .C("StoIDS",
                C = as.double(smoothed),
                Csize = as.integer(LengthCin),
                firstCin   = as.integer(first.last.c[level + 1, 1]),
                H = as.double(filter$H),
                LengthH    = as.integer(length(filter$H)),
                LengthCout = as.integer(LengthCout),
                firstCout  = as.integer(first.last.c[level, 1]),
                lastCout   = as.integer(first.last.c[level, 2]),
                LengthDout = as.integer(LengthDout),
                firstDout  = as.integer(first.last.d[level, 1]),
                lastDout   = as.integer(first.last.d[level, 2]),
                ImCC = numeric(LengthCout ^ 2),
                ImCD = numeric(LengthCout ^ 2),
                ImDC = numeric(LengthCout ^ 2),
                ImDD = numeric(LengthCout ^ 2),
                nbc  = as.integer(nbc),
                error = as.integer(0))
        error <- z$error
        if(error != 0) {
            cat("Error was ", error, "\n")
            stop("Error reported")
        }
        smoothed <- z$ImCC
        ##	 if(verbose) cat("Assigning wavelet coefficients\n")
	nm.count <- length(names(image.decomp))
        nm <- lt.to.name(level - 1, "CD")
        image.decomp$xxxx <- z$ImCD
	names(image.decomp)[nm.count+1] <- nm
        nm <- lt.to.name(level - 1, "DC")
        image.decomp$xxxx <- z$ImDC
	names(image.decomp)[nm.count+2] <- nm
        nm <- lt.to.name(level - 1, "DD")
        image.decomp$xxxx <- z$ImDD
	names(image.decomp)[nm.count+3] <- nm
    }
    if(verbose) cat("\nReturning answer...\n")
    image.decomp$w0Lconstant <- smoothed
    image.decomp$bc <- bc
    class(image.decomp) <- "imwd"
    image.decomp
}

imwr <- function(imwd, ...) UseMethod("imwr")

imwr.imwd <- function(imwd, bc = imwd$bc, verbose = getOption("verbose"), ...)
{
    if(verbose) cat("Argument checking...")#
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))
    ##
    ##	 Check class of imwd
    ##
    ctmp <- class(imwd)
    if(is.null(ctmp) || all(ctmp != "imwd"))
        stop("argument `imwd' is not of class \"imwd\"")

    filter <- imwd$filter
    if(verbose)
        cat("...done\nFirst/last database...")
    fl.dbase <- imwd$fl.dbase
    first.last.c <- fl.dbase$first.last.c
    first.last.d <- fl.dbase$first.last.d
    if(verbose)
        cat("...extracted\nReconstructing...")
    ImCC <- imwd$w0Lconstant
    ##
    ## Ok, go round loop doing reconstructions
    ##
    for(level in seq(2, 1 + imwd$nlevels)) {
        if(verbose)
            cat(level - 1, " ")
        LengthCin <- first.last.c[level - 1, 2] -
            first.last.c[level - 1, 1] + 1
        LengthCout <- first.last.c[level, 2] -
            first.last.c[level, 1] + 1
        LengthDin <- first.last.d[level - 1, 2] -
            first.last.d[level - 1, 1] + 1
        error <- 0
        ImOut <- rep(0, LengthCout^2)
        nbc <- switch(bc,
                      periodic = 1,
                      symmetric = 2)
        if(is.null(nbc))
            stop("Unknown boundary handling")
        z <- .C("StoIRS",
                ImCC = as.double(ImCC),
                ImCD = as.double(imwd[[lt.to.name(level - 2, "CD")]]),
                ImDC = as.double(imwd[[lt.to.name(level - 2, "DC")]]),
                ImDD = as.double(imwd[[lt.to.name(level - 2, "DD")]]),
                LengthCin = as.integer(LengthCin),
                firstCin = as.integer(first.last.c[level - 1, 1]),
                lastCin	 = as.integer(first.last.c[level - 1, 2]),
                LengthDin = as.integer(LengthDin),
                firstDin = as.integer(first.last.d[level - 1, 1]),
                lastDin	 = as.integer(first.last.d[level - 1, 2]),
                H = as.double(filter$H),
                LengthH = as.integer(length(filter$H)),
                LengthCout = as.integer(LengthCout),
                firstCout = as.integer(first.last.c[level, 1]),
                lastCout  = as.integer(first.last.c[level, 2]),
                ImOut = as.double(ImOut),
                nbc = as.integer(nbc),
                error = as.integer(error))
        error <- z$error
        if(error != 0) {
            cat("Error was ", error, "\n")
            stop("Error reported")
        }
        ## Do something with ImOut
        ImCC <- z$ImOut
    }
    if(verbose)
        cat("\nReturning image\n")	# Return the image
    matrix(ImCC, nrow = 2^(imwd$nlevels))
}

imwr.imwdc <- function(imwd, bc = imwd$bc, verbose = getOption("verbose"), ...)
{
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))
    if(verbose) cat("Uncompressing...\n")
    imwd2 <- uncompress(imwd, ver = verbose)
    if(verbose) cat("Reconstructing...\n")
    imwr(imwd2, verbose = verbose)
}

lt.to.name <- function(level, type)
{
##
## This function converts the level and type (horizontal, vertical, diagonal)
## of wavelet coefficients to a character string "wnLx" which should be
## interpreted as "nth Level, coefficients x", where x is 1, 2 or 3 in the
## scheme of Mallat. (So 1 is horizontal, 2 is vertical and 3 is diagonal).
## w is on the front to indicate that these are wavelet coefficients
##
    return(paste("w", as.character(level), "L",
		 switch(as.character(type),
			CD = "1",
			DC = "2",
			DD = "3",
			stop("illegal `type'")), sep = ""))
}

plot.imwd <-
    function(x, scaling = "by.level", co.type = c("abs", "mabs", "none"),
	     plot.type = c("mallat", "cols"),
	     arrangement = c(3, 3),
	     plot = exists("image", mode = "function"),
	     transform = FALSE, tfunction = sqrt, col = heat.colors(32), ...)
{
    plot.type <- match.arg(plot.type)
    co.type   <- match.arg(co.type)
    ## Check class of x
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "imwd"))
	stop("argument `x' is not of class \"imwd\"")

    first.last.d <- x$fl.dbase$first.last.d
    first.last.c <- x$fl.dbase$first.last.c

    do.level <- function(L) {
	## do common things for level L	 for both plot.type's
        ## "<<-" := exporting to caller
	ndata <<- 2^(L - 1)
	firstD <- first.last.d[L, 1]
	lastD  <- first.last.d[L, 2]
	LengthD <- lastD - firstD + 1
	sel <<- seq(from = (1 - firstD), length = ndata)#

	## Extract CD for this level
	nm <- lt.to.name(L - 1, "CD")
	msub1 <- matrix(x[[nm]], nrow = LengthD, ncol = LengthD)#

	## Extract DC for this level
	nm <- lt.to.name(L - 1, "DC")
	msub2 <- matrix(x[[nm]], nrow = LengthD, ncol = LengthD)#

	## Extract DD for this level
	nm <- lt.to.name(L - 1, "DD")
	msub3 <- matrix(x[[nm]], nrow = LengthD, ncol = LengthD)#

	## Work out if we want to display the absolute values
	##	or the actual values
	switch(co.type,
	       "abs" = {
		   msub1 <- abs(msub1)
		   msub2 <- abs(msub2)
		   msub3 <- abs(msub3)
	       },
	       "mabs" = {
		   msub1 <-  - abs(msub1)
		   msub2 <-  - abs(msub2)
		   msub3 <-  - abs(msub3)
	       },
	       "none" = {})
	if(transform) {
	    m1 <<- tfunction(msub1)
	    m2 <<- tfunction(msub2)
	    m3 <<- tfunction(msub3)
	}
	else {
	    m1 <<- msub1
	    m2 <<- msub2
	    m3 <<- msub3
	}
    }## do.level()

    if(plot.type == "mallat") {

        Csize <- 2^(x$nlevels)
        m <- matrix(0, nrow = Csize, ncol = Csize)

        for(level in (x$nlevels):1) {

            do.level(level)

            if(scaling == "by.level") {
                r.m1 <- range(m1)
                r.m2 <- range(m2)
                r.m3 <- range(m3)
                mu1 <- 249/(r.m1[2] - r.m1[1])
                mu2 <- 249/(r.m2[2] - r.m2[1])
                mu3 <- 249/(r.m3[2] - r.m3[1])
                m1 <- mu1 * (m1 - r.m1[1])
                m2 <- mu2 * (m2 - r.m2[1])
                m3 <- mu3 * (m3 - r.m3[1])
            }
            else {
                range.m <- range(c(m1, m2, m3))
                multiplier <- 255/(range.m[2] - range.m[1])
                m1 <- multiplier * (m1 - range.m[1])
                m2 <- multiplier * (m2 - range.m[1])
                m3 <- multiplier * (m3 - range.m[1])#
            }
            m[(ndata + 1):(2 * ndata), 1:ndata] <- m1[sel, sel]
            m[1:ndata, (ndata + 1):(2 * ndata)] <- m2[sel, sel]
            m[(ndata + 1):(2 * ndata), (ndata + 1):(2 * ndata)] <-
                m3[sel, sel]
        }
        if(plot) {
            image(z = m, xaxt = "n", yaxt = "n", col = col, ...)
            axis(1, at = c(0, 2^((x$nlevels - 3):(x$nlevels))))
            axis(2, at = c(0, 2^((x$nlevels - 3):(x$nlevels))))
            return(invisible(m))
        }
        else return(m)
    }
    else { ## plot.type == "cols"
        oldpar <- par(mfrow = arrangement, pty = "s", ...)
        on.exit(par(oldpar))
        for(level in (x$nlevels:1)) {

            do.level(level)

            if(plot) {
                xlabstr <- paste("Level", level - 1, "(horizontal)")
                image(z = m1, xlab = xlabstr, col = col)
                xlabstr <- paste("Level", level - 1, "(vertical)")
                image(z = m2, xlab = xlabstr, col = col)
                xlabstr <- paste("Level", level - 1, "(diagonal)")
                image(z = m3, xlab = xlabstr, col = col)
            }
        }
        return(invisible())
    }
}

plot.imwdc <- function(x, verbose = getOption("verbose"), ...)
{
    imwd <- uncompress(x, verbose = verbose)
    return(plot(imwd, ...))
}

plot.wd <- function(x, xlabels, first.level = 1,
		    main = "Wavelet Decomposition Coefficients",
                    sub = x$filter$name,
		    xlab = "Translate", ylab = "Resolution Level",
		    scaling = "by.level", rhlab = FALSE,
		    col = par("fg"), lty = par("lty"), lwd = par("lwd"),
		    ...)
{
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "wd"))
	stop("argument `x' is not of class \"wd\"")

    levels <- x$nlevels
    nlevels <- levels - first.level
    n <- 2^(levels - 1)
    plot(c(0, 0, n, n), c(0, nlevels + 1, nlevels + 1, 0), type = "n",
	 xlab = xlab, ylab = ylab, main = main, yaxt = "n", xaxt = "n",
	 sub = sub, ...)
    i.lev <- (levels - 1):first.level
    axis(2, at = 1:nlevels, labels = i.lev)
    if(missing(xlabels)) {
	axx <- 2^(nlevels - 2)
	axx <- axx * 0:4
	axis(1, at = axx)
    }
    else {
	axx <- pretty(1:n, nint = 3)
	if(axx[length(axx)] > n)
	    axx[length(axx)] <- n
	axx[axx == 0] <- 1
	axl <- signif(xlabels[axx], dig = 3)
	axis(1, at = axx, labels = axl)
    }
    ix <- 1:n
    height <- 1
    first.last.d <- x$fl.dbase$first.last.d
    if(scaling == "global") {
	my <- 0
	for(i in i.lev) {
	    y <- accessD(x, i)
	    my <- max(c(my, abs(y)))
	}
    }
    axr <- numeric(0)
    for(i in i.lev) {
	n <- 2^i
	y <- accessD(x, i)
	xplot <- ix
	ly <- length(y)
	if(scaling == "by.level")
	    my <- max(abs(y))
	y <- (0.5 * y)/my
	axr <- c(axr, my)
	segments(xplot, height, xplot, height + y,
		 col = col, lty = lty, lwd = lwd)
	if(i != first.level) {
	    x1 <- ix[seq(1, n - 1, 2)]
	    x2 <- ix[seq(2, n, 2)]
	    ix <- (x1 + x2)/2
	    height <- height + 1
	}
    }
    if(rhlab)
	axis(4, at = 1:length(axr), labels = signif(axr, 3))
    invisible(axr)
}

print.imwd <- function(x, ...)
{
    cat("Class imwd : Discrete Image Wavelet Transform Object:\n",
	"      ~~~~ : List with ", length(x), " components with names\n",
	"            ", names(x), "\n\n",
	"$ wNLx are LONG coefficient vectors !\n",
	"\nsummary(.):\n----------\n")
    print(summary.imwd(x, ...))
    invisible(x)
}

print.imwdc <- function(x, ...)
{
    cat("Class imwdc : Compressed Discrete Image Wavelet Transform Object:\n",
	"      ~~~~~ : List with ", length(x), " components with names\n")
    cat("             ", names(x), "\n\n",
      	"$ wNLx are LONG coefficient vectors !\n",
	"\nsummary(.):\n----------\n")
    print(summary.imwdc(x, ...))
    invisible(x)
}

print.wd <- function(x, ...)
{
    cat("Class wd : Discrete Wavelet Transform Object:\n",
	"      ~~ : List with ", length(x), " components with names\n",
	"          ", names(x), "\n\n",
	"$ C and $ D are LONG coefficient vectors !\n",
	"\nsummary(.):\n----------\n")
    print(summary.wd(x, ...))
    invisible(x)
}

putC <- function(wd, level, v, boundary = FALSE)
{
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
        stop("argument `wd' is not of class \"wd\"")
    if(level < 0) stop("level too small")
    else if(level > wd$nlevels) stop("level too big")
    flc <- wd$fl.dbase$first.last.c[level + 1, ]
    if(!boundary) {
        n <- 2^level
        i1 <- flc[3] + 1 - flc[1]
        i2 <- flc[3] + n - flc[1]
    }
    else {
        n <- flc[2] - flc[1] + 1
        i1 <- flc[3] + 1
        i2 <- flc[3] + n
    }
    if(length(v) != n)
        stop("I think that the length of v is wrong")
    wd$C[i1:i2] <- v
    wd
}

putD <- function(wd, level, v, boundary = FALSE)
{
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
        stop("argument `wd' is not of class \"wd\"")
    if(level < 0) stop("level too small")
    else if(level >= wd$nlevels) stop("level too big")
    fld <- wd$fl.dbase$first.last.d[level + 1, ]
    if(!boundary) {
        n <- 2^level
        i1 <- fld[3] + 1 - fld[1]
        i2 <- fld[3] + n - fld[1]
    }
    else {
        n <- fld[2] - fld[1] + 1
        i1 <- fld[3] + 1
        i2 <- fld[3] + n
    }
    if(length(v) != n)
        stop("I think that the length of v is wrong")
    wd$D[i1:i2] <- v
    wd
}

summary.imwd <- function(object, ...)
{
    ## Check class of object
    ctmp <- class(object)
    if(is.null(ctmp) || all(ctmp != "imwd"))
        stop("argument `object' is not of class \"imwd\"")
    fl.c <- object$fl.dbase$first.last.c
    pix <- fl.c[object$nlevels + 1, 2] - fl.c[object$nlevels + 1, 1] + 1
    cat("UNcompressed image wavelet decomposition structure\n")
    cat("Levels: ", object$nlevels, "\n")
    cat("Original image was", pix, "x", pix, " pixels.\n")
    cat("Filter was: ", object$filter$name, "\n")
    cat("Boundary handling: ", object$bc, "\n")
}

summary.imwdc <- function(object, ...)
{
    ## Check class of object
    ctmp <- class(object)
    if(is.null(ctmp) || all(ctmp != "imwdc"))
        stop("argument `object' is not of class \"imwdc\"")
    fl.c <- object$fl.dbase$first.last.c
    pix <- fl.c[object$nlevels + 1, 2] - fl.c[object$nlevels + 1, 1] + 1
    cat("Compressed image wavelet decomposition structure\n")
    cat("Levels: ", object$nlevels, "\n")
    cat("Original image was", pix, "x", pix, " pixels.\n")
    cat("Filter was: ", object$filter$name, "\n")
    cat("Boundary handling: ", object$bc, "\n")
}

summary.wd <- function(object, ...)
{
    pix <- length(accessC(object))          # this is HIGHLY inefficient
    cat("Levels:  ", object$nlevels,
	"\nLength of original:  ", pix,
	"\nFilter was:  ", object$filter$name,
	"\nBoundary handling:  ", object$bc, "\n", sep = "")
}

support <- function(filter.number = 2, family = c("DaubExPhase", "DaubLeAsymm"),
                    m = 0, n = 0)
{
    family <- match.arg(family)
    m <- m + 1
    switch(family,
           "DaubExPhase" = {
               a <-  - (filter.number - 1)
               b <- filter.number
               lh <- 2^( + m) * (a + n)
               rh <- 2^( + m) * (b + n)
               list(lh = lh, rh = rh, psi.lh = 	- (filter.number - 1),
                    psi.rh = filter.number,
                    phi.lh = 0, phi.rh = 2 * filter.number - 1)
           },
           "DaubLeAsymm" = {
               a <-  - (filter.number - 1)
               b <- filter.number
               lh <- 2^( + m) * (a + n)
               rh <- 2^( + m) * (b + n)
               list(lh = lh, rh = rh, psi.lh = 	- (filter.number - 1),
                    psi.rh = filter.number,
                    phi.lh = 0, phi.rh = 2 * filter.number - 1)
           })
}

threshold <- function(x, ...) UseMethod("threshold")

threshold.imwd <-
  function(x, levels = 3:(x$nlevels - 1),
	   type = "hard", policy = "universal", by.level = FALSE, value = 0,
	   dev = var, verbose = getOption("verbose"),
	   return.threshold = FALSE, compression = TRUE, ...)
{
    ## Check class of x
    if(verbose) cat("Argument checking\n")
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "imwd"))
        stop("argument `x' is not of class \"imwd\"")
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))

    if(policy != "universal" && policy != "manual" && policy !=
       "probability")
        stop("Only policys are universal, manual and probability at present")
    if(type != "hard" && type != "soft")
        stop("Only hard or soft thresholding at	 present")
    r <- range(levels)
    if(r[1] < 0)
        stop("levels out of range, level too small")
    if(r[2] > x$nlevels - 1)
        stop("levels out of range, level too big")
    if(r[1] > x$nlevels - 1) {
        warning("no thresholding done")
        return(x)
    }
    if(r[2] < 0) {
        warning("no thresholding done")
        return(x)
    }
    nthresh <- length(levels)
    d <- NULL
    n <- 2^(2 * x$nlevels)           #
    ##	 Decide which policy to adopt
    ##		 The next if-else construction should define a vector called
    ##		 "thresh" that contains the threshold value for each level
    ##		 in "levels". This may be the same threshold value
    ##		 a global threshold.
    ##
    if(policy == "universal") {
        if(verbose)
            cat("Universal policy...")
        if(!by.level) {
            if(verbose)
                cat("All levels at once\n")
            for(i in 1:nthresh) {
                d <- c(d, x[[lt.to.name(levels[i], "CD")]],
                       x[[lt.to.name(levels[i], "DC")]],
                       x[[lt.to.name(levels[i], "DD")]])
            }
            noise.level <- sqrt(dev(d))
            thresh <- sqrt(2 * log(n)) * noise.level
            if(verbose)
                cat("Global threshold is: ", thresh, "\n")
            thresh <- rep(thresh, length = nthresh)
        }
        else {
            if(verbose)
                cat("Level by level\n")
            thresh <- rep(0, length = nthresh)
            for(i in 1:nthresh) {
                d <- c(x[[lt.to.name(levels[i], "CD")]],
                       x[[lt.to.name(levels[i], "DC")]],
                       x[[lt.to.name(levels[i], "DD")]])
                noise.level <- sqrt(dev(d))
                thresh[i] <- sqrt(2 * log(n)) * noise.level
                if(verbose)
                    cat("Threshold for level: ", levels[i],
                        " is ", thresh[i], "\n")
            }
        }
    }
    else if(policy == "manual") {
        if(verbose)
            cat("Manual policy...\n")
        thresh <- rep(value, length = nthresh)
        if(length(value) != 1 && length(value) != nthresh)
            warning("your threshold is not the same length as number of levels")
    }
    else if(policy == "probability") {
        if(verbose)
            cat("Probability policy...")
        if(!by.level) {
            if(verbose)
                cat("All levels at once\n")
            for(i in 1:nthresh) {
                d <- c(d, x[[lt.to.name(levels[i], "CD")]],
                       x[[lt.to.name(levels[i], "DC")]],
                       x[[lt.to.name(levels[i], "DD")]])
            }
            if(length(value) != 1)
                stop("Length of value should be 1")
            thresh <- rep(quantile(abs(d), prob = value), length =
                          nthresh)
            if(verbose)
                cat("Global threshold is: ", thresh[1], "\n")
        }
        else {
            if(verbose)
                cat("Level by level\n")
            thresh <- rep(0, length = nthresh)
            if(length(value) == 1)
                value <- rep(value, nthresh)
            if(length(value) != nthresh)
                stop("Wrong number of probability values")
            for(i in 1:nthresh) {
                d <- c(x[[lt.to.name(levels[i], "CD")]],
                       x[[lt.to.name(levels[i], "DC")]],
                       x[[lt.to.name(levels[i], "DD")]])
                thresh[i] <- quantile(abs(d), prob = value[i])
                if(verbose)
                    cat("Threshold for level: ", levels[i],
                        " is ", thresh[i], "\n")
            }
        }
    }
    if(return.threshold)
        return(thresh)
    for(i in 1:nthresh) {
        dCD <- x[[lt.to.name(levels[i], "CD")]]
        dDC <- x[[lt.to.name(levels[i], "DC")]]
        dDD <- x[[lt.to.name(levels[i], "DD")]]
        if(type == "hard") {
            dCD[abs(dCD) <= thresh[i]] <- 0
            dDC[abs(dDC) <= thresh[i]] <- 0
            dDD[abs(dDD) <= thresh[i]] <- 0
            if(verbose)
                cat("Level: ", levels[i], " there are ",
                    sum(dCD == 0), ":", sum(dDC == 0), ":",
                    sum(dDD == 0), " zeroes and: ",
                    sum(dCD != 0), ":", sum(dDC != 0), ":",
                    sum(dDD != 0), " nonzeroes\n")
        }
        else if(type == "soft") {
            dCD <- sign(dCD) * (abs(dCD) - thresh[i]) * (abs(dCD) > thresh[i])
            dDC <- sign(dDC) * (abs(dDC) - thresh[i]) * (abs(dDC) > thresh[i])
            dDD <- sign(dDD) * (abs(dDD) - thresh[i]) * (abs(dDD) > thresh[i])
            if(verbose)
                cat("Level: ", levels[i], " there are ",
                    sum(dCD == 0), ":", sum(dDC == 0), ":",
                    sum(dDD == 0), " zeroes and: ",
                    sum(dCD != 0), ":", sum(dDC != 0), ":",
                    sum(dDD != 0), " nonzeroes\n")
        }
        x[[lt.to.name(levels[i], "CD")]] <- dCD
        x[[lt.to.name(levels[i], "DC")]] <- dDC
        x[[lt.to.name(levels[i], "DD")]] <- dDD
    }
    x
    if(compression)
        return(compress(x, verbose = verbose))
    else return(x)
}

threshold.imwdc <- function(x, verbose = getOption("verbose"), ...)
{
	warning("You are probably thresholding an already thresholded object")
	imwd <- uncompress(x, verbose = verbose)
	return(threshold(imwd, verbose = TRUE, ...))
}

threshold.wd <-
  function(x, levels = 3:(x$nlevels - 1),
	   type = c("hard","soft"),
           policy = c("universal","manual","probability"),
	   by.level = FALSE, value = 0, dev = var,
	   boundary = FALSE, verbose = getOption("verbose"),
           return.threshold = FALSE, ...)
{
    ## Check class of x
    if(verbose) cat("Argument checking\n")
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "wd"))
        stop("argument `x' is not of class \"wd\"")
    policy <- match.arg(policy)
    type <- match.arg(type)
    if(length(list(...)))
	warning(paste("extra arguments",deparse(substitute(...)),"are discarded."))
    r <- range(levels)
    if(r[1] < 0)
        stop("levels out of range, level too small")
    if(r[2] > x$nlevels - 1)
        stop("levels out of range, level too big")
    if(r[1] > x$nlevels - 1) {
        warning("no thresholding done")
        return(x)
    }
    if(r[2] < 0) {
        warning("no thresholding done")
        return(x)
    }
    d <- NULL
    n <- 2^x$nlevels
    nthresh <- length(levels)           #
    ##
    ##	Decide which policy to adopt
    ##		The next if-else construction should define a vector called
    ##		"thresh" that contains the threshold value for each level
    ##		in "levels". This may be the same threshold value
    ##		a global threshold.
    ##
    if(policy == "universal") {
        ##
        ##
        ##		Donoho and Johnstone's universal policy
        ##
        if(verbose) cat("Universal policy...")
        if(!by.level) {
            if(verbose)
                cat("All levels at once\n")
            for(i in 1:nthresh)
                d <- c(d, accessD(x, level = levels[i],
				  boundary = boundary))
            noise.level <- sqrt(dev(d))
            thresh <- sqrt(2 * log(n)) * noise.level
            if(verbose)
                cat("Global threshold is: ", thresh, "\n")
            thresh <- rep(thresh, length = nthresh)
        }
        else {
            if(verbose)
                cat("Level by level\n")
            thresh <- rep(0, length = nthresh)
            for(i in 1:nthresh) {
                d <- accessD(x, level = levels[i], boundary = boundary)
                noise.level <- sqrt(dev(d))
                thresh[i] <- sqrt(2 * log(n)) * noise.level
                if(verbose)
                    cat("Threshold for level: ", levels[i],
                        " is ", thresh[i], "\n")
            }
        }
    }
    else if(policy == "manual") {
        ##
        ##
        ##		User supplied threshold policy
        ##
        if(verbose) cat("Manual policy\n")
        thresh <- rep(value, length = nthresh)
        if(length(value) != 1 && length(value) != nthresh)
            warning("your threshold is not the same length as number of levels")
    }
    else if(policy == "probability") {
        ##
        ##
        ##		Threshold is quantile based
        ##
        if(verbose) cat("Probability policy...")
        if(!by.level) {
            if(verbose)
                cat("All levels at once\n")
            for(i in 1:nthresh)
                d <- c(d, accessD(x, level = levels[i],
				  boundary = boundary))
            if(length(value) != 1)
                stop("Length of value should be 1")
            thresh <- rep(quantile(abs(d), prob = value), length = nthresh)
            if(verbose)
                cat("Global threshold is: ", thresh[1], "\n")
        }
        else {
            if(verbose)
                cat("Level by level\n")
            thresh <- rep(0, length = nthresh)
            if(length(value) == 1)
                value <- rep(value, nthresh)
            if(length(value) != nthresh)
                stop("Wrong number of probability values")
            for(i in 1:nthresh) {
                d <- accessD(x, level = levels[i], boundary = boundary)
                thresh[i] <- quantile(abs(d), prob = value[i])
                if(verbose)
                    cat("Threshold for level: ", levels[i],
                        " is ", thresh[i], "\n")
            }
        }
    }
    if(return.threshold)
        return(thresh)
    for(i in 1:nthresh) {
        d <- accessD(x, level = levels[i], boundary = boundary)
        if(type == "hard") {
	    d[abs(d) <= thresh[i]] <- 0
	    if(verbose)
		cat("Level: ", levels[i], " there are ", sum(d == 0)," zeroes\n")
        }
        else ## if(type == "soft")
            d <- sign(d) * (abs(d) - thresh[i]) * (abs(d) > thresh[i])
        x <- putD(x, level = levels[i], v = d, boundary = boundary)
    }
    x
}

uncompress <- function(x, ...) UseMethod("uncompress")

uncompress.default <- function(x, verbose = getOption("verbose"), ...)
{
    ctmp <- class(x)
    if(is.null(ctmp))
        stop("Object x has no class")
    else if(ctmp == "uncompressed") {
        if(verbose) cat("Not compressed\n")
        return(unclass(x$vector))
    }
    else if(ctmp == "compressed") {
        answer <- rep(0, length = x$original.length)
        answer[x$position] <- x$values
        if(verbose) cat("Uncompressed to length ", length(answer), "\n")
        return(answer)
    }
    else stop("x has unknown class")
}

uncompress.imwdc <- function(x, verbose = getOption("verbose"), ...)
{
    if(verbose) cat("Argument checking\n")
    ctmp <- class(x)
    if(is.null(ctmp) || all(ctmp != "imwdc"))
        stop("argument `x' is not of class \"imwdc\"")

    unsquished <-
        x[c("nlevels", "fl.dbase", "filter", "w0Lconstant", "bc")]
    ##
    ##	 Go round loop compressing each set of coefficients
    ##
    for(level in 0:(x$nlevels - 1)) {
        if(verbose)
            cat("Level ", level, "\n\t")
        nm <- lt.to.name(level, "CD")
	nm.count <- length(names(unsquished))
        if(verbose)
            cat("CD\t")
        unsquished$xxxx <- uncompress.default(x[[nm]], ver = verbose)
	names(unsquished)[nm.count+1] <- nm
        nm <- lt.to.name(level, "DC")
        if(verbose)
            cat("\tDC\t")
        unsquished$xxxx <- uncompress.default(x[[nm]], ver = verbose)
	names(unsquished)[nm.count+2] <- nm
        nm <- lt.to.name(level, "DD")
        if(verbose)
            cat("\tDD\t")
        unsquished$xxxx <- uncompress.default(x[[nm]], ver = verbose)
	names(unsquished)[nm.count+3] <- nm
    }
    class(unsquished) <- "imwd"
    if(verbose && exists("object.size", mode = "function"))
        cat("Overall inflation: Was: ",
            w <- object.size(imwd), " Now:",
            s <- object.size(unsquished),
            " (", signif((100 * s)/w, 3), "%)\n")
    unsquished
}

wd <- function(data, filter.number = 2, family = c("DaubExPhase", "DaubLeAsymm"),
	       bc = "periodic",	verbose = getOption("verbose"))
{
    if(verbose) cat("Argument checking...")
    family <- match.arg(family)
    DataLength <- length(data)          #
    ##
    ## Check that we have a power of 2 data elements
    ##
    nlevels <- log(DataLength)/log(2)
    if(round(nlevels) != nlevels)
        stop("The length of data is not a power of 2")
    ##
    ## Select the appropriate filter
    ##
    if(verbose)
        cat("...done\nFilter...")
    filter <- filter.select(filter.number = filter.number, family = family)
                                        #
    ##
    ## Build the first/last database
    ##
    if(verbose)
        cat("...selected\nFirst/last database...")
    fl.dbase <- first.last(LengthH = length(filter$H), DataLength =
                           DataLength, bc = bc)#
    ##
    ##
    ## Put in the data
    ##
    C <- rep(0, fl.dbase$ntotal)
    C[1:DataLength] <- data             #
    if(verbose)
        error <- 1
    else error <- 0
    if(verbose)
        cat("built\nObject code...")
    ##
    ## Compute the decomposition
    ##
    if(verbose)
        cat("Decomposing...\n")
    nbc <- switch(bc,
                  periodic = 1,
                  symmetric = 2)
    if(is.null(nbc))
        stop("Unknown boundary condition")
    wavelet.decomposition <-
        .C("wavedecomp",
           C = as.double(C),
           LengthC = as.integer(fl.dbase$ntotal),
           D = as.double(rep(0, fl.dbase$ntotal.d)),
           LengthD = as.integer(fl.dbase$ntotal.d),
           H = as.double(filter$H),
           LengthH = as.integer(length(filter$H)),
           nlevels = as.integer(nlevels),
           firstC = as.integer(fl.dbase$first.last.c[, 1]),
           lastC = as.integer(fl.dbase$first.last.c[, 2]),
           offsetC = as.integer(fl.dbase$first.last.c[, 3]),
           firstD = as.integer(fl.dbase$first.last.d[, 1]),
           lastD = as.integer(fl.dbase$first.last.d[, 2]),
           offsetD = as.integer(fl.dbase$first.last.d[, 3]),
           nbc = as.integer(nbc),
           error = as.integer(error))
    if(verbose)
        cat("done\n")
    error <- wavelet.decomposition$error
    if(error != 0)
        stop(paste("Error", error, " occured in wavedecomp"))

    l <- list(C = wavelet.decomposition$C, D = wavelet.decomposition$D,
              nlevels = wavelet.decomposition$nlevels, fl.dbase = fl.dbase,
              filter = filter, bc = bc)
    class(l) <- "wd"
    l
}

wr <- function(wd, start.level = 0, verbose = getOption("verbose"),
	       bc = wd$bc, return.object = FALSE,
	       filter.number = wd$filter$filter.number,
	       family = wd$filter$family)
{
    ## Check class of wd
    if(verbose) cat("Argument checking\n")
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
        stop("argument `wd' is not of class \"wd\"")
    if(start.level < 0)
        stop("start.level must be nonnegative")
    if(start.level >= wd$nlevels)
        stop("start.level must be less than the number of levels")
    if(is.null(wd$filter$filter.number))
        stop("NULL filter.number for wd")
    if(bc != wd$bc)
        warning("Boundary handling is different to original")
    filter <- filter.select(filter.number = filter.number, family = family)
    LengthH <- length(filter$H)         #
    ##
    ##	Build the reconstruction first/last database
    ##
    if(verbose)
        cat("...done\nFirst/last database...")
    r.first.last.c <- wd$fl.dbase$first.last.c[(start.level + 1):
                                               (wd$ nlevels + 1), ]#
    ntotal <- r.first.last.c[1, 3] + r.first.last.c[1, 2] -
        r.first.last.c[1, 1] + 1
    names(ntotal) <- NULL
    C <- accessC(wd, level = start.level, boundary = TRUE)
    C <- c(rep(0, length = (ntotal - length(C))), C)
    nlevels <- wd$nlevels - start.level
    error <- 0                          #

    if(verbose) {
        cat("...built\nReconstruction...")
        error <- 1
    }
    nbc <- switch(bc,
                  periodic = 1,
                  symmetric = 2)
    if(is.null(nbc))
        stop("Unknown boundary handling")
    waverecons <- .C("waverecons",
                     C = as.double(C),
                     LengthC = as.integer(length(C)),
                     D = as.double(wd$D),
                     LengthD = as.integer(length(wd$D)),
                     H = as.double(filter$H),
                     LengthH = as.integer(LengthH),
                     nlevels = as.integer(nlevels),
                     firstC = as.integer(r.first.last.c[, 1]),
                     lastC = as.integer(r.first.last.c[, 2]),
                     offsetC = as.integer(r.first.last.c[, 3]),
                     firstD = as.integer(wd$fl.dbase$first.last.d[, 1]),
                     lastD = as.integer(wd$fl.dbase$first.last.d[, 2]),
                     offsetD = as.integer(wd$fl.dbase$first.last.d[, 3]),
                     nbc = as.integer(nbc),
                     error = as.integer(error))
    if(verbose)
        cat("done\n")
    error <- waverecons$error
    if(error != 0) {
        cat("Error code returned from waverecons: ", error, "\n")
        stop("waverecons returned error")
    }
    fl.dbase <- list(first.last.c = r.first.last.c, ntotal =
                     waverecons$LengthC, first.last.d = wd$fl.dbase$
                     first.last.d, ntotal.d = wd$fl.dbase$ntotal.d)
    l <- list(C = waverecons$C, D = waverecons$D,
              fl.dbase = fl.dbase, nlevels = waverecons$nlevels,
              filter = filter, bc = bc)
    class(l) <- "wd"

    return(if(return.object) l else accessC(l))
}
