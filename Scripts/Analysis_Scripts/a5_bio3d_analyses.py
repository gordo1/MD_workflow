#!/usr/bin/env python
#################################################################################
#   
#   File Name: a5_bio3d_analyses.py 
#   Created: Sun 25 May 20:34:29 2014
#   Last Modified: Sun 25 May 20:37:19 2014
#   Created By: Shane Gordon
#
################################################################################

# TODO
#   Create a brief description of what this does!

from os.path import exists
import sys
import subprocess

INPUT = "no_water_no_hydrogen.dcd"
if exists(INPUT) == True:
        print ""
elif exists(INPUT) == False:
        print "File %s not found. Did \"a2_create_no_H_no_H2O_dcd.sh\" run successfully?" % INPUT
        sys.exit()



