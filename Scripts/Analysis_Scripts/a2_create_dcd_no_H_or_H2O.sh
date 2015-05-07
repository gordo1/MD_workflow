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
reduced="no_water"
echo "Reading in data set..."
echo "Writing reduced selection..."
vmd -dispdev text -e ../Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
echo " Merging reduced data..."

# source directory list
y=$(head -n 1 ../.dir_list.txt) 
for i in $y
do
  index=`echo $i | sed 's/.*_//' | | sed 's/\..*//'`
  ../Scripts/Tools/catdcd -otype dcd -o no_water_${index_no}.dcd ${index_no}_temp_*.dcd
  ls ${index_no}_temp_*.dcd
done
