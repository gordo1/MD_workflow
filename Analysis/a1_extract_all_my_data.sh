#!/bin/bash

# This is a simple launch script to run: 
# <main>/Scripts/Analysis_Scripts/a1_extract_all_data

# This will extract and collate all jobs in the job directories under ../MainJob_dir 
# 
# launch script: 

 vmd -dispdev text -e ../Scripts/Analysis_Scripts/a1_extract_all_dcd_data.tcl >/dev/null
 ../Scripts/Analysis_Scripts/a1_extract_all_dcd_data

# 
