#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.sh
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:02:52
# MODIFIED: 2014-07-28 16:14:29

vmd -dispdev text -e ../Scripts/Analysis_Scripts/a5_other_analyses.tcl

# Some useful plots

GNUPLOTTEMPLATE="../Scripts/Gnuplot_Scripts/template.gpi"
gnuplot -e "FILE='./protein_sasa.txt'" -e "OUTPUT='./protein_sasa.pdf'" -e "YLABEL='SASA (Angstrom^{2})'" -e "XLABEL='Frame (10 ps frame^{-1})'" $GNUPLOTTEMPLATE
gnuplot -e "FILE='./protein_sasa_N.txt'" -e "OUTPUT='./protein_sasa_N.pdf'" -e "YLABEL='SASA (Angstrom^{2})'" -e "XLABEL='Frame (10 ps frame^{-1})'" $GNUPLOTTEMPLATE
gnuplot -e "FILE='./protein_sasa_C.txt'" -e "OUTPUT='./protein_sasa_C.pdf'" -e "YLABEL='SASA (Angstrom^{2})'" -e "XLABEL='Frame (10 ps frame^{-1})'" $GNUPLOTTEMPLATE
