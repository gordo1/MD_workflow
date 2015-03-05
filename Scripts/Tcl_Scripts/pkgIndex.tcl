#!/usr/bin/env tclsh
# AUTHOR:   Shane Gordon
# FILE:     pkgIndex.tcl
# ROLE:     TODO (some explanation)
# CREATED:  2015-01-08 10:32:44
# MODIFIED: 2015-01-08 10:53:53

package provide common_functions 1.0

namespace eval ::common_functions {
  namespace export file_check
}

proc file_check { filename } {
  if { [file exists $filename] == 0} {
    puts "\n$filename not found. You must have made a mistake somewhere\n"
    exit
  }
}
