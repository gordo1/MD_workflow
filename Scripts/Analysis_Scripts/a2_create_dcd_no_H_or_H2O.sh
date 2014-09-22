#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a2_create_dcd_no_H_or_H2O.sh
# ROLE:     This is a simple launch script to run:
#           <main>/Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
#           This will create a version of the centered dcd trajectory without water or 
#           hydrogen for easier analysis.
# CREATED:  2014-06-06 15:45:58
# MODIFIED: 2014-06-06 15:46:11

# Launch script: 

source ../Scripts/common_functions.sh
reduced="no_water_no_hydrogen"
echo "Reading in data set..."
echo "Writing reduced selection..."
vmd -dispdev text -e ../Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
echo " Merging reduced data..."
../Scripts/Tools/catdcd -otype dcd -o no_water_no_hydrogen.dcd temp_*.dcd

# Clean up any temp files used in concatenating trajectories
rm temp_*.dcd
