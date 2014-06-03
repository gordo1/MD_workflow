#!/bin/bash
# AUTHOR:   Shane Gordon
# FILE:     a2_create_no_H_no_H2O_dcd.sh
# ROLE:     This is a simple launch script to run:
#           <main>/Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
# CREATED:  2014-06-03 13:32:45
# MODIFIED: 2014-06-03 13:32:45

# This will create a version of the centered dcd trajectory without water or 
# hydrogen for easier analysis. 

# Launch script: 
vmd -dispdev text -e ../Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
# 
