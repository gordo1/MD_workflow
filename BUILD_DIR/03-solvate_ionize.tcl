#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     03-solvate_ionize.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-05-22 15:25:22
# MODIFIED: 2015-01-08 11:03:51

# Instructions --------------------------------------------------------------- {{{

# Call this script using an external shell command:
#   vmd -e 03-solvate_ionize.tcl -args "input_prefix"
#   Replacing "input_prefix" with an appropriate value
#   Be sure to feed in only one arg!

# }}}

# Basic checks --------------------------------------------------------------- {{{

# Relative paths are evil
lappend auto_path ../Scripts/Tcl_Scripts
package require common_functions 1.0

# proc file_check { filename } {
#   if { [file exists $filename] == 0} {
#     puts "$filename not found. Is the input prefix wrong?"
#     exit
#   }
# }

if { $argc == 1 } {
  set input_prefix $argv
  file_check $input_prefix.pdb
  file_check $input_prefix.psf
} elseif { $argc == 0 } {
  puts "No arguments given!"
  exit
} elseif { $argc > 1 } {
  puts "Too many arguments"
  exit
}
}

# }}}

# Solvate -------------------------------------------------------------------- {{{

set psf "${input_prefix}.psf"
set pdb "${input_prefix}.pdb"
set rbddh "${input_prefix}_solvate"
source ./rhombicdodecahedron.tcl

# }}}

# Ionize --------------------------------------------------------------------- {{{

set iprefix "$rbddh"
set oprefix "${iprefix}_ionized"
set ionconc 0.15

package require autoionize
autoionize -psf $iprefix.psf -pdb $iprefix.pdb -sc $ionconc -o $oprefix

# }}}

exit
