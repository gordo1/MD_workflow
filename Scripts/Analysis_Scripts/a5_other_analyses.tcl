#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:04:49
# MODIFIED: 2014-09-22 11:02:44

#------------------------------------------------------------------------------

# read in raw data: 
puts " reading in reduced data set:"
set input "no_water_no_hydrogen"
mol new $input.psf
mol addfile $input.dcd waitfor all

#------------------------------------------------------------------------------

# Variable definitions for later
set seltext_backbone "protein and backbone"
set seltext_CA "protein and name CA"
set sel_backbone [atomselect top "$seltext_backbone"]
set sel_CA [atomselect top "$seltext_CA"]

#------------------------------------------------------------------------------

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl

# Get number of frames
set frame_no [molinfo top get numframes]

# RMSD scan
rmsdscan $seltext_backbone top

# Radius of gyration scan
rgyrscan $sel_backbone protein_radius_gyration.txt

# RMSF scan
rmsfscan $sel_CA rmsf_protein_backbone

# Calculates secondary structure over course of entire simulation
ss_calc top 0 [ expr [ molinfo top get numframes ] ] 10

# Time-dependent SASA-scan for entire simulation
sasa_scan "protein" protein_sasa.txt 10

# Calculates all salt bridges formed during the simulation
saltbr 0 -1 [ atomselect top "protein" ] SaltBridges

#------------------------------------------------------------------------------

exit
