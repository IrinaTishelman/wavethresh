library(wavethresh)
options(digits = 10)

for(fn in 1:10) { ## family = "DaubExPhase"
    print(filter.select(filter.number = fn))
    print(draw(filter.number = fn, resolution = 32, plot = FALSE))
}

for(fn in 4:10) {
    print(filter.select(filter.number = fn, family = "DaubLeAsymm"))
    draw(filter.number = fn, resolution = 32, plot = FALSE, family = "DaubLeAsymm")
}
