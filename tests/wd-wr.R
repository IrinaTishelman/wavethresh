### wd() & wr() : 1-D wavelets

library(wavethresh)
options(digits = 8)

example(wd)
wds # large!

for(fn in 1:10) { ## family = "DaubExPhase"
    wds <- wd(y, filter.number = fn)
    stopifnot(all.equal(wr(wds), y))
}

for(fn in 4:10) {
    wds <- wd(y, filter.number = fn, family = "DaubLeAsymm")
    stopifnot(all.equal(wr(wds), y))
}
