# data() sets this directory
load("lennon.rda")# contains Martin's 8->32 compressed integers
lennon <- matrix(unpack8bit(lennon4), nr = 256, nc = 256)
rm(lennon4)
