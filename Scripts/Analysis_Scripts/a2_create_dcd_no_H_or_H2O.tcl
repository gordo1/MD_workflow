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

# read in raw data: 
puts " reading in entire data set:"
source basic_vmd_setup.vmd

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl

# source combined_dcd_loader_script.vmd 
mol new [ glob ../InputFiles/*psf ]
mol addfile [ glob ../InputFiles/*pdb ]

set reduced_sel "noh protein"
set sel_all [ atomselect top "$reduced_sel" ]
reduced $sel no_water_no_hydrogen
set num_sel [$sel num]
set cha_all [get_charge $sel_all ]
puts $out " Total reduced atoms:  $num_sel \n  "
puts $out " Total charge:         $cha_all  "

#------------------------------------------------------------------------------

# write out reduced data: 
# animate write dcd no_water_no_hydrogen.dcd waitfor all sel $sel

puts " reading in reduced data..."

# delete original; read in reduced data set: 
mol delete top

# generates a list of dcd files that will be reduced
set fp [ open "./dcdfile_list.txt" r ]
set file_data [ read $fp ]
set data [ split $file_data "\n" ]

# file-by-file removal of atoms to a reduced selection
# these temp files are subsequently concatenated using catdcd
mol new [ glob ../InputFiles/*psf ]
set i 1
foreach dcd $data {
        set sel_all [ atomselect top { noh protein } ]
        animate read dcd ${dcd} beg 0 end -1 waitfor all top
        animate write dcd temp_$i.dcd beg 0 end -1 sel $sel_all waitfor all top
        animate delete all
        incr i
}

puts " Concatenating reduced trajectory files..."
for { set dcd_files 1 } { $dcd_files < [ expr $i - 1 ] } { incr dcd_files } {
        set a [ expr $dcd_files + 1 ]
        exec ../Scripts/Tools/catdcd -o temp_new.dcd temp_$dcd_files.dcd temp_$a.dcd
        exec mv temp_new.dcd temp_$a.dcd
        # cleaning up
        file delete temp_$dcd_files.dcd
}
# write out reduced data: 
exec mv temp_[ expr $i -1 ].dcd no_water_no_hydrogen.dcd
outputcheck no_water_no_hydrogen.dcd
mol delete all

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
