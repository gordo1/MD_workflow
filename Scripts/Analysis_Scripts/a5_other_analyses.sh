#!/usr/bin/env bash
# AUTHOR:   Shane Gordon
# FILE:     a5_other_analyses.sh
# ROLE:     TODO (some explanation)
# CREATED:  2014-06-03 22:02:52
# MODIFIED: 2015-05-12 10:43:36

# Common variables ----------------------------------------------------------- {{{

raw="raw_analysis_data"

# }}}

# Folder checks -------------------------------------------------------------- {{{

# Check whether folder "raw_analysis" exists. Blow away if it does.
if [[ -d "./$raw" ]]; then
  rm -r "./$raw" && mkdir -p "./$raw"
else
  mkdir -p "./$raw"
fi

# }}}

# VMD analyses --------------------------------------------------------------- {{{

vmd -dispdev text -e ../Scripts/Analysis_Scripts/a5_other_analyses.tcl

# }}}

# GNUplot'ing ---------------------------------------------------------------- {{{

y=$(cat ../.dir_list.txt) 
for i in $y
do
  
  index_no=`echo $i | sed 's/.*_//' | sed 's/\.*//'`

  out_dir="${raw}/sim_${index_no}"

  [[ -d "./$out_dir/SecondaryStructure_${index_no}" ]] &&\
    paste ./$out_dir/SecondaryStructure_${index_no}/* > ./$out_dir/SecondaryStructure_${index_no}/SecondaryStructure.dat

  GNUPLOTTEMPLATE="../Scripts/Gnuplot_Scripts/template_4plot.gpi"
  gnuplot -e "OUTPUT='./sim_${index_no}_analysis.pdf'" \
    -e "SECONDARYSTRUCTURE='${out_dir}/SecondaryStructure_${index_no}/SecondaryStructure.dat'" \
    -e "YLABEL1='Percent Structure'" \
    -e "XLABEL1='Simulation Frame'" \
    -e "TITLE1p1='Beta'" \
    -e "TITLE1p2='Coil'" \
    -e "TITLE1p3='Helix'" \
    -e "TITLE1p4='Turn'" \
    -e "FILE2='${out_dir}/protein_radius_gyration_${index_no}.txt'" \
    -e "YLABEL2='R_{g} (\305)'" \
    -e "XLABEL2='Simulation Frame'" \
    -e "TITLE2='R_{g}'" \
    -e "FILE3='${out_dir}/rmsd_protein_${index_no}.txt'" \
    -e "YLABEL3='RMSD (A)'" \
    -e "XLABEL3='Simulation Frame'" \
    -e "TITLE3='RMSD'" \
    -e "YLABEL4='RMSF (A)'" \
    -e "XLABEL4='Residue No'" \
    -e "FILE5='${out_dir}/protein_sasa_${index_no}.txt'" \
    -e "YLABEL5='SASA (units)'" \
    -e "XLABEL5='Simulation Frame'" \
    -e "TITLE5='SASA'" \
    -e "index_no='$index_no'" \
    -e "raw='$out_dir'" \
    $GNUPLOTTEMPLATE
done

# }}}
