#!/usr/bin/env tclsh
#################################################################################
#   
#   File Name: 02-mutate.tcl
#   Created: Thu 22 May 2014 12:48:21 EST
#   Last Modified: Thu 22 May 2014 15:11:19 EST
#   Created By: Shane Gordon
#
################################################################################

# Input Details
set oprefix "change_me.1"
set iprefix "change_me.1"
set targetresname "P1"
set resid "change me"
set targetres "change me"

# Note: set check to make sure that length of both lists are equal!
cp $iprefix.pdb TEMP.pdb
cp $iprefix.psf TEMP.psf

set psf "TEMP.psf"
set pdb "TEMP.pdb"

# Makes sure that lists are of same length
set listlength [ llength $resid ]
set listlength2 [ llength $targetres ]
if { $listlength != $listlength2 } {
        puts ""
        puts "WARNING: Lists are not equal! Check number of residues entered."
        puts ""
        exit
}

package require mutator

for { set listitem 0 } { $listitem < $listlength } { incr listitem } {
        mutator -psf $psf -pdb $pdb -o TEMP.1 -ressegname $targetresname -resid [ lindex $resid $listitem ] -mut [ lindex $targetres $listitem ]
        mv TEMP.1.psf TEMP.psf
        mv TEMP.1.pdb TEMP.pdb
}

# Rename TEMP output files into the correct output names
mv TEMP.psf $oprefix.psf
mv TEMP.pdb $oprefix.pdb

# Should think of better check system
if { [file exists $oprefix.psf] == 1 } {
        puts ""
        puts "$oprefix.psf has been successfully created"
        puts ""
} elseif { [file exists $oprefix] == 0 } {
        puts "WHOOPS! Something went amiss. $oprefix has NOT been successfully created"
}
exit
