#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a2_create_no_H_no_H2O_dcd.sh
# ROLE:     This is a simple launch script to run:
#           <main>/Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
#           This will create a version of the centered dcd trajectory without water or 
#           hydrogen for easier analysis.
# CREATED:  2014-06-03 13:32:45
# MODIFIED: 2014-06-03 13:32:45

# Launch script: 

reduced="no_water_no_hydrogen"
../Scripts/Tools/catdcd -o $reduced.dcd -otype dcd -s ../InputFiles/*.psf -stype psf -i $reduced.text $(cat dcdfile_list.txt) 
vmd -dispdev text -e ../Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl

# Gnuplot plotting functions

GNUPLOTTEMPLATE="../Scripts/Gnuplot_Scripts/template.gpi"
gnuplot -e "FILE='./rmsf_protein_backbone.txt'" -e "OUTPUT='./rmsf_protein_backbone.pdf'" -e "YLABEL='RMSF (Angstrom)'" -e "XLABEL='Residue No.'" $GNUPLOTTEMPLATE
gnuplot -e "FILE='./rmsd_protein.txt'" -e "OUTPUT='./rmsd_protein.pdf'" -e "YLABEL='RMSD (Angstrom)'" -e "XLABEL='Frame No.'" $GNUPLOTTEMPLATE
gnuplot -e "FILE='./protein_radius_gyration.txt'" -e "OUTPUT='./protein_radius_gyration.pdf'" -e "YLABEL='R_g (Angstrom)'" -e "XLABEL='Frame No.'" $GNUPLOTTEMPLATE

# Create Gromacs-compatible tarjectory file for analysis

catdcd_d="../Scripts/Tools/catdcd"
string="no_water_no_hydrogen"

if [ -f $string.dcd ];
then
        $catdcd_d -o $string.trr -otype trr -s $string.psf -stype psf -first 0 -last -1 -dcd $string.dcd;
        trjconv -f $string.trr -o $string.xtc;
        # Clean up
        if [ -f \#$string.xtc*\# ];
        then
                rm \#$string.xtc*\#
        fi
        rm \#$string.xtc*\#
else
        echo "File \"$string.dcd\" wasn't found. Eep!"
fi

if [ -f $string.xtc ];
then
        echo "Everything seems to have worked."
else
        echo "File \"$string.trr\" wasn't found. Is \"trjconv\" installed under gromacs tools. If not, try installation using \'sudo apt-get install gromacs'"
fi

#
