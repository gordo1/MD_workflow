#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:04:49
# MODIFIED: 2015-04-04 09:48:59

#------------------------------------------------------------------------------

# read in raw data: 
puts " reading in reduced data set:"
set input "no_water_no_hydrogen"

#------------------------------------------------------------------------------

# Variable definitions for later
set num_rmsf_windows 5
set seltext_protein "protein"
set seltext_backbone "protein and backbone"
set seltext_CA "protein and name CA"
set molid 0
set mol [ mol new $input.psf type psf waitfor all ]
set reference_CA [ atomselect $mol "$seltext_CA" frame 0]
set sel_protein [atomselect $mol "$seltext_protein"]
set sel_backbone [atomselect $mol "$seltext_backbone"]
set sel_CA [ atomselect $mol "$seltext_CA" ]
mol addfile $input.dcd first 0 last 0 waitfor all

#------------------------------------------------------------------------------

proc filecheck { filename } {
  if { [ file exists $filename ] } {
    file delete -force $filename
    puts "Deleted $filename"
  }
}

#------------------------------------------------------------------------------

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl
source ../Scripts/Tcl_Scripts/bigdcd.tcl

# Align frames to common reference
# fitframes top "backbone"

# Get number of frames
# set frame_no [molinfo top get numframes]
# set zero_based_frame_no [ expr $frame_no - 1 ]
# set windows 20 ;# 

# RMSD scan
filecheck rmsd_protein.txt
bigdcd rmsdscan_bigdcd $input.dcd
bigdcd_wait

# Radius of gyration scan
filecheck protein_radius_gyration.txt
bigdcd rgyrscan_bigdcd $input.dcd
bigdcd_wait

# RMSF scan
if { [file exists ./number_frames.txt ] } {
  set f [ open number_frames.txt r ]
  set r [ read $f ]
  close $f
  set num_frames $r
} else {
  puts "Can't find ./number_frames.txt.\nCan't manage RMSF calculations without this info"
}
set rmsf_fraction_count 1
set frame_incr [ expr $num_frames / $num_rmsf_windows ]

while { $rmsf_fraction_count <= $num_rmsf_windows } {
  set first_frame [ expr ( $rmsf_fraction_count - 1 ) * $frame_incr ]
  set last_frame [ expr ( $first_frame + $frame_incr ) -1 ]
  mol addfile $input.dcd first $first_frame last $last_frame waitfor all
  rmsfscan_range $sel_CA 0 -1 "rmsf_protein_backbone_${rmsf_fraction_count}of${num_rmsf_windows}"
  animate delete all
  incr rmsf_fraction_count
}

# Calculates secondary structure over course of entire simulation
filecheck sec_structure.dat
filecheck SecondaryStructure/betaPercent.plt
filecheck SecondaryStructure/coilPercent.plt
filecheck SecondaryStructure/helixPercent.plt
filecheck SecondaryStructure/turnPercent.plt
bigdcd ss_calc_bigdcd $input.dcd
bigdcd_wait

# Time-dependent SASA-scan for entire simulation
filecheck protein_sasa.txt
bigdcd sasa_scan_bigdcd $input.dcd
bigdcd_wait

#------------------------------------------------------------------------------

exit
