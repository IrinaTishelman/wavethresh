### imwd() & imwr() : 2-D aka "IMage" wavelets

library(wavethresh)
options(digits = 8)
data(lennon)
imwdL <- imwd(lennon)
imwdL
rL <- imwr(imwdL)
stopifnot(all.equal(rL, lennon))

for(fn in 3:10) { ## family = "DaubExPhase" ; not Haar
    imwdL <- imwd(lennon, filter.number = fn)
    stopifnot(all.equal(imwr(imwdL), lennon))
}
