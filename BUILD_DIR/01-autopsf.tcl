#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     01-autopsf.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-05-22 14:21:19
# MODIFIED: 2015-02-06 13:21:22

# Instructions --------------------------------------------------------------- {{{

# Call this script using an external shell command:
#   vmd -e 01-autops.tcl -args "PDB_input_prefix"
#   Replacing "PDB_input_prefix" with an appropriate value
#   Be sure to feed in only one arg!

# }}}
# Load PDB molecule from the Protein Data Base ------------------------------- {{{

set input "$argv"
set output "${input}.autopsf"
set temp_prot "temp_${input}"
mol load pdb ${input}.pdb

#  }}}
# Creates protein-only selection for segment building ------------------------ {{{

#   Protein
set sel [atomselect top "protein and noh" frame 0]
$sel writepdb $temp_prot.pdb

#  }}}
# PSFGEN part ---------------------------------------------------------------- {{{

# Renames isoleucine delta-carbon atom from CD1 to CD, as specified in
# topology file
package require psfgen
topology ../InputFiles/Parameters/top_all27_prot_lipid.rtf
pdbalias residue HIS HSE
pdbalias atom ILE CD1 CD
segment P1 {
        pdb ${temp_prot}.pdb
}
coordpdb ${temp_prot}.pdb P1
guesscoord
writepdb ${output}.pdb
writepsf ${output}.psf
resetpsf
file delete ${temp_prot}.pdb
file delete ${temp_prot}.psf
exit

# }}}
