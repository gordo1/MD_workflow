#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_rmsd.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:40:17
# MODIFIED: 2015-07-11 23:00:40

# LOAD USEFUL ANALYSIS SCRIPTS -------------------------------------------- {{{

source ../Scripts/Tcl_Scripts/analysis.tcl
source ../Scripts/Tcl_Scripts/bigdcd.tcl

# }}}

# VARIABLES --------------------------------------------------------------- {{{

set input_psf "no_water"
set seltext "protein"
set seltext_protein "protein"
set seltext_backbone "$seltext_protein and backbone"
set seltext_CA "$seltext_protein and name CA"
set molid 0
set dcd [ lindex $argv 0 ]
set raw [ lindex $argv 1 ]
set align_seltext [ lrange $argv 2 end ]

# }}}

# SUBROUTINES ------------------------------------------------------------- {{{


proc dircheck { dirname } {
  if { [ file isdirectory $dirname ] } {
    file delete -force $dirname
    puts "Deleted $dirname"
  }
}



proc filecheck { filename } {
  if { [ file exists $filename ] } {
    file delete -force $filename
    puts "Deleted $filename"
  }
}



proc dir_make { dir } {
  # If directory exists, blow it away and make a new one
  # Else, make the directory
  if { [ file isdirectory $dir ] } {
    puts "Directory $dir already exists!"
  } else {
    file mkdir $dir
  }
}

# }}}

# Sequentially read in args as $1, $2, etc.
regexp {0.[0-9]{1,3}} $dcd index_no

# Variable definitions for later
set input $dcd
set out_dir $raw/sim_$index_no
set mol [ mol new $input_psf.psf type psf waitfor all ]
set reference_CA [ atomselect $mol $seltext_CA frame 0 ]
set sel_protein [ atomselect $mol $seltext_protein ]
set sel_backbone [ atomselect $mol $seltext_backbone ]
set sel_CA [ atomselect $mol $seltext_CA ]
mol addfile $input_psf.pdb first 0 last 0 waitfor all

# RMSD scan
filecheck $out_dir/rmsd_protein_$index_no.txt
bigdcd rmsdscan_bigdcd $input
bigdcd_wait
file rename -force rmsd_protein.txt $out_dir/rmsd_protein_$index_no.txt

exit
