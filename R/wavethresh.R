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

compress <- function(x, ...) UseMethod("compress")

compress.default <- function(v, verbose = FALSE)
{
    n <- length(v)
    r <- sum(v != 0)
    if(n > 2 * r) {
        position <- (1:n)[v != 0]
        values <- v[position]
        answer <- list(position = position, values = values,
                       original.length = n)
        class(answer) <- "compressed"
        if(verbose)
            cat("Compressed ", n, " into ", 2 * r, "(",
                signif((100 * 2 * r)/n, 3), "%)\n")
    }
    else {
        answer <- list(vector = v)
        class(answer) <- "uncompressed"
        if(verbose)
            cat("No compression\n")
    }
    return(answer)
}

compress.imwd <- function(imwd, verbose = FALSE)
{
    if(verbose)
        cat("Argument checking\n")
    ctmp <- class(imwd)
    if(is.null(ctmp) || all(ctmp != "imwd"))
	stop("argument `imwd' is not of class \"imwd\"")

    squished <-
        list(nlevels = imwd$nlevels, fl.dbase = imwd$fl.dbase,
             filter = imwd$filter, w0Lconstant = imwd$w0Lconstant, bc = imwd$bc)
##
##	Go round loop compressing each set of coefficients
##
	for(level in 0:(imwd$nlevels - 1)) {
		if(verbose)
			cat("Level ", level, "\n\t")
		nm <- lt.to.name(level, "CD")
	nm.count<-length(names(squished))
		if(verbose)
			cat("CD\t")
		squished$xxxx <- compress.default(imwd[[nm]], ver = verbose)
	names(squished)[nm.count+1]<-nm
		nm <- lt.to.name(level, "DC")
		if(verbose)
			cat("\tDC\t")
		squished$xxxx <- compress.default(imwd[[nm]], ver = verbose)
	names(squished)[nm.count+2]<-nm
		nm <- lt.to.name(level, "DD")
		if(verbose)
			cat("\tDD\t")
		squished$xxxx <- compress.default(imwd[[nm]], ver = verbose)
	names(squished)[nm.count+3]<-nm
	}
	class(squished) <- c("imwdc")
	if(verbose)
		cat("Overall compression: Was: ", w <- object.size(imwd),
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

draw.default <-
  function(filter.number = 2, family = "DaubExPhase",
	   resolution = 1024, verbose = FALSE, plot = TRUE,
	   main = "Wavelet Picture", sub = zwd$filter$name,
	   xlab = "x", ylab = expression(psi(x)),
           dimension = 1, twodplot = persp,
           enhance = TRUE, efactor = 0.05, ...)
{
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
  if(verbose)
    cat("Lowest level is: ", lowest.level, "\n")
  selection <- NULL
  candidates <- NULL
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
      lhs <- support(filter.number = filter.number, family =
		     family, m = m, n = n)
      rhs <- lhs$rh
      lhs <- lhs$lh
      if(verbose)
	cat("LHS: ", lhs, " RHS: ", rhs, "\n")
      if((lhs >= lh) && (rhs <= rh)) {
	candidates <- c(candidates, n)
	if(verbose)
	  cat("Level ", m, " Position: ", n, " selected\n")
      }
    }
    if(!is.null(candidates)) {
      if(verbose) {
	cat("Candidates are \n")
	print(candidates)
      }
      n <- floor(median(candidates))
      if(verbose)
	cat("Choosing ", n, "\n")
      selection <- list(m = m, n = n)
      lhs <- support(filter.number = filter.number, family =
		     family, m = m, n = n)
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
  zwd <- wd(rep(0, length = resolution * 2), filter.number =
	    filter.number, family = family, bc = "symmetric")#
  ##
  ##	Insert a vector containing a 1 where we want to put the coefficient
  ##
  wd.lev <- lowest.level - selection$m
  if(verbose)
    cat("Coefficient insertion at wd level: ", wd.lev, "\n")
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
    main <- paste(main, " (Enhanced)")
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

draw.wd <- function(wd, ...)
{
    filter <- wd$filter
    draw.default(filter.number = filter$filter.number,
                 family = filter$family, ...)
}

draw.imwd <- function(wd, resolution = 128, ...)
    draw.wd(wd, resolution = resolution, dim = 2, ...)

draw.imwdc <- .Alias(draw.imwd)


filter.select <- function(filter.number, family = "DaubExPhase", constant = 1)
{
    if(family == "DaubExPhase") {
        family <- "DaubExPhase"         #
        ##
        ##	The following wavelet coefficients are taken from
        ##	Daubechies, I (1988) Orthonormal Bases of Wavelets
        ##	Communications on Pure and Applied Mathematics. Page 980
        ##	or Ten Lectures on Wavelets, Daubechies, I, 1992
        ##	CBMS-NSF Regional Conference Series, page 195, Table 6.1
        ##
        ##	Comment from that table reads:
        ##       "The filter coefficients for the compactly supported wavelets
        ##        with extremal phase and highest number of vanishing moments
        ##	  compatible with their support width".
        ##
        if(filter.number == 1) {
            ## This is for the Haar basis. (not in Daubechies).

            H <- rep(0, 2)
            H[1] <- 1/sqrt(2)
            H[2] <- H[1]
            filter.name <- c("Haar wavelet")
        }
        else if(filter.number == 2) {
            H <- rep(0, 4)
            H[1] <- 0.48296291314500001
            H[2] <- 0.83651630373800001
            H[3] <- 0.22414386804200001
            H[4] <- -0.12940952255099999
            filter.name <- c("Daub cmpct on ext. phase N=2")
        }
        else if(filter.number == 3) {
            H <- rep(0, 6)
            H[1] <- 0.33267055294999998
            H[2] <- 0.80689150931099995
            H[3] <- 0.45987750211799999
            H[4] <- -0.13501102001000001
            H[5] <- -0.085441273882
            H[6] <- 0.035226291882000001
            filter.name <- c("Daub cmpct on ext. phase N=3")
        }
        else if(filter.number == 4) {
            H <- rep(0, 8)
            H[1] <- 0.23037781330900001
            H[2] <- 0.71484657055300005
            H[3] <- 0.63088076793000003
            H[4] <- -0.027983769417
            H[5] <- -0.18703481171899999
            H[6] <- 0.030841381836
            H[7] <- 0.032883011667000001
            H[8] <- -0.010597401785
            filter.name <- c("Daub cmpct on ext. phase N=4")
        }
        else if(filter.number == 5) {
            H <- rep(0, 10)
            H[1] <- 0.160102397974
            H[2] <- 0.60382926979700002
            H[3] <- 0.72430852843799998
            H[4] <- 0.138428145901
            H[5] <- -0.242294887066
            H[6] <- -0.032244869585000002
            H[7] <- 0.07757149384
            H[8] <- -0.006241490213
            H[9] <- -0.012580751999
            H[10] <- 0.003335725285
            filter.name <- c("Daub cmpct on ext. phase N=5")
        }
        else if(filter.number == 6) {
            H <- rep(0, 12)
            H[1] <- 0.11154074335
            H[2] <- 0.49462389039799998
            H[3] <- 0.751133908021
            H[4] <- 0.31525035170900001
            H[5] <- -0.22626469396500001
            H[6] <- -0.12976686756700001
            H[7] <- 0.097501605586999995
            H[8] <- 0.02752286553
            H[9] <- -0.031582039318000001
            H[10] <- 0.000553842201
            H[11] <- 0.004777257511
            H[12] <- -0.001077301085
            filter.name <- c("Daub cmpct on ext. phase N=6")
        }
        else if(filter.number == 7) {
            H <- rep(0, 14)
            H[1] <- 0.077852054084999997
            H[2] <- 0.396539319482
            H[3] <- 0.72913209084599995
            H[4] <- 0.469782287405
            H[5] <- -0.14390600392899999
            H[6] <- -0.22403618499399999
            H[7] <- 0.071309219267
            H[8] <- 0.080612609151000006
            H[9] <- -0.038029936935000001
            H[10] <- -0.016574541631
            H[11] <- 0.012550998556
            H[12] <- 0.000429577973
            H[13] <- -0.001801640704
            H[14] <- 0.0003537138
            filter.name <- c("Daub cmpct on ext. phase N=7")
        }
        else if(filter.number == 8) {
            H <- rep(0, 16)
            H[1] <- 0.054415842243000001
            H[2] <- 0.31287159091400002
            H[3] <- 0.67563073629699999
            H[4] <- 0.58535468365400001
            H[5] <- -0.015829105256
            H[6] <- -0.28401554296199999
            H[7] <- 0.000472484574
            H[8] <- 0.12874742662
            H[9] <- -0.017369301002000001
            H[10] <- -0.044088253931
            H[11] <- 0.013981027917
            H[12] <- 0.008746094047
            H[13] <- -0.004870352993
            H[14] <- -0.000391740373
            H[15] <- 0.000675449406
            H[16] <- -0.000117476784
            filter.name <- c("Daub cmpct on ext. phase N=8")
        }
        else if(filter.number == 9) {
            H <- rep(0, 18)
            H[1] <- 0.038077947363999998
            H[2] <- 0.24383467461300001
            H[3] <- 0.60482312369000002
            H[4] <- 0.65728807805099998
            H[5] <- 0.13319738582499999
            H[6] <- -0.293273783279
            H[7] <- -0.096840783222999993
            H[8] <- 0.14854074933799999
            H[9] <- 0.030725681479000001
            H[10] <- -0.067632829061000002
            H[11] <- 0.000250947115
            H[12] <- 0.022361662124
            H[13] <- -0.004723204758
            H[14] <- -0.004281503682
            H[15] <- 0.001847646883
            H[16] <- 0.000230385764
            H[17] <- -0.000251963189
            H[18] <- 3.934732e-05
            filter.name <- c("Daub cmpct on ext. phase N=9")
        }
        else if(filter.number == 10) {
            H <- rep(0, 20)
            H[1] <- 0.026670057901000001
            H[2] <- 0.188176800078
            H[3] <- 0.52720118893199996
            H[4] <- 0.688459039454
            H[5] <- 0.28117234366100002
            H[6] <- -0.24984642432699999
            H[7] <- -0.19594627437699999
            H[8] <- 0.127369340336
            H[9] <- 0.093057364604000006
            H[10] <- -0.071394147165999997
            H[11] <- -0.029457536822
            H[12] <- 0.033212674058999997
            H[13] <- 0.003606553567
            H[14] <- -0.010733175483
            H[15] <- 0.001395351747
            H[16] <- 0.001992405295
            H[17] <- -0.000685856695
            H[18] <- -0.000116466855
            H[19] <- 9.358867e-05
            H[20] <- -1.3264203e-05
            filter.name <- c("Daub cmpct on ext. phase N=10")
        }
        else {
            stop("Unknown filter number for Daubechies wavelets with extremal phase and highest number of vanishing moments..."
                 )
        }
    }
    else if(family == "DaubLeAsymm") {
        family <- "DaubLeAsymm"         #
        ##
        ##	 The following wavelet coefficients are taken from
        ##	 Ten Lectures on Wavelets, Daubechies, I, 1992
        ##	 CBMS-NSF Regional Conference Series, page 198, Table 6.3
        ##
        ##	 Comment from that table reads:
        ##		"The low pass filter coefficients for the "least-asymmetric"
        ##		compactly supported wavelets with maximum number of
        ##		vanishing moments, for N = 4 to 10
        ##
        if(filter.number == 4) {
            H <- rep(0, 8)
            H[1] <- -0.107148901418
            H[2] <- -0.041910965125
            H[3] <- 0.703739068656
            H[4] <- 1.136658243408
            H[5] <- 0.421234534204
            H[6] <- -0.140317624179
            H[7] <- -0.017824701442
            H[8] <- 0.045570345896
            filter.name <- c("Daub cmpct on least asymm N=4")
            H <- H/sqrt(2)
        }
        else if(filter.number == 5) {
            H <- rep(0, 10)
            H[1] <- 0.038654795955
            H[2] <- 0.041746864422
            H[3] <- -0.055344186117
            H[4] <- 0.281990696854
            H[5] <- 1.023052966894
            H[6] <- 0.89658164838
            H[7] <- 0.023478923136
            H[8] <- -0.247951362613
            H[9] <- -0.029842499869
            H[10] <- 0.027632152958
            filter.name <- c("Daub cmpct on least asymm N=5")
            H <- H/sqrt(2)
	}
        else if(filter.number == 6) {
            H <- rep(0, 12)
            H[1] <- 0.021784700327
            H[2] <- 0.004936612372
            H[3] <- -0.166863215412
            H[4] <- -0.068323121587
            H[5] <- 0.694457972958
            H[6] <- 1.113892783926
            H[7] <- 0.477904371333
            H[8] <- -0.102724969862
            H[9] <- -0.029783751299
            H[10] <- 0.06325056266
            H[11] <- 0.002499922093
            H[12] <- -0.011031867509
            filter.name <- c("Daub cmpct on least asymm N=6")
            H <- H/sqrt(2)
        }
        else if(filter.number == 7) {
            H <- rep(0, 14)
            H[1] <- 0.003792658534
            H[2] <- -0.001481225915
            H[3] <- -0.017870431651
            H[4] <- 0.043155452582
            H[5] <- 0.096014767936
            H[6] <- -0.070078291222
            H[7] <- 0.024665659489
            H[8] <- 0.758162601964
            H[9] <- 1.085782709814
            H[10] <- 0.408183939725
            H[11] <- -0.198056706807
            H[12] <- -0.152463871896
            H[13] <- 0.005671342686
            H[14] <- 0.014521394762
            filter.name <- c("Daub cmpct on least asymm N=7")
            H <- H/sqrt(2)
        }
        else if(filter.number == 8) {
            H <- rep(0, 16)
            H[1] <- 0.002672793393
            H[2] <- -0.0004283943
            H[3] <- -0.021145686528
            H[4] <- 0.005386388754
            H[5] <- 0.069490465911
            H[6] <- -0.038493521263
            H[7] <- -0.073462508761
            H[8] <- 0.515398670374
            H[9] <- 1.099106630537
            H[10] <- 0.68074534719
            H[11] <- -0.086653615406
            H[12] <- -0.202648655286
            H[13] <- 0.010758611751
            H[14] <- 0.044823623042
            H[15] <- -0.000766690896
            H[16] <- -0.004783458512
            filter.name <- c("Daub cmpct on least asymm N=8")
            H <- H/sqrt(2)
        }
        else if(filter.number == 9) {
            H <- rep(0, 18)
            H[1] <- 0.001512487309
            H[2] <- -0.000669141509
            H[3] <- -0.014515578553
            H[4] <- 0.012528896242
            H[5] <- 0.087791251554
            H[6] <- -0.02578644593
            H[7] <- -0.270893783503
            H[8] <- 0.049882830959
            H[9] <- 0.873048407349
            H[10] <- 1.015259790832
            H[11] <- 0.337658923602
            H[12] <- -0.077172161097
            H[13] <- 0.000825140929
            H[14] <- 0.042744433602
            H[15] <- -0.016303351226
            H[16] <- -0.018769396836
            H[17] <- 0.000876502539
            H[18] <- 0.001981193736
            filter.name <- c("Daub cmpct on least asymm N=9")
            H <- H/sqrt(2)
        }
        else if(filter.number == 10) {
            H <- rep(0, 20)
            H[1] <- 0.001089170447
            H[2] <- 0.00013524502
            H[3] <- -0.01222064263
            H[4] <- -0.002072363923
            H[5] <- 0.064950924579
            H[6] <- 0.016418869426
            H[7] <- -0.225558972234
            H[8] <- -0.100240215031
            H[9] <- 0.667071338154
            H[10] <- 1.0882515305
            H[11] <- 0.542813011213
            H[12] <- -0.050256540092
            H[13] <- -0.045240772218
            H[14] <- 0.07070356755
            H[15] <- 0.008152816799
            H[16] <- -0.028786231926
            H[17] <- -0.001137535314
            H[18] <- 0.006495728375
            H[19] <- 8.0661204e-05
            H[20] <- -0.000649589896
            filter.name <- c("Daub cmpct on least asymm N=10")
            H <- H/sqrt(2)
        }
        else {
            stop("Unknown filter number for Daubechies wavelets with\n least asymmetry and highest number of vanishing moments..."
                 )
        }
    }
    else {
        stop("Unknown filter\n")
    }
    H <- H/constant
    return(list(H = H, name = filter.name, family = family, filter.number
                = filter.number))
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

imwd <- function(image, filter.number = 2, bc = "periodic", verbose = FALSE)
{
    if(verbose)
        cat("Argument checking...")
    if(nrow(image) != ncol(image))
        stop("Number of rows and columns in image are not identical")
    if(verbose)
        cat("...done\nFilter...")
    filter <- filter.select(filter.number)#	Select wavelet filter
    Csize <- nrow(image)

    ## Check that Csize is a power of 2
    ##
    nlevels <- log(Csize)/log(2)
    if(round(nlevels) != nlevels)
        stop("The image size is not a power of 2")

    ## Set-up first/last database
    ##
    if(verbose)
        cat("...selected\nFirst/last database...")
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

    if(verbose)
        cat("...built\n")

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
        if(verbose)
            cat(level - 1, "")
        LengthCin <- first.last.c[level + 1, 2] -
            first.last.c[level + 1, 1] + 1
        LengthCout <- first.last.c[level, 2] -
            first.last.c[level, 1] + 1
        LengthDout <- first.last.d[level, 2] -
            first.last.d[level, 1] + 1
        ImCC <-
            ImCD <-
		ImDC <-
                    ImDD <- numeric(LengthCout * LengthCout)
        error <- 0
        z <- .C("StoIDS",
                C = as.double(smoothed),
                Csize = as.integer(LengthCin),
                firstCin = as.integer(first.last.c[level + 1, 1]),
                H = as.double(filter$H),
                LengthH = as.integer(length(filter$H)),
                LengthCout = as.integer(LengthCout),
                firstCout = as.integer(first.last.c[level, 1]),
                lastCout = as.integer(first.last.c[level, 2]),
                LengthDout = as.integer(LengthDout),
                firstDout = as.integer(first.last.d[level, 1]),
                lastDout = as.integer(first.last.d[level, 2]),
                ImCC = ImCC,
                ImCD = ImCD,
                ImDC = ImDC,
                ImDD = ImDD,
                nbc = as.integer(nbc),
                error = as.integer(error))
        error <- z$error
        if(error != 0) {
            cat("Error was ", error, "\n")
            stop("Error reported")
        }
        smoothed <- z$ImCC
        ##	 if(verbose) cat("Assigning wavelet coefficients\n")
	nm.count<-length(names(image.decomp))
        nm <- lt.to.name(level - 1, "CD")
        image.decomp$xxxx <- z$ImCD
	names(image.decomp)[nm.count+1]<-nm
        nm <- lt.to.name(level - 1, "DC")
        image.decomp$xxxx <- z$ImDC
	names(image.decomp)[nm.count+2]<-nm
        nm <- lt.to.name(level - 1, "DD")
        image.decomp$xxxx <- z$ImDD
	names(image.decomp)[nm.count+3]<-nm
    }
    if(verbose)
        cat("\nReturning answer...\n")
    image.decomp$w0Lconstant <- smoothed
    image.decomp$bc <- bc
    class(image.decomp) <- "imwd"
    image.decomp
}

imwr <- function(x, ...) UseMethod("imwr")

imwr.imwd <- function(imwd, bc = imwd$bc, verbose = FALSE)
{
    if(verbose) cat("Argument checking...")#
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

imwr.imwdc <- function(imwdc, bc = imwd$bc, verbose = FALSE)
{
    if(verbose) cat("Uncompressing...\n")
    imwd2 <- uncompress(imwdc, ver = verbose)
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
    function(imwd, scaling = "by.level", co.type = "abs",
	     plot.type = "mallat", arrangement = c(3, 3),
	     plot = exists("image", mode="function"),
	     transform = FALSE, tfunction = sqrt, col = heat.colors(32), ...)
{
    ## Check class of imwd
    ctmp <- class(imwd)
    if(is.null(ctmp) || all(ctmp != "imwd"))
	stop("argument `imwd' is not of class \"imwd\"")

    Csize <- 2^(imwd$nlevels)
    m <- matrix(0, nrow = Csize, ncol = Csize)
    first.last.d <- imwd$fl.dbase$first.last.d
    first.last.c <- imwd$fl.dbase$first.last.c
    if(plot.type == "mallat") {
	for(level in (imwd$nlevels):1) {
	    ndata <- 2^(level - 1)
	    firstD <- first.last.d[level, 1]
	    lastD <- first.last.d[level, 2]
	    LengthD <- lastD - firstD + 1
	    sel <- seq(from = (1 - firstD), length = ndata)#
	    ##
	    ## Extract CD for this level
	    ##
	    nm <- lt.to.name(level - 1, "CD")
	    msub1 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)	#
	    ##
	    ## Extract DC for this level
	    ##
	    nm <- lt.to.name(level - 1, "DC")
	    msub2 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)	#
	    ##
	    ## Extract DD for this level
	    ##
	    nm <- lt.to.name(level - 1, "DD")
	    msub3 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)	#
	    ##
	    ##
	    ##	Work out if we want to display the absolute values or the actual
	    ##	values
	    ##
	    if(co.type == "abs") {
		msub1 <- abs(msub1)
		msub2 <- abs(msub2)
		msub3 <- abs(msub3)
	    }
	    else if(co.type == "mabs") {
		msub1 <-  - abs(msub1)
		msub2 <-  - abs(msub2)
		msub3 <-  - abs(msub3)
	    }
	    else if(co.type != "none")
		stop("Unknown co.type")
	    if(transform) {
		msub1 <- tfunction(msub1)
		msub2 <- tfunction(msub2)
		msub3 <- tfunction(msub3)
	    }
	    if(scaling == "by.level") {
		r.m1 <- range(msub1)
		r.m2 <- range(msub2)
		r.m3 <- range(msub3)
		mu1 <- 249/(r.m1[2] - r.m1[1])
		mu2 <- 249/(r.m2[2] - r.m2[1])
		mu3 <- 249/(r.m3[2] - r.m3[1])
		msub1 <- mu1 * (msub1 - r.m1[1])
		msub2 <- mu2 * (msub2 - r.m2[1])
		msub3 <- mu3 * (msub3 - r.m3[1])
	    }
	    else {
		range.msub <- range(c(msub1, msub2, msub3))
		multiplier <- 255/(range.msub[2] - range.msub[1])
		msub1 <- multiplier * (msub1 - range.msub[1])
		msub2 <- multiplier * (msub2 - range.msub[1])
		msub3 <- multiplier * (msub3 - range.msub[1])#
	    }
	    m[(ndata + 1):(2 * ndata), 1:ndata] <- msub1[sel, sel]
	    m[1:ndata, (ndata + 1):(2 * ndata)] <- msub2[sel, sel]
	    m[(ndata + 1):(2 * ndata), (ndata + 1):(2 * ndata)] <-
		msub3[sel, sel]
	}
	if(plot) {
	    image(z=m, xaxt = "n", yaxt = "n", col=col, ...)
	    axis(1, at= c(0, 2^((imwd$nlevels - 3):(imwd$nlevels))))
	    axis(2, at= c(0, 2^((imwd$nlevels - 3):(imwd$nlevels))))
	    return(invisible(m))
	}
	else return(m)
    }
    else if(plot.type == "cols") {
	oldpar <- par(mfrow = arrangement, pty = "s", ...)
	on.exit(par(oldpar))
	for(level in (imwd$nlevels:1)) {
	    ndata <- 2^(level - 1)
	    firstD <- first.last.d[level, 1]
	    lastD <- first.last.d[level, 2]
	    LengthD <- lastD - firstD + 1
	    sel <- seq(from = (1 - firstD), length = ndata)

	    ## Extract CD for this level
	    nm <- lt.to.name(level - 1, "CD")
	    msub1 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)

	    ## Extract DC for this level
	    nm <- lt.to.name(level - 1, "DC")
	    msub2 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)

	    ## Extract DD for this level
	    nm <- lt.to.name(level - 1, "DD")
	    msub3 <- matrix(imwd[[nm]], nrow = LengthD, ncol = LengthD)

	    ##	Work out if we want to display the absolute values or the actual
	    ##	values
	    if(co.type == "abs") {
		msub1 <- abs(msub1)
		msub2 <- abs(msub2)
		msub3 <- abs(msub3)
	    }
	    else if(co.type == "mabs") {
		msub1 <-  - abs(msub1)
		msub2 <-  - abs(msub2)
		msub3 <-  - abs(msub3)
	    }
	    else if(co.type != "none")
		stop("Unknown co.type")
	    if(transform) {
		msub1 <- tfunction(msub1)
		msub2 <- tfunction(msub2)
		msub3 <- tfunction(msub3)
	    }
	    if(plot) {
		xlabstr <- paste("Level", level - 1, "(horizontal)")
		image(z=msub1, xlab = xlabstr, col=col)
		xlabstr <- paste("Level", level - 1, "(vertical)")
		image(z=msub2, xlab = xlabstr, col=col)
		xlabstr <- paste("Level", level - 1, "(diagonal)")
		image(z=msub3, xlab = xlabstr, col=col)
	    }
	}
	invisible()
    }
    else stop("Unknown plot.type")
}

plot.imwdc <- function(imwdc, verbose = FALSE, ...)
{
    imwd <- uncompress(imwdc, verbose = verbose)
    return(plot(imwd, ...))
}

plot.wd <- function(wd, xlabels, first.level = 1,
		    main = "Wavelet Decomposition Coefficients",
                    sub = wd$filter$name,
		    xlab = "Translate", ylab = "Resolution Level",
		    scaling = "by.level", rhlab = FALSE, ...)
{
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
	stop("argument `wd' is not of class \"wd\"")

    levels <- wd$nlevels
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
    x <- 1:n
    height <- 1
    first.last.d <- wd$fl.dbase$first.last.d
    if(scaling == "global") {
	my <- 0
	for(i in i.lev) {
	    y <- accessD(wd, i)
	    my <- max(c(my, abs(y)))
	}
    }
    axr <- numeric(0)
    for(i in i.lev) {
	n <- 2^i
	y <- accessD(wd, i)
	xplot <- x
	ly <- length(y)
	if(scaling == "by.level")
	    my <- max(abs(y))
	y <- (0.5 * y)/my
	axr <- c(axr, my)
	segments(xplot, height, xplot, height + y)
	if(i != first.level) {
	    x1 <- x[seq(1, n - 1, 2)]
	    x2 <- x[seq(2, n, 2)]
	    x <- (x1 + x2)/2
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
    print(summary.imwd(x))
    invisible(x)
}

print.imwdc <- function(x, ...)
{
    cat("Class imwdc : Compressed Discrete Image Wavelet Transform Object:\n",
	"      ~~~~~ : List with ", length(x), " components with names\n")
    cat("             ", names(x), "\n\n",
      	"$ wNLx are LONG coefficient vectors !\n",
	"\nsummary(.):\n----------\n")
    print(summary.imwdc(x))
    invisible(x)
}

print.wd <- function(x, ...)
{
    cat("Class wd : Discrete Wavelet Transform Object:\n",
	"      ~~ : List with ", length(x), " components with names\n",
	"          ", names(x), "\n\n",
	"$ C and $ D are LONG coefficient vectors !\n",
	"\nsummary(.):\n----------\n")
    print(summary.wd(x))
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

summary.imwd <- function(imwd)
{
    ## Check class of imwd
    ctmp <- class(imwd)
    if(is.null(ctmp) || all(ctmp != "imwd"))
        stop("argument `imwd' is not of class \"imwd\"")
    fl.c <- imwd$fl.dbase$first.last.c
    pix <- fl.c[imwd$nlevels + 1, 2] - fl.c[imwd$nlevels + 1, 1] + 1
    cat("UNcompressed image wavelet decomposition structure\n")
    cat("Levels: ", imwd$nlevels, "\n")
    cat("Original image was", pix, "x", pix, " pixels.\n")
    cat("Filter was: ", imwd$filter$name, "\n")
    cat("Boundary handling: ", imwd$bc, "\n")
}

summary.imwdc <- function(imwdc)
{
    ## Check class of imwdc
    ctmp <- class(imwdc)
    if(is.null(ctmp) || all(ctmp != "imwdc"))
        stop("argument `imwdc' is not of class \"imwdc\"")
    fl.c <- imwdc$fl.dbase$first.last.c
    pix <- fl.c[imwdc$nlevels + 1, 2] - fl.c[imwdc$nlevels + 1, 1] + 1
    cat("Compressed image wavelet decomposition structure\n")
    cat("Levels: ", imwdc$nlevels, "\n")
    cat("Original image was", pix, "x", pix, " pixels.\n")
    cat("Filter was: ", imwdc$filter$name, "\n")
    cat("Boundary handling: ", imwdc$bc, "\n")
}

summary.wd <- function(wd)
{
    pix <- length(accessC(wd))          # this is HIGHLY inefficient
    cat("Levels:  ", wd$nlevels,
	"\nLength of original:  ", pix,
	"\nFilter was:  ", wd$filter$name,
	"\nBoundary handling:  ", wd$bc, "\n", sep = "")
}

support <- function(filter.number = 2, family = "DaubExPhase", m = 0, n = 0)
{
    m <- m + 1
    if(family == "DaubExPhase") {
        a <-  - (filter.number - 1)
        b <- filter.number
        lh <- 2^( + m) * (a + n)
        rh <- 2^( + m) * (b + n)
        return(list(lh = lh, rh = rh, psi.lh =	- (filter.number - 1),
                    psi.rh = filter.number, phi.lh = 0, phi.rh = 2 *
                    filter.number - 1))
    }
    else if(family == "DaubLeAsymm") {
        a <-  - (filter.number - 1)
        b <- filter.number
        lh <- 2^( + m) * (a + n)
        rh <- 2^( + m) * (b + n)
        return(list(lh = lh, rh = rh, psi.lh =	- (filter.number - 1),
                    psi.rh = filter.number, phi.lh = 0, phi.rh = 2 *
                    filter.number - 1))
    }
    else {
        stop("Unknown family")
    }
}

threshold <- function(x, ...) UseMethod("threshold")

threshold.imwd <-
  function(imwd, levels = 3:(imwd$nlevels - 1),
	   type = "hard", policy = "universal", by.level = FALSE, value = 0,
	   dev = var, verbose = FALSE,
	   return.threshold = FALSE, compression = TRUE)
{
    ## Check class of imwd
    if(verbose) cat("Argument checking\n")
    ctmp <- class(imwd)
    if(is.null(ctmp) || all(ctmp != "imwd"))
        stop("argument `imwd' is not of class \"imwd\"")

    if(policy != "universal" && policy != "manual" && policy !=
       "probability")
        stop("Only policys are universal, manual and probability at present")
    if(type != "hard" && type != "soft")
        stop("Only hard or soft thresholding at	 present")
    r <- range(levels)
    if(r[1] < 0)
        stop("levels out of range, level too small")
    if(r[2] > imwd$nlevels - 1)
        stop("levels out of range, level too big")
    if(r[1] > imwd$nlevels - 1) {
        warning("no thresholding done")
        return(imwd)
    }
    if(r[2] < 0) {
        warning("no thresholding done")
        return(imwd)
    }
    nthresh <- length(levels)
    d <- NULL
    n <- 2^(2 * imwd$nlevels)           #
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
                d <- c(d, imwd[[lt.to.name(levels[i], "CD")]],
                       imwd[[lt.to.name(levels[i], "DC")]],
                       imwd[[lt.to.name(levels[i], "DD")]])
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
                d <- c(imwd[[lt.to.name(levels[i], "CD")]],
                       imwd[[lt.to.name(levels[i], "DC")]],
                       imwd[[lt.to.name(levels[i], "DD")]])
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
                d <- c(d, imwd[[lt.to.name(levels[i], "CD")]],
                       imwd[[lt.to.name(levels[i], "DC")]],
                       imwd[[lt.to.name(levels[i], "DD")]])
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
                d <- c(imwd[[lt.to.name(levels[i], "CD")]],
                       imwd[[lt.to.name(levels[i], "DC")]],
                       imwd[[lt.to.name(levels[i], "DD")]])
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
        dCD <- imwd[[lt.to.name(levels[i], "CD")]]
        dDC <- imwd[[lt.to.name(levels[i], "DC")]]
        dDD <- imwd[[lt.to.name(levels[i], "DD")]]
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
        imwd[[lt.to.name(levels[i], "CD")]] <- dCD
        imwd[[lt.to.name(levels[i], "DC")]] <- dDC
        imwd[[lt.to.name(levels[i], "DD")]] <- dDD
    }
    imwd
    if(compression)
        return(compress(imwd, verbose = verbose))
    else return(imwd)
}

threshold.imwdc <- function(imwdc, verbose = FALSE, ...)
{
	warning("You are probably thresholding an already thresholded object")
	imwd <- uncompress(imwdc, verbose = verbose)
	return(threshold(imwd, verbose = TRUE, ...))
}

threshold.wd <-
  function(wd, levels = 3:(wd$nlevels - 1),
	   type = "hard", policy = c("universal","manual","probability"),
	   by.level = FALSE, value = 0, dev = var,
	   boundary = FALSE, verbose = FALSE, return.threshold = FALSE)
{
    ## Check class of wd
    if(verbose) cat("Argument checking\n")
    ctmp <- class(wd)
    if(is.null(ctmp) || all(ctmp != "wd"))
        stop("argument `wd' is not of class \"wd\"")
    if(is.null(policy <- match.arg(policy)))
        stop("Only policys are universal, manual and probability at present")
    if(type != "hard" && type != "soft")
        stop("Only hard or soft thresholding at	 present")
    r <- range(levels)
    if(r[1] < 0)
        stop("levels out of range, level too small")
    if(r[2] > wd$nlevels - 1)
        stop("levels out of range, level too big")
    if(r[1] > wd$nlevels - 1) {
        warning("no thresholding done")
        return(wd)
    }
    if(r[2] < 0) {
        warning("no thresholding done")
        return(wd)
    }
    d <- NULL
    n <- 2^wd$nlevels
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
                d <- c(d, accessD(wd, level = levels[i],
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
                d <- accessD(wd, level = levels[i], boundary = boundary)
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
                d <- c(d, accessD(wd, level = levels[i],
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
                d <- accessD(wd, level = levels[i], boundary = boundary)
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
        d <- accessD(wd, level = levels[i], boundary = boundary)
        if(type == "hard") {
            d[abs(d) <= thresh[i]] <- 0
            if(verbose)
                cat("Level: ", levels[i], " there are ",
                    sum(d == 0), " zeroes\n")
        }
        else if(type == "soft")
            d <- sign(d) * (abs(d) - thresh[i]) * (abs(d) > thresh[i])
        wd <- putD(wd, level = levels[i], v = d, boundary = boundary)
    }
    wd
}

uncompress <- function(x, ...) UseMethod("uncompress")

uncompress.default <- function(v, verbose = FALSE)
{
    ctmp <- class(v)
    if(is.null(ctmp)) {
        stop("Object v has no class")
    }
    else if(ctmp == "uncompressed") {
        if(verbose)
            cat("Not compressed\n")
        return(unclass(v$vector))
    }
    else if(ctmp == "compressed") {
        answer <- rep(0, length = v$original.length)
        answer[v$position] <- v$values
        if(verbose)
            cat("Uncompressed to length ", length(answer), "\n")
        return(answer)
    }
    else stop("v has unknown class")
}

uncompress.imwdc <- function(imwdc, verbose = FALSE)
{
    if(verbose) cat("Argument checking\n")
    ctmp <- class(imwdc)
    if(is.null(ctmp) || all(ctmp != "imwdc"))
        stop("argument `imwdc' is not of class \"imwdc\"")

    unsquished <-
        imwdc[c("nlevels", "fl.dbase", "filter", "w0Lconstant", "bc")]
    ##
    ##	 Go round loop compressing each set of coefficients
    ##
    for(level in 0:(imwdc$nlevels - 1)) {
        if(verbose)
            cat("Level ", level, "\n\t")
        nm <- lt.to.name(level, "CD")
	nm.count<-length(names(unsquished))
        if(verbose)
            cat("CD\t")
        unsquished$xxxx <- uncompress.default(imwdc[[nm]], ver = verbose)
	names(unsquished)[nm.count+1]<-nm
        nm <- lt.to.name(level, "DC")
        if(verbose)
            cat("\tDC\t")
        unsquished$xxxx <- uncompress.default(imwdc[[nm]], ver = verbose)
	names(unsquished)[nm.count+2]<-nm
        nm <- lt.to.name(level, "DD")
        if(verbose)
            cat("\tDD\t")
        unsquished$xxxx <- uncompress.default(imwdc[[nm]], ver = verbose)
	names(unsquished)[nm.count+3]<-nm
    }
    class(unsquished) <- "imwd"
    if(verbose && exists("object.size", mode="function"))
        cat("Overall inflation: Was: ",
            w <- object.size(imwd), " Now:",
            s <- object.size(unsquished),
            " (", signif((100 * s)/w, 3), "%)\n")
    unsquished
}

wd <- function(data, filter.number = 2, family = "DaubExPhase",
	       bc = "periodic",	verbose = FALSE)
{
    if(verbose)
        cat("Argument checking...")
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

wr <- function(wd, start.level = 0, verbose = FALSE,
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

pack8bit <- function(v)
{
    ## Purpose: Compress vector of values in 0:255 into an integer of 1/4 length
    ## ----------------------------------------------------------------------
    ## Author: Martin Mächler, Date:  5 Oct 99, 22:31
    lv <- length(v <- as.integer(v))
    if(any(v < 0 | v > 255))
      stop("`v' is outside range 0..255")
    if((r <- lv %% 4))
      v <- c(v, rep(0,r))
    as.integer(c(matrix(v, ncol=4) %*% 256^(0:3))- 2.^31)
}

unpack8bit <- function(v)
{
    ## Purpose: UnCompress vector that has been compressed by compress8to32
    ## ----------------------------------------------------------------------
    ## Author: Martin Mächler, Date:  5 Oct 99, 22:31
    lv <- length(v <- as.double(2^31) + v)
    b <- 256
    v1 <- v %% b ; v <- as.integer(v %/% b)
    b <- as.integer(b)
    v2 <- v %% b ; v <- v %/% b
    v3 <- v %% b ; v <- v %/% b
    c(cbind(as.integer(v1),v2,v3,v))
}

wvrelease <- function(do.cat = interactive())
{
    wv <- list(major = 2.2, R.minor = 4)
    if(do.cat)
	cat("S/R wavelet software, release ", wv$major,", installed\n",
	    "Copyright Guy Nason 1993\n",
	    "R version ", wv$major,"-", wv$R.minor,
	    ": Arne Kovac 1997; Martin Maechler, 1999-2000\n", sep="")
    invisible(wv)
}

wvrelease()
##- cat("WARNING: You are in the wavelet software distribution\n")
##- cat("Take care not to delete any functions\n")
