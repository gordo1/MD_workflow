#!/usr/bin/env python
# AUTHOR:   Shane Gordon
# FILE:     a1_other_analyses.py
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-16 21:46:32
# MODIFIED: 2015-06-16 22:11:29

import os
import sys
import logging
import argparse
import subprocess
import shutil
import time
import shlex

# Argparse
class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

parser=MyParser(description='Run CDPro automatically.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-v', '--verbose',  action="store_true",
        help="Increase verbosity")

result = parser.parse_args()

"""
If verbosity set, change logging to debug.
Else leave at info
"""
if result.verbose:
    logging.basicConfig(format='%(levelname)s:\t%(message)s', level=logging.DEBUG)
else:
    logging.basicConfig(format='%(levelname)s:\t%(message)s', level=logging.INFO)

def check_dir(dir):
    """
    Check whether directory dir exists.
    If true continue. Else exit.
    """
    if not os.path.isdir(dir):
        logging.error('Path %s not found', dir)
        logging.error('Aborting')
        sys.exit()

def check_file(file):
    """
    Check whether directory dir exists.
    If true continue. Else exit.
    """
    if not os.path.isfile(file):
        logging.error('Path %s not found', file)
        logging.error('Aborting')
        sys.exit()

def delete_dir(dir):
    """
    Check whether directory dir exists.
    If true delete and remake.
    """
    if os.path.exists(dir):
        shutil.rmtree(dir)
    os.makedirs(dir)

def check_cmd(cmd):
    try:
        subprocess.check_call(['%s' % cmd], shell=True)
    except subprocess.CalledProcessError:
        pass # handle errors in the called executable
    except OSError:
        logging.error('Command %s not found' % cmd)
        sys.exit()

def make_dir(dir):
    if not os.path.exists(dir):
        os.makedirs(dir)

cmds = ["vmd"]

for command in cmds:
    check_cmd(command)

dir_list = "../.dir_list.txt"
check_file(dir_list)

catdcd = "../Scripts/Tools/catdcd"
reduced = "no_water"

with open(dir_list) as f:
    for line in f:
        suffix = subprocess.check_output("echo %s | sed 's/.*_//' | sed 's/\.*//'" % (line), shell=True)
        subprocess.call("{1} -otype dcd -o no_water_{2}.dcd ${2}_temp_*.dcd".format(catdcd, suffix), shell=True)

# echo "Reading in data set..."
# echo "Writing reduced selection..."
# vmd -dispdev text -e ../Scripts/Analysis_Scripts/a2_create_dcd_no_H_or_H2O.tcl
# echo " Merging reduced data..."
