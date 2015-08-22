#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_rsasa.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-07-07 11:21:21
# MODIFIED: 2015-07-26 16:34:19

source ../Scripts/Analysis_Scripts/common_analysis.tcl

set dcd [ lindex $argv 0 ]
set raw [ lindex $argv 1 ]
set align_seltext [ lrange $argv 2 end ]

# Sequentially read in args as $1, $2, etc.
# set i 0; foreach n $argv {set [incr i] $n}
regexp {0.[0-9]{1,3}} $index index_no

# Variable definitions for later
set seltext "protein"
set input $dcd
set out_dir $raw/sim_$index_no
set mol [ mol new $input_psf.psf type psf waitfor all ]
set reference_CA [ atomselect $mol "$seltext and name CA" frame 0 ]
set sel_protein [ atomselect $mol "$seltext" ]
set sel_backbone [ atomselect $mol "$seltext and backbone" ]
set sel_CA [ atomselect $mol "$seltext and name CA" ]
mol addfile $input_psf.pdb first 0 last 0 waitfor all

# Time-dependent SASA-scan for entire simulation
filecheck $out_dir/protein_sasa_$index_no.txt
bigdcd sasa_scan_bigdcd $input
bigdcd_wait
file rename -force protein_sasa.txt $out_dir/protein_sasa_$index_no.txt

exit
