#!/usr/bin/env R
#################################################################################
#   
#   File Name: a5_bio3d_analyses.R
#   Created: Sun 25 May 20:34:29 2014
#   Last Modified: Sun 25 May 20:37:19 2014
#   Created By: Shane Gordon
#
################################################################################

library(bio3d)
#pdbfile <- read.pdb("no_water_no_hydrogen.pdb")
#dcdfile <- read.dcd("no_water_no_hydrogen.dcd")

dcdfile <- system.file("examples/hivp.dcd", package = "bio3d")
pdbfile <- system.file("examples/hivp.pdb", package = "bio3d")

dcd <- read.dcd(dcdfile)
pdb <- read.pdb(pdbfile)

ca.inds <- atom.select(pdb, elety = "CA")
xyz <- fit.xyz(fixed = pdb$xyz, mobile = dcd, fixed.inds = ca.inds$xyz, mobile.inds = ca.inds$xyz)

pdf("a5_traj_rmsd.pdf")
rd <- rmsd(xyz[1, ca.inds$xyz], xyz[, ca.inds$xyz])
plot(rd, typ = "l", ylab = "RMSD", xlab = "Frame No.")
points(lowess(rd), typ = "l", col = "red", lty = 2, lwd = 2)
hist(rd, breaks = 40, freq = FALSE, main = "RMSD Histogram", xlab = "RMSD")
lines(density(rd), col = "gray", lwd = 3)
#summary(rd)
dev.off()

pdf("a5_traj_rmsf.pdf")
rf <- rmsf(xyz[, ca.inds$xyz])
plot(rf, ylab = "RMSF", xlab = "Residue Position", typ = "l")
dev.off()
