#!/usr/bin/env tclsh
#################################################################################
#   
#   File Name: 03-solvate_ionize.tcl
#   Created: Thu 22 May 2014 15:25:22 EST
#   Last Modified: Thu 22 May 2014 15:32:19 EST
#   Created By: Shane Gordon
#
################################################################################

# Solvate
set psf "change_me.1.psf"
set pdb "change_me.1.pdb"
set rbddh   "change_me.1_solvate"
source ./rhombicdodecahedron.tcl

# Ionize
set iprefix "change_me.1_solvate"
set oprefix "change_me.1_ionized"
set ionconc 0.15

package require autoionize
autoionize -psf $iprefix.psf -pdb $iprefix.pdb -sc $ionconc -o $oprefix

exit
