#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_dccm.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:48:18

source ../Scripts/Analysis_Scripts/common_analysis.tcl
source ../Scripts/Tcl_Scripts/cross_corr2.tcl

set dcd [ lindex $argv 0 ]
set align_seltext [ lrange $argv 1 end ]
set seltext "protein"

proc align_dcd {dcd seltext} {
  set dcd_o temp.dcd
  set dcd_i $dcd
  mol addfile $dcd_i waitfor all
  fitframes top $align_seltext
  animate write dcd $dcd_o waitfor all top
  animate delete all
}

# Sequentially read in args as $1, $2, etc.
# set i 0; foreach n $argv {set [incr i] $n}
regexp {0.[0-9]{1,3}} $dcd index_no

# Variable definitions for later
set input_t temp.dcd
set input $dcd
set out_dir $raw/sim_$index_no
set mol [ mol new $input_psf.psf type psf waitfor all ]
set reference_CA [ atomselect $mol "$seltext and name CA" frame 0 ]
set sel_protein [ atomselect $mol "$seltext" ]
set sel_backbone [ atomselect $mol "$seltext and backbone" ]
set sel_CA [ atomselect $mol "$seltext and name CA" ]
mol addfile $input_psf.pdb first 0 last 0 waitfor all

# RMSD scan
filecheck $out_dir/rmsd_protein_$index_no.txt
bigdcd rmsdscan_bigdcd $input
bigdcd_wait
file rename -force rmsd_protein.txt $out_dir/rmsd_protein_$index_no.txt

# dccm
set o dccm_$index_no.dat
filecheck $out_dir/$o
set mol [ mol new $input_psf.psf type psf waitfor all ]
align_dcd $dcd $seltext
set sel [ atomselect top $seltext_protein ]
bigcorr $sel ccmat cmlast reslist sarray $input_t
bigdcd_wait
cross_corr_finis $o ccmat reslist
file rename -force $o $out_dir/$o

exit
