#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:04:49
# MODIFIED: 2015-03-23 16:13:06

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

# Align frames to common reference
fitframes top "backbone"

# Get number of frames
set frame_no [molinfo top get numframes]
set zero_based_frame_no [ expr $frame_no - 1 ]
set windows 20 ;# 

# RMSD scan
rmsdscan $seltext_backbone top

# Radius of gyration scan
rgyrscan $sel_backbone protein_radius_gyration.txt

# RMSF scan
set fractions 5
set fraction_no 1
while {$fraction_no <= $fractions} {
  set end_range [ expr [expr $fraction_no * $zero_based_frame_no]/$fractions ]
  set start_range [ expr $end_range - [expr $zero_based_frame_no]/$fractions ]
  rmsfscan_range $sel_CA $start_range $end_range "rmsf_protein_backbone_${fraction_no}of${fractions}"
  incr fraction_no
}
rmsfscan $sel_CA rmsf_protein_backbone

# Calculates secondary structure over course of entire simulation
ss_calc top 0 $frame_no [ format "%.0f" [ expr $frame_no / $windows ] ] ;# Divide into nice windows

# Time-dependent SASA-scan for entire simulation
sasa_scan "protein" protein_sasa.txt [ format "%.0f" [ expr $frame_no / $windows ] ] ;# Divide into nice windows

# Calculates all salt bridges formed during the simulation
saltbr 0 -1 [ atomselect top "protein" ] SaltBridges

#------------------------------------------------------------------------------

exit
