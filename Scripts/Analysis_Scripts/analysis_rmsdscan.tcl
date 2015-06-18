#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_rmsdscan.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:40:17
# MODIFIED: 2015-06-18 22:36:11

source ../Scripts/Analysis_Scripts/common_analysis.tcl

foreach index [ lsort [glob no_water_*.dcd] ] {
  regexp {0.[0-9]{1,3}} $index index_no

  # Variable definitions for later
  set input "no_water_${index_no}"
  set out_dir "$raw/sim_$index_no"
  dir_make $out_dir
  set num_rmsf_windows 5
  set mol [ mol new $input_psf.psf type psf waitfor all ]
  set reference_CA [ atomselect $mol "$seltext_CA" frame 0]
  set sel_protein [atomselect $mol "$seltext_protein"]
  set sel_backbone [atomselect $mol "$seltext_backbone"]
  set sel_CA [ atomselect $mol "$seltext_CA" ]
  mol addfile $input_psf.pdb first 0 last 0 waitfor all

  # RMSD scan
  filecheck rmsd_protein_${index_no}.txt
  bigdcd rmsdscan_bigdcd $input.dcd
  bigdcd_wait
  file rename "rmsd_protein.txt" "${out_dir}/rmsd_protein_${index_no}.txt"
}

exit
