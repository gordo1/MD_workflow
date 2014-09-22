#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     a2_create_dcd_no_H_or_H2O.tcl
# ROLE:     This tcl script is used to generate a reduced selection (not water) by using 
#           the analysis.tcl script for easier analysis on machines with less memory.
# CREATED:  2014-06-06 15:43:25
# MODIFIED: 2014-06-06 15:43:25
# NOTE: Hydrogens have now been left in the reduced files. Needed for some analysis steps

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

set reduced_sel "protein"
set sel_all [ atomselect top "$reduced_sel" ]
reduced $sel no_water_no_hydrogen
set num_sel [$sel num]
set cha_all [get_charge $sel_all ]
puts $out " Total reduced atoms:  $num_sel \n  "
puts $out " Total charge:         $cha_all  "
close $out

#------------------------------------------------------------------------------

# write out reduced data: 

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
        set sel_all [ atomselect top $reduced_sel ]
        animate read dcd ${dcd} beg 0 end -1 waitfor all top
        if { $i < 10 } {        
                animate write dcd temp_000$i.dcd beg 0 end -1 sel $sel_all waitfor all top
                animate delete all
                incr i
        } elseif { $i < 100 } {
                animate write dcd temp_00$i.dcd beg 0 end -1 sel $sel_all waitfor all top
                animate delete all
                incr i
        } elseif { $i < 1000 } {
                animate write dcd temp_0$i.dcd beg 0 end -1 sel $sel_all waitfor all top
                animate delete all
                incr i
        } elseif { $i < 10000 } {
                animate write dcd temp_$i.dcd beg 0 end -1 sel $sel_all waitfor all top
                animate delete all
                incr i
        }
}

#------------------------------------------------------------------------------

set reduced_sel "protein"
set sel_all [ atomselect top "$reduced_sel" ]
mol delete all

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

exit
