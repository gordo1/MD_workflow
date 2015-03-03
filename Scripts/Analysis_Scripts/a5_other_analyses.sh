#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.sh
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:02:52
# MODIFIED: 2015-03-03 21:13:18

vmd -dispdev text -e ../Scripts/Analysis_Scripts/a5_other_analyses.tcl

# Concatenate secondary structures

if [[ -d ./SecondaryStructure ]]; then
  paste ./SecondaryStructure/* > ./SecondaryStructure/SecondaryStructure.dat
fi

# Some useful plots

GNUPLOTTEMPLATE="../Scripts/Gnuplot_Scripts/template_4plot.gpi"
gnuplot -e "OUTPUT='./analysis.pdf'" \
        -e "SECONDARYSTRUCTURE='./SecondaryStructure/SecondaryStructure.dat'" \
        -e "YLABEL1='Percent Structure'" \
        -e "XLABEL1='Frame (10 ps frame^{-1})'" \
        -e "TITLE1p1='Beta'" \
        -e "TITLE1p2='Coil'" \
        -e "TITLE1p3='Helix'" \
        -e "TITLE1p4='Turn'" \
        -e "FILE2='./protein_radius_gyration.txt'" \
        -e "YLABEL2='R_{g} (Angstrom)'" \
        -e "XLABEL2='Frame (10 ps frame^{-1})'" \
        -e "TITLE2='R_{g}'" \
        -e "FILE3='./rmsd_protein.txt'" \
        -e "YLABEL3='RMSD (Angstrom)'" \
        -e "XLABEL3='Frame (10 ps frame^{-1})'" \
        -e "TITLE3='RMSD'" \
        -e "FILE4='./rmsf_protein_backbone.txt'" \
        -e "YLABEL4='RMSF (Angstrom)'" \
        -e "XLABEL4='Frame (10 ps frame^{-1})'" \
        -e "TITLE4='RMSF'" \
        $GNUPLOTTEMPLATE
