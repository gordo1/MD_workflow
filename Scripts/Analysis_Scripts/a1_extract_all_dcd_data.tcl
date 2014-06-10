#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a1_extract_all_dcd_data.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-04 20:16:45
# MODIFIED: 2014-06-09 14:15:32

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl

mol new [ glob ../InputFiles/*psf ]
mol addfile [ glob ../InputFiles/*pdb ]

set sel_all [atomselect top {noh protein}]
reduced $sel_all no_water_no_hydrogen

exit
