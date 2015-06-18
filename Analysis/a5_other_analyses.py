#!/usr/bin/env python
# AUTHOR:   Shane Gordon
# FILE:     a1_other_analyses.py
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-16 21:46:32
# MODIFIED: 2015-06-18 19:34:03

import os
import sys
import logging
import argparse
import subprocess
import shutil
import time
import shlex
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import math
from scipy.optimize import curve_fit

# Argparse
class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

parser=MyParser(description="Batch analysis script. Takes output from a2 and \
		allows for interpretation of RMSD, RMSF, SASA, secondary structure and more.", 
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
        logging.debug("Directory {0} found.\nRemoving {0}".format(dir))
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

def command_catch_error(command):
	try:
		r = subprocess.Popen(command)
		r.wait()
	except OSError as e:
		logging.error(e)
		logging.error("failed")
		sys.exit()

# cmds = ["vmd -dispdev"]

# for command in cmds:
# 	check_cmd(command)

raw = "raw_analysis_data"
processed = "processed_analysis_data"
dir_list = "../.dir_list.txt"
gnuplot_t = "../Scripts/Gnuplot_Scripts/template_4plot.gpi"

# Checks
for d in [raw, processed]:
	delete_dir(d)
for f in [dir_list, gnuplot_t]:
	check_file(f)

# Run VMD analyses
try:
	r = subprocess.Popen(["vmd", "-dispdev", "text", "-e", "../Scripts/Analysis_Scripts/a5_other_analyses.tcl"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	r.wait()
	stdout, stderr = r.communicate()
except OSError as e:
	logging.error(e)
	logging.error("failed")
	sys.exit()
else:
	if stdout:
		if ("reading in reduced data set:" in stdout):
			logging.info("reading in reduced data set")
		if ("measure rmsf: specified frames are out of range") in stdout:
			logging.error("measure rmsf: specified frames are out of range")
			logging.error("This usually occurs because the number of frames in each chunk is too small")
	logging.info("VMD analyses done!")

# GNUplot
			# print("gnuplot -e \"OUTPUT='./sim_{0}_analysis.pdf'\" -e \"SECONDARYSTRUCTURE='{1}/SecondaryStructure_{0}/SecondaryStructure.dat'\" -e \"OUTPUT_ss='{0}/sim_{1}_ss.pdf'\" -e \"YLABEL1='Percent Structure'\" -e \"XLABEL1='Simulation Frame'\" -e \"TITLE1p1='Beta'\" -e \"TITLE1p2='Coil'\" -e \"TITLE1p3='Helix'\" -e \"TITLE1p4='Turn'\" -e \"FILE2='{1}/protein_radius_gyration_{0}.txt'\" -e \"OUTPUT_rg='{0}/sim_{1}_rg.pdf'\" -e \"YLABEL2='R_{{g}} ({{\305}})'\" -e \"XLABEL2='Simulation Frame'\" -e \"TITLE2='R_{{g}}'\" -e \"FILE3='{1}/rmsd_protein_{0}.txt'\" -e \"OUTPUT_rmsd='{0}/sim_{1}_rmsd.pdf'\" -e \"OUTPUT_rmsf='{0}/sim_{1}_rmsf.pdf'\" -e \"YLABEL3='RMSD ({{\305}})'\" -e \"XLABEL3='Simulation Frame'\" -e \"TITLE3='RMSD'\" -e \"YLABEL4='RMSF ({{\305}})'\" -e \"XLABEL4='Residue No'\" -e \"FILE5='{1}/protein_sasa_{0}.txt'\" -e \"OUTPUT_sasa='{0}/sim_{1}_sasa.pdf'\" -e \"YLABEL5='SASA (units)'\" -e \"XLABEL5='Simulation Frame'\" -e \"TITLE5='SASA'\" -e \"index_no='{0}'\" -e \"raw='{1}'\" {2}".format(i, out_d, gnuplot_t))
			# subprocess.Popen(["gnuplot -e \"OUTPUT='./sim_{0}_analysis.pdf'\" -e \"SECONDARYSTRUCTURE='{1}/SecondaryStructure_{0}/SecondaryStructure.dat'\" -e \"OUTPUT_ss='{0}/sim_{1}_ss.pdf'\" -e \"YLABEL1='Percent Structure'\" -e \"XLABEL1='Simulation Frame'\" -e \"TITLE1p1='Beta'\" -e \"TITLE1p2='Coil'\" -e \"TITLE1p3='Helix'\" -e \"TITLE1p4='Turn'\" -e \"FILE2='{1}/protein_radius_gyration_{0}.txt'\" -e \"OUTPUT_rg='{0}/sim_{1}_rg.pdf'\" -e \"YLABEL2='R_{{g}} ({{\305}})'\" -e \"XLABEL2='Simulation Frame'\" -e \"TITLE2='R_{{g}}'\" -e \"FILE3='{1}/rmsd_protein_{0}.txt'\" -e \"OUTPUT_rmsd='{0}/sim_{1}_rmsd.pdf'\" -e \"OUTPUT_rmsf='{0}/sim_{1}_rmsf.pdf'\" -e \"YLABEL3='RMSD ({{\305}})'\" -e \"XLABEL3='Simulation Frame'\" -e \"TITLE3='RMSD'\" -e \"YLABEL4='RMSF ({{\305}})'\" -e \"XLABEL4='Residue No'\" -e \"FILE5='{1}/protein_sasa_{0}.txt'\" -e \"OUTPUT_sasa='{0}/sim_{1}_sasa.pdf'\" -e \"YLABEL5='SASA (units)'\" -e \"XLABEL5='Simulation Frame'\" -e \"TITLE5='SASA'\" -e \"index_no='{0}'\" -e \"raw='{1}'\" {2}".format(i, out_d, gnuplot_t)], shell=True)

with open(dir_list) as f:
	for line in f:
		line = line.rstrip('\n')
		i = subprocess.check_output(
				"echo {0} | sed 's/.*_//' | sed 's/\.*//'".format(line),
				shell=True
				)
		i = i.replace('\n', '')
		out_d = "{0}/sim_{1}".format(processed, i)
		make_dir(out_d)
		try:
			rg_dict = {'Filename': '{0}/sim_{1}/protein_radius_gyration_{1}.txt'.format(raw, i), 
					'xlabel':	'Simulation time (ns)',
					'ylabel':	'R$_g$ ($\AA$)',
					'ymin'	:	0,
					'ofile'	:	'{0}/rg_plot_{1}'.format(out_d, i)}
			rmsd_dict = {'Filename': '{0}/sim_{1}/rmsd_protein_{1}.txt'.format(raw, i), 
					'xlabel':	'Simulation time (ns)',
					'ylabel':	'RMSD ($\AA$)',
					'ymin'	:	0,
					'ofile'	:	'{0}/rmsd_plot_{1}'.format(out_d, i)}
			rmsf_dict = {'Filename': '{0}/sim_{1}/rmsd_protein_{1}.txt'.format(raw, i), 
					'xlabel':	'Simulation time (ns)',
					'ylabel':	'RMSD ($\AA$)',
					'ymin'	:	0,
					'ofile'	:	'{0}/rmsd_plot_{1}'.format(out_d, i)}
			sasa_dict = {'Filename': '{0}/sim_{1}/protein_sasa_{1}.txt'.format(raw, i), 
					'xlabel':	'Simulation time (ns)',
					'ylabel':	'Solvent-accessible surface area ($\AA^2$)',
					'ymin'	:	0,
					'ofile'	:	'{0}/sasa_plot_{1}'.format(out_d, i)}

			for dict in [rg_dict, rmsd_dict]:
				data = np.loadtxt(dict['Filename'])
				
				# def func(x, A, kappa):
				# 	return A*np.exp(-1*kappa*x)

				# x = data[:,0]/10
				# y = data[:,1]

				# popt, pcov = curve_fit(func, x, y, p0=(0.01, 0.000001))

				# print(popt)

				# A = popt[1]
				# kappa = popt[0]
				# residuals = y - func(x, A, kappa)
				# fres = sum(residuals**2)

				# print(fres)

				ax = plt.subplot(111)
				ax.spines["top"].set_visible(False)
				ax.spines["right"].set_visible(False)
				ax.get_xaxis().tick_bottom()  
				ax.get_yaxis().tick_left()
				plt.xlabel('{0}'.format(dict['xlabel']), fontsize=16)
				plt.ylabel('{0}'.format(dict['ylabel']), fontsize=16)
				plt.xticks(fontsize=14)
				plt.yticks(fontsize=14)
				curve_y = func(x, A, kappa)
				plt.plot(data[:,0]/10, data[:,1,], lw=2)
				plt.plot(x, curve_y, ' ', lw=3)
				plt.ylim(dict['ymin'])
				ax.spines["top"].set_visible(False)
				plt.savefig('{0}.pdf'.format(dict['ofile']))
				plt.close()
		except OSError as e:
			logging.error(e)
