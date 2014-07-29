#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:04:49
# MODIFIED: 2014-07-28 16:26:05

source ../Scripts/Analysis_Scripts/clustering_configuration.tcl

# read in raw data: 
puts " reading in reduced data set:"
#source basic_vmd_setup.vmd
#source combined_dcd_loader_script.vmd
set input "no_water_no_hydrogen"
mol new $input.psf
mol addfile $input.dcd waitfor all

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl
source ../Scripts/Analysis_Scripts/clustering_configuration.tcl

# Get number of frames
set frame_no [molinfo top get numframes]

# Calculates all salt bridges formed during the simulation
sasa_scan "protein" protein_sasa.txt 10
sasa_scan "protein and resid < 192" protein_sasa_N.txt 10
sasa_scan "protein and resid > 215" protein_sasa_C.txt 10
saltbr 0 -1 [ atomselect top "protein" ] SaltBridges

exit
