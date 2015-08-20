#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_rmsdscan.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:40:17
# MODIFIED: 2015-07-11 23:00:40

source ../Scripts/Analysis_Scripts/common_analysis.tcl

set dcd [ lindex $argv 0 ]
set align_seltext [ lrange $argv 1 end ]
set seltext "protein"

# Sequentially read in args as $1, $2, etc.
# set i 0; foreach n $argv {set [incr i] $n}
regexp {0.[0-9]{1,3}} $dcd index_no

# Variable definitions for later
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

exit
