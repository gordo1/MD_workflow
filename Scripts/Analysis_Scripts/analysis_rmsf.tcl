#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_rmsf.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:43:31
# MODIFIED: 2015-07-12 10:59:46

source ../Scripts/Analysis_Scripts/common_analysis.tcl

set dcd [ lindex $argv 0 ]
set raw [ lindex $argv 1 ]
set align_seltext [ lrange $argv 2 end ]

regexp {0.[0-9]{1,3}} $dcd index_no

# Variable definitions for later
set seltext "protein"
set input $dcd
set out_dir $raw/sim_$index_no
set num_rmsf_windows 5
set mol [ mol new $input_psf.psf type psf waitfor all ]
set reference_CA [ atomselect $mol "$seltext and name CA" frame 0]
set sel_protein [atomselect $mol "$seltext and protein"]
set sel_backbone [atomselect $mol "$seltext and backbone"]
set sel_CA [ atomselect $mol "$seltext and name CA" ]
mol addfile $input_psf.pdb first 0 last 0 waitfor all

# RMSF scan
if { [file exists ./number_frames_${index_no}.txt ] } {
  set f [ open "number_frames_${index_no}.txt" r ]
  set r [ read $f ]
  close $f
  set num_frames $r
} else {
  puts "Can't find number_frames_${index_no}.txt"
  puts "Can't manage RMSF calculations without this info"
  exit
}
set rmsf_fraction_count 1
set frame_incr [ expr $num_frames / $num_rmsf_windows ]

while { $rmsf_fraction_count <= $num_rmsf_windows } {
  set first_frame [ expr ( $rmsf_fraction_count - 1 ) * $frame_incr ]
  set last_frame [ expr ( $first_frame + $frame_incr ) -1 ]
  mol addfile $dcd first $first_frame last $last_frame waitfor all
  fitframes top "$align_seltext and name CA"
  rmsfscan_range $sel_CA 1 -1 $out_dir/rmsf_protein_backbone_${rmsf_fraction_count}of${num_rmsf_windows}_${index_no}
  animate delete beg 1 end -1 ;# Spare the first frame, containing ref pdb
  incr rmsf_fraction_count
}
mol addfile $dcd first 0 last -1 waitfor all
fitframes top "$align_seltext and name CA"
rmsfscan_range $sel_CA 1 -1 $out_dir/rmsf_all_protein_backbone_${index_no}
animate delete beg 1 end -1 ;# Spare the first frame, containing ref pdb

exit
