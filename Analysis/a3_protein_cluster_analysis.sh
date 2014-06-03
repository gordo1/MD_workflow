#!/bin/bash
# AUTHOR:   Shane Gordon
# FILE:     a2_create_no_H_no_H2O_dcd.sh
# ROLE:     TODO
# CREATED:  2014-06-03 13:32:45
# MODIFIED: 2014-06-03 14:37:17

# This is a simple launch script to run: 
# <main>/Scripts/Analysis_Scripts/a3_protein_backbone_cluster_analysis

# This will run a clustering job to sort the backbones of protein conformations. 
# 
# launch script: 

vmd -dispdev text -e ../Scripts/Analysis_Scripts/a3_protein_backbone_cluster_analysis.tcl
# 
