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
pdbfile <- "~/Desktop/WT_apoE4.pdb"
dcdfile <- "~/Desktop/WT_apoE4.dcd"

#dcdfile <- system.file("examples/hivp.dcd", package = "bio3d")
#pdbfile <- system.file("examples/hivp.pdb", package = "bio3d")

dcd <- read.dcd(dcdfile)
pdb <- read.pdb(pdbfile)

ca.inds <- atom.select(pdb, elety = "CA")
xyz <- fit.xyz(fixed = pdb$xyz, mobile = dcd, fixed.inds = ca.inds$xyz, mobile.inds = ca.inds$xyz)

pdf("bio3d/a5_traj_rmsd_no_water_no_hydrogen.pdf")
rd <- rmsd(xyz[1, ca.inds$xyz], xyz[, ca.inds$xyz])
plot(rd, typ = "l", ylab = "RMSD", xlab = "Frame No.")
points(lowess(rd), typ = "l", col = "red", lty = 2, lwd = 2)
hist(rd, breaks = 40, freq = FALSE, main = "RMSD Histogram", xlab = "RMSD")
lines(density(rd), col = "gray", lwd = 3)
dev.off()

pdf("bio3d/a5_traj_rmsf_no_hydrogen.pdf")
rf <- rmsf(xyz[, ca.inds$xyz])
plot(rf, ylab = "RMSF", xlab = "Residue Position", typ = "l")
dev.off()

pdf("bio3d/a5_traj_pca_no_hydrogen.pdf")
pc <- pca.xyz(xyz[, ca.inds$xyz])
plot(pc, col = bwr.colors(nrow(xyz)))
dev.off()

pdf("bio3d/a5_traj_dccm_no_hydrogen.pdf")
cij <- dccm(xyz[, ca.inds$xyz])
plot(cij)
dev.off()
#q(save="no")
