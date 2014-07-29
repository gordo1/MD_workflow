#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a2_create_dcd_no_H_or_H2O.tcl
# ROLE:     This tcl script is used to generate a reduced selection (not water) by using 
#           the analysis.tcl script for easier analysis on machines with less memory.
# CREATED:  2014-06-06 15:43:25
# MODIFIED: 2014-06-06 15:43:25

#------------------------------------------------------------------------------

# open output file:
set out [open "summary.txt" a]

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl

set reduced_sel "protein"
set sel_all [ atomselect top "$reduced_sel" ]

#------------------------------------------------------------------------------

# write out reduced data: 
outputcheck no_water_no_hydrogen.dcd

# taking reduced data set and aligning protein atoms
mol new no_water_no_hydrogen.psf
mol addfile no_water_no_hydrogen.dcd waitfor all

source ../Scripts/Analysis_Scripts/clustering_configuration.tcl
set sel [atomselect top "$reduced_sel"]

puts " creating reduced selection of data: no water no hydrogen"

#------------------------------------------------------------------------------
puts " aligning protein backbone in reduced data"

# fit reduced data to first frame and protein backbone: 
fitframes top "$reduced_sel"

# write out aligned reduced data: 
animate write dcd no_water_no_hydrogen.dcd beg 0 end -1 sel $sel waitfor all
outputcheck no_water_no_hydrogen.dcd

mol delete all

mol new no_water_no_hydrogen.psf
mol addfile no_water_no_hydrogen.dcd waitfor all

#-- Some quick and easy things to calculate:-----------------------------------
if {$calc_rog == 1} {
 puts " calculating radius of gyration of protein backbone: " 
        set sel [atomselect top "protein and backbone" ]  
        rgyrscan $sel protein_radius_gyration.txt 
}

if {$calc_rmsf == 1} {
        puts " calculating rmsf of protein backbone "
        set sel_ca [atomselect top "protein and name CA" ]  
        rmsfscan $sel_ca rmsf_protein_backbone
}

if {$calc_rmsd == 1} {
        puts " calculating rmsd of protein "
        set seltext "protein and backbone"
        rmsdscan $seltext top 0 -1
}
# clean up
close out

# Exit VMD
exit
