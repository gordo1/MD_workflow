#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_sasa.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:50:38
# MODIFIED: 2015-06-18 22:55:07

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

  # Time-dependent SASA-scan for entire simulation
  filecheck ${out_dir}/protein_sasa_${index_no}.txt
  bigdcd sasa_scan_bigdcd $input.dcd
  bigdcd_wait
  file rename "protein_sasa.txt" "${out_dir}/protein_sasa_${index_no}.txt"
}

exit
