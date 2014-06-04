#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     /home/gordo/Desktop/WT_APOE3/Scripts/Analysis_Scripts/a1_extract_all_dcd_data.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-04 20:16:45
# MODIFIED: 2014-06-04 20:19:36

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl

mol new [ glob ../InputFiles/*psf ]
mol addfile [ glob ../InputFiles/*pdb ]

set sel_all [atomselect top {not water and not hydrogen}]
reduced $sel_all no_water_no_hydrogen

exit
