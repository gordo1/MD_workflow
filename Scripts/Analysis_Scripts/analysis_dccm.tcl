#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     analysis_dccm.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:48:18

# LOAD USEFUL ANALYSIS SCRIPTS -------------------------------------------- {{{

source ../Scripts/Tcl_Scripts/analysis.tcl
source ../Scripts/Tcl_Scripts/bigdcd.tcl

# }}}

# VARIABLES --------------------------------------------------------------- {{{

set input_psf "no_water"
set seltext "protein"
set seltext_protein "protein"
set seltext_backbone "protein and backbone"
set seltext_CA "protein and name CA"
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


proc align_dcd { dcd seltext } {
  set traj temp.dcd
  set dcd_i $dcd
  mol addfile $dcd_i waitfor all
  fitframes top $align_seltext
  animate write dcd $traj waitfor all top
  animate delete all
}

# }}}

# Sequentially read in args as $1, $2, etc.
regexp {0.[0-9]{1,3}} $dcd index_no

# Variable definitions for later
set input_t temp.dcd
set input $dcd
set o dccm_$index_no.dat
set out_dir $raw/sim_$index_no
set mol [ mol new $input_psf.psf type psf waitfor all ]
set reference_CA [ atomselect $mol $seltext_CA frame 0 ]
set sel_protein [ atomselect $mol $seltext_protein ]
set sel_backbone [ atomselect $mol $seltext_backbone ]
set sel_CA [ atomselect $mol $seltext_CA ]
mol addfile $input_psf.pdb first 0 last 0 waitfor all

# dccm
filecheck $out_dir/$o
set mol [ mol new $input_psf.psf type psf waitfor all ]
align_dcd $dcd $seltext
set sel [ atomselect top $seltext_protein ]
bigcorr $sel ccmat cmlast reslist sarray $input_t
bigdcd_wait
cross_corr_finis $o ccmat reslist
file rename -force $o $out_dir/$o

exit
