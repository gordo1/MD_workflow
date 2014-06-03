#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:04:49
# MODIFIED: 2014-06-03 22:16:10

source ../Scripts/Analysis_Scripts/clustering_configuration.tcl

# read in raw data: 
puts " reading in entire data set:"
source basic_vmd_setup.vmd
source combined_dcd_loader_script.vmd

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl
source clustering_configuration.tcl

# Get number of frames
set frame_no [molinfo top get numframes]

# Calculates all salt bridges formed during the simulation
saltbr 0 $frame_no "protein" SaltBridges


