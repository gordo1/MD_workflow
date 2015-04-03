#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.sh
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:02:52
# MODIFIED: 2015-04-04 09:27:47

vmd -dispdev text -e ../Scripts/Analysis_Scripts/a5_other_analyses.tcl

# Concatenate secondary structures

if [[ -d ./SecondaryStructure ]]; then
  paste ./SecondaryStructure/* > ./SecondaryStructure/SecondaryStructure.dat
fi

# Some useful plots

GNUPLOTTEMPLATE="../Scripts/Gnuplot_Scripts/template_4plot.gpi"
gnuplot -e "OUTPUT='${PWD}/analysis.pdf'" \
        -e "SECONDARYSTRUCTURE='${PWD}/SecondaryStructure/SecondaryStructure.dat'" \
        -e "YLABEL1='Percent Structure'" \
        -e "XLABEL1='Simulation Frame'" \
        -e "TITLE1p1='Beta'" \
        -e "TITLE1p2='Coil'" \
        -e "TITLE1p3='Helix'" \
        -e "TITLE1p4='Turn'" \
        -e "FILE2='./protein_radius_gyration.txt'" \
        -e "YLABEL2='R_{g} (\305)'" \
        -e "XLABEL2='Simulation Frame'" \
        -e "TITLE2='R_{g}'" \
        -e "FILE3='./rmsd_protein.txt'" \
        -e "YLABEL3='RMSD (A)'" \
        -e "XLABEL3='Simulation Frame'" \
        -e "TITLE3='RMSD'" \
        -e "YLABEL4='RMSF (A)'" \
        -e "XLABEL4='Residue No'" \
        -e "FILE5='./protein_sasa.txt'" \
        -e "YLABEL5='SASA (units)'" \
        -e "XLABEL5='Simulation Frame'" \
        -e "TITLE5='SASA'" \
        $GNUPLOTTEMPLATE
