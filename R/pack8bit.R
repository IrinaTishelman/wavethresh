pack8bit <- function(v8)
{
    ## Purpose: Compress vector of values in 0:255 into an integer of 1/4 length
    ## ----------------------------------------------------------------------
    ## Author: Martin Mächler, Date:  5 Oct 99, 22:31
    lv <- length(v8 <- as.integer(v8))
    if(any(v8 < 0 | v8 > 255))
      stop("`v8' is outside range 0..255")
    if((r <- lv %% 4))
      v8 <- c(v8, rep(0,r))
    as.integer(c(matrix(v8, ncol=4) %*% 256^(0:3))- 2.^31)
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
