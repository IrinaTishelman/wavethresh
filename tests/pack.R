library(wavethresh)

stopifnot(c(1:7,0) == unpack8bit(pack8bit(1:7)))

pad.to.4 <- function(v) {
    r <- length(v) %% 4
    if(r == 0) v else c(v, rep.int(0, 4-r))
}

set.seed(4)
for(n in 1:1000) {
    v <- sample(0:255, rpois(1, 20), replace = TRUE)
    stopifnot(pad.to.4(v) == unpack8bit(pack8bit(v)))
}
