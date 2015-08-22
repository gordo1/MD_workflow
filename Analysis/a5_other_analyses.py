#!/usr/bin/env python
# AUTHOR:	Shane Gordon
# FILE:		a1_other_analyses.py
# ROLE:		TODO (some explanation)
# CREATED:	2015-06-16 21:46:32
# MODIFIED: 2015-07-26 16:44:27

# PREAMBLE ------------------------------------------------------------------- {{{

import os
import sys
import logging
import argparse
import subprocess
import shutil
import time
import shlex
from glob import glob
import matplotlib
matplotlib.use('Agg')	# For non-interactive backends
import matplotlib.pyplot as plt
import numpy as np
import math
from scipy.optimize import curve_fit

# Matplotlib formatting bits
def init_plotting():
	plt.rcParams['figure.figsize'] = (8, 3)
	plt.rcParams['figure.autolayout'] = True
	plt.rcParams['axes.linewidth'] = 1
	plt.rcParams['xtick.major.width'] = 1
	plt.rcParams['ytick.major.width'] = 1
	plt.rcParams['xtick.direction'] = 'in'
	plt.rcParams['ytick.direction'] = 'in'
	plt.rcParams['xtick.major.size'] = 3
	plt.rcParams['xtick.minor.size'] = 3
	plt.rcParams['ytick.major.size'] = 3
	plt.rcParams['ytick.minor.size'] = 3
	plt.rcParams['xtick.labelsize'] = 10
	plt.rcParams['ytick.labelsize'] = 10
	plt.rcParams['font.sans-serif'] = 'Arial'
	plt.rcParams['axes.labelsize'] = 12
	plt.rcParams['lines.linewidth'] = 0.5
	plt.rcParams['legend.loc'] = 'center right'
	plt.gca().spines['right'].set_color('none')
	plt.gca().spines['top'].set_color('none')
	plt.gca().xaxis.set_ticks_position('bottom')
	plt.gca().yaxis.set_ticks_position('left')

init_plotting()

# }}}

# Argparse
# Convenient argument manager for python scripts
# Optional arguments (should) have sane defaults
# Allows for choice of rmsf, rmsd, sasa, secondary structure, residue-based
# sasa, etc analysis.
class MyParser(argparse.ArgumentParser):
	def error(self, message):
		sys.stderr.write('error: %s\n' % message)
		self.print_help()
		sys.exit(2)

parser=MyParser(description="Batch analysis script. Takes output from a2 and \
		allows for interpretation of RMSD, RMSF, SASA, secondary structure and \
		more.", 
		formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-v', '--verbose',	action="store_true",
		help="Increase verbosity")
parser.add_argument('--rmsd',  action="store_true", default=False,
		help="RMSD")
parser.add_argument('-s', '--selection', default='protein',
		help="""
		Protein selection to use in analyses. Must be a valid selection.
		At present, there are no explicit checks for making sure what you pass 
		is valid. Very fragile!
		""")
parser.add_argument('-as', '--align_sel', default='protein and name CA',
		help="""
		Optional selection to use for protein alignment, if applicable.
		Currently there are no sanity checks for this, so assume that it is
		very fragile. Syntax documentation for VMD selections can be found
		here:
		ks.uiuc.edu/Research/vmd/vmd-1.2/ug/vmdug_node137.html
		""")
parser.add_argument('--rmsf',  action="store_true", default=False,
		help="""
		RMSF.
		""")
parser.add_argument('--sasa',  action="store_true", default=False,
		help="SASA")
parser.add_argument('--rsasa',	action="store_true", default=False,
		help="Residue-level SASA")
parser.add_argument('--rg',  action="store_true", default=False,
		help="Rg")
parser.add_argument('--dccm',  action="store_true", default=False,
		help="dccm")
parser.add_argument('--ss',  action="store_true", default=False,
		help="""
		Secondary structure scan using Stride.
		""")

# Argument strings are accessed through the argparser 'result'
result = parser.parse_args()

# Logger-control of feed-out
# Normal output is prescribed to info
# Debug output (accessed through -v/--verbose) is prescribed to debug
"""
If verbosity set, change logging to debug.
Else leave at info
"""
if result.verbose:
	logging.basicConfig(format='%(levelname)s:\t%(message)s',
			level=logging.DEBUG)
else:
	logging.basicConfig(format='%(levelname)s:\t%(message)s',
			level=logging.INFO)

# SUBROUTINES ---------------------------------------------------------------- {{{
# workings are described within
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
	"""
	If directory does not exist, make it
	"""
	if not os.path.exists(dir):
		os.makedirs(dir)

def command_catch_error(command):
	"""
	Wrapper for shell commands. Stdin/stdout returned.
	"""
	try:
		p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE,
				stderr=subprocess.STDOUT)
		p.wait()
		return p.communicate()
	except OSError as e:
		"""
		If this fails, report the error.
		"""
		logging.error(e)
		logging.error("Command {com} failed. Please troubleshoot this and try \
				again")
		sys.exit()

def get_dirs(dirlist):
	i_list = []
	with open(dirlist) as f:
		for line in f:
			line = line.rstrip('\n')
			i = subprocess.check_output(
				"echo {0} | sed 's/.*_//' | sed 's/\.*//'".format(line),
				shell=True)
			i = i.replace('\n', '')
			i_list.append(i)
	return i_list


def basic_plot(proc):
	if os.path.isfile(proc['fname']):
		data = np.loadtxt(proc['fname'])
		ax = plt.subplot(111)
		plt.xlabel(proc['xlabel'])
		plt.ylabel(proc['ylabel'])
		plt.plot(data[:,0]/10, data[:,1,], lw=2)
		plt.ylim(proc['ymin'])
		plt.savefig('{ofile}.pdf'.format(ofile = proc['ofile']))
		plt.close()

def rmsf_shared_axis(d):
	if glob('{fn}*'.format(fn=d['fname'])):
		a = [i for i in sorted(glob('{fn}*'.format(fn=d['fname'])))]
		n = len(a)
		count = 1
		color=iter(plt.cm.Blues(np.linspace(0,1,n)))
		for f in a:
			if os.path.isfile(f):
				c=next(color)
				o = os.path.splitext(f)[0]
				data = np.loadtxt('{o}.txt'.format(o=o))
				path, prefix = os.path.split('{o}.txt'.format(o=o))
				ax = plt.subplot(111)
				plt.plot(data[:,0], data[:,1,], c=c,
						label='Fraction {count} of 5'.format(count=count))
				count = count+1
		if glob('{fn}*'.format(fn=d['all_avg'])):
			if os.path.isfile(f):
				o = os.path.splitext(f)[0]
				data = np.loadtxt('{o}.txt'.format(o=o))
				path, prefix = os.path.split('{oprefix}.txt'.format(oprefix=o))
				ax = plt.subplot(111) 
				plt.plot(data[:,0], data[:,1,], c='r', label='All')
		legend = ax.legend(loc='upper left')
		for label in legend.get_texts(): label.set_fontsize('small')
		for label in legend.get_lines(): label.set_linewidth(1)
		plt.xlabel('{label}'.format(label=d['xlabel']))
		plt.ylabel('{label}'.format(label=d['ylabel']))
		plt.ylim(d['ymin'], d['ymax'])
		plt.savefig('{oprefix}/rmsf.pdf'.format(oprefix=out_d))
		plt.close()

# }}}

# COMMUNAL VARIABLES --------------------------------------------------------- {{{

# Directory where raw data is placed, if generated
raw = "raw"

# Directory where processed (plotted) data is placed, if generated by 
# matplotlib
processed = "plots"

# File containing a list of simulation replicates. We use this to work out how
# many times other subroutines need to run. This could be better.
dir_list = "../.dir_list.txt"

# Path to directory containing VMD tcl scripts we need to use later
script_dir = "../Scripts/Analysis_Scripts"

# shell command to call vmd in CLI mode
vmd_cmd = 'vmd -dispdev text'

# }}}

# Run VMD analyses
res = {
	result.rmsd : "{0}/analysis_rmsd.tcl".format(script_dir),
	result.rmsf : "{0}/analysis_rmsf.tcl".format(script_dir),
	result.sasa : "{0}/analysis_sasa.tcl".format(script_dir),
	result.rsasa : "{0}/analysis_rsasa.tcl".format(script_dir),
	result.rg : "{0}/analysis_rg.tcl".format(script_dir),
	result.dccm : "{0}/analysis_dccm.tcl".format(script_dir),
	result.ss : "{0}/analysis_ss.tcl".format(script_dir)
	}

l = result.selection.split()
i_list = get_dirs(dir_list)

# Checks
for f in [dir_list]:
	check_file(f)
for dir in [raw, processed]:
	logging.info(dir)
	make_dir(dir)
	for replicate in i_list:
		d = "{0}/sim_{1}".format(dir, replicate)
		make_dir(d)

for r, a in res.iteritems():
	if r == True:
		for replicate in i_list:
			c = command_catch_error(
			'{vmd} -e {script} -args no_water_{rep}.dcd {raw} {align_sel}'.format(
						vmd=vmd_cmd,
						script=a, 
						rep=replicate,
						raw=raw, 
						align_sel = result.align_sel))

for replicate in i_list:
	out_d = "{0}/sim_{1}".format(processed, replicate)
	try:
		rg_dict = {
				'fname' :
				'{0}/sim_{1}/protein_radius_gyration_{1}.txt'.format(
					raw, replicate), 
				'xlabel' : 'Simulation time (ns)',
				'ylabel' : 'R$_g$ ($\AA$)',
				'ymin' : 0,
				'ofile'	: '{0}/rg_plot_{1}'.format(out_d, replicate)}
		rmsd_dict = {
				'fname':
				'{0}/sim_{1}/rmsd_protein_{1}.txt'.format(raw, replicate), 
				'xlabel' : 'Simulation time (ns)',
				'ylabel' : 'RMSD ($\AA$)',
				'ymin' : 0,
				'ofile' : '{0}/rmsd_plot_{1}'.format(out_d, replicate)}
		rmsf_dict = {
				'fname': 
				'{0}/sim_{1}/rmsf_protein_backbone_'.format(raw, replicate), 
				'all_avg':
				'{0}/sim_{1}/rmsf_all_protein_backbone'.format(raw, replicate), 
				'xlabel':	'Residue No.',
				'ylabel':	'RMSF ($\AA$)',
				'ymin'	:	0,
				'ymax'	:	10,
				'ofile'	:	'{0}/rmsf_plot_{1}'.format(out_d, replicate)}
		sasa_dict = {
				'fname': 
				'{0}/sim_{1}/protein_sasa_{1}.txt'.format(raw, replicate), 
				'xlabel':	'Simulation time (ns)',
				'ylabel':	'Solvent-accessible surface area ($\AA^2$)',
				'ymin'	:	0,
				'ofile'	:	'{0}/sasa_plot_{1}'.format(out_d, replicate)}
		rsasa_dict = {
				'fname':
				'{0}/sim_{1}/protein_sasa_{1}.txt'.format(raw, replicate), 
				'xlabel':	'Simulation time (ns)',
				'ylabel':	'Solvent-accessible surface area ($\AA^2$)',
				'ymin'	:	0,
				'ofile'	:	'{0}/sasa_plot_{1}'.format(out_d, replicate)}
		ss_dict = {
				'fname_helix':
				'{0}/sim_{1}/SecondaryStructure/helixPercent.plt'.format(
					raw, replicate), 
				'fname_beta':
				'{0}/sim_{1}/SecondaryStructure/betaPercent.plt'.format(
					raw, replicate), 
				'fname_coil':
				'{0}/sim_{1}/SecondaryStructure/coilPercent.plt'.format(
					raw, replicate), 
				'fname_turn':
				'{0}/sim_{1}/SecondaryStructure/turnPercent.plt'.format(
					raw, replicate), 
				'xlabel':	'Simulation time (ns)',
				'ylabel':	'Proportion Secondary Structure',
				'ymin'	:	0,
				'ofile'	:	'{0}/ss_plot_{1}'.format(out_d, replicate)}

		for dict in [ss_dict]:
			"""
			Making an assumption here that if the helix file exists, the
			others do as well. This is very fragile and could easily be
			improved, but I don't care enough right now
			"""
			if os.path.isfile(dict['fname_helix']):
				data_h = np.loadtxt(dict['fname_helix'])
				data_b = np.loadtxt(dict['fname_beta'])
				data_c = np.loadtxt(dict['fname_coil'])
				data_t = np.loadtxt(dict['fname_turn'])
				# Row-wise read in ss elements into array ss
				ss = np.row_stack([data_h, data_b, data_c, data_t])
				# Dummy Y-data for plotting
				y = np.arange(len(ss[1]))
				# Use more appropriate RGBY colour palette
				ax = plt.subplot(111)
				plt.xlabel('{label}'.format(label=dict['xlabel']))
				plt.ylabel('{label}'.format(label=dict['ylabel']))
				plt.stackplot(y, ss, lw=0.1, alpha=0.7)
				# Hack to give labels for ss elements
				plt.plot([], [], color='r', alpha=0.5, 
						w=10, label='helix')
				plt.plot([], [], color='b', alpha=0.7,
						linewidth=10, label='coil')
				plt.plot([], [], color='y', alpha=0.7,
						linewidth=10, label='turn')
				plt.plot([], [], color='g', alpha=0.7,
						linewidth=10, label='strand')
				# Legend
				legend.get_frame().set_facecolor('white')
				# Y limits
				plt.ylim(dict['ymin'])
				# Write the file out
				plt.savefig('{0}.pdf'.format(dict['ofile']))
				plt.close()

		# If true, plot rmsd, sasa, and radius of gyrations data
		for p in [rmsd_dict, sasa_dict, rg_dict]: basic_plot(p)

		# For each replicate, plot fractional rmsf values and total rmsf values
		rmsf_shared_axis(rmsf_dict)

	except OSError as e:
		logging.error(e)
