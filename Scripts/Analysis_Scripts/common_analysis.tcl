#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     common_analysis.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-18 20:31:02
# MODIFIED: 2015-06-19 17:13:51

# Common variables ----------------------------------------------------------- {{{

# Output directory for raw data files
set raw "raw_analysis_data"

# }}}

# ---------------------------------------------------------------------------- {{{

# read in raw data: 
puts " reading in reduced data set:"

proc dircheck { dirname } {
  if { [ file isdirectory $dirname ] } {
    file delete -force $dirname
    puts "Deleted $dirname"
  }
}

proc filecheck { filename } {
  if { [ file exists $filename ] } {
    file delete -force $filename
    puts "Deleted $filename"
  }
}

# If directory exists, blow it away and make a new one
# Else, make the directory
proc dir_make { dir } {
  if { [ file isdirectory $dir ] } {
    puts "Directory $dir already exists!"
  } else {
    file mkdir $dir
  }
}

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl
source ../Scripts/Tcl_Scripts/bigdcd.tcl

# }}}
 
# Variable definitions for later --------------------------------------------- {{{
set input_psf "no_water"
set seltext_protein "protein"
set seltext_backbone "protein and backbone"
set seltext_CA "protein and name CA"
set molid 0

# }}}
