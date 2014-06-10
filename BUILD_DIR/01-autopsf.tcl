#!/usr/bin/env tclsh
#################################################################################
#   
#   File Name: 01-autopsf.tcl
#   Created: Thu 22 May 2014 14:21:19 EST
#   Last Modified: Thu 22 May 2014 14:47:13 EST
#   Created By: Shane Gordon
#
################################################################################

# Loads PDB molecule from the Protein Data Base

set input "change_me"
set output "change_me"
set temp_prot "temp_${input}"
mol load pdb ${input}.pdb

#   Creates protein-only and lipid-only PDBs for segment building
################################################################################

#   Protein
set sel [atomselect top "protein and noh" frame 0]
$sel writepdb $temp_prot.pdb

#   PSFGEN part
################################################################################

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
