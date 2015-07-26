#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     resid_sasa.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-07-07 11:21:21
# MODIFIED: 2015-07-26 16:34:19

source ../Scripts/Analysis_Scripts/common_analysis.tcl

set oname "resid_protein_sasa"

foreach index [ lsort [glob "no_water_*.dcd"] ] {
  regexp {0.[0-9]{1,3}} $index index_no

  # Variable definitions for later
  set input "no_water_${index_no}"
  set out_dir "$raw/sim_$index_no"
  dir_make $out_dir
  set mol [ mol new $input_psf.psf type psf waitfor all ]
  set reference_CA [ atomselect $mol "$seltext_CA" frame 0]
  set sel_protein [atomselect $mol "$seltext_protein"]
  set sel_backbone [atomselect $mol "$seltext_backbone"]
  set sel_CA [ atomselect $mol "$seltext_CA" ]
  mol addfile $input_psf.pdb first 0 last 0 waitfor all

  set sel_protein "protein and name CA"

  filecheck $oname.txt
  bigdcd sasa_resid_scan_bigdcd no_water_${index_no}.dcd
  bigdcd_wait
  file rename "$oname.txt" "$out_dir/$oname.txt"
}

exit
