#!/usr/bin/env python
# AUTHOR:   Shane Gordon
# FILE:     a1_other_analyses.py
# ROLE:     TODO (some explanation)
# CREATED:  2015-06-16 21:46:32
# MODIFIED: 2015-07-12 11:22:46

import os
import sys
import logging
import argparse
import subprocess
import shutil
import time
import shlex
import glob
import matplotlib
matplotlib.use('Agg')	# For non-interactive backends
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
parser.add_argument('--rmsd',  action="store_true", default=False,
        help="RMSD")
parser.add_argument('-s', '--selection', default='protein',
        help="""
        Protein selection to use in analyses. Must be a valid selection.
        At present, there are no explicit checks for making sure what you pass 
        is valid. Very fragile!
        """)
parser.add_argument('--rmsf',  action="store_true", default=False,
        help="""
        RMSF.
        """)
parser.add_argument('--sasa',  action="store_true", default=False,
        help="SASA")
parser.add_argument('--rg',  action="store_true", default=False,
        help="Rg")
parser.add_argument('--ss',  action="store_true", default=False,
        help="""
        Secondary structure scan using Stride.
        """)

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
analysis_script_dir = "../Scripts/Analysis_Scripts"

# Checks
for d in [raw, processed]:
    delete_dir(d)
    make_dir(d)
for f in [dir_list, gnuplot_t]:
    check_file(f)

# Run VMD analyses
analysis_dict = {
    "Common":   "{0}/analysis_common.tcl".format(analysis_script_dir),
    "RMSD"  :   "{0}/analysis_rmsdscan.tcl".format(analysis_script_dir),
    "RMSF"  :   "{0}/analysis_rmsfscan.tcl".format(analysis_script_dir),
    "SASA"  :   "{0}/analysis_sasa.tcl".format(analysis_script_dir),
    "Rg"    :   "{0}/analysis_rgscan.tcl".format(analysis_script_dir),
    "SS"    :   "{0}/analysis_secondarystructurescan.tcl".format(analysis_script_dir)
    }


l = result.selection.split()

if result.rmsd:
    try:
        r = subprocess.Popen(['vmd -dispdev text -e {script} -args \"\"{sel}\"\"'.format(
        	script = analysis_dict["RMSD"], 
        	sel = result.selection)], 
        	stdout=subprocess.PIPE, 
        	stderr=subprocess.PIPE, 
        	shell=True)
        r.wait()
        stdout, stderr = r.communicate()
    except OSError as e:
        logging.error(e)
        logging.error("failed")
        sys.exit()

if result.rmsf:
    try:
        r = subprocess.Popen(['vmd -dispdev text -e {script} -args \"\"{sel}\"\"'.format(
        	script = analysis_dict["RMSF"], 
        	sel = result.selection)], 
        	stdout=subprocess.PIPE, 
        	stderr=subprocess.PIPE, 
        	shell=True)
        r.wait()
        stdout, stderr = r.communicate()
    except OSError as e:
        logging.error(e)
        logging.error("failed")
        sys.exit()

# if result.rmsf:
#     try:
#         r = subprocess.Popen([
#             "vmd", "-dispdev", "text", "-e", 
#             analysis_dict["RMSF"]
#             ], stderr=subprocess.PIPE)
#         r.wait()
#         stdout, stderr = r.communicate()
#     except OSError as e:
#         logging.error(e)
#         logging.error("failed")
#         sys.exit()

if result.sasa:
    try:
        r = subprocess.Popen([
            "vmd", "-dispdev", "text", "-e", 
            analysis_dict["SASA"]
            ], stderr=subprocess.PIPE)
        r.wait()
        stdout, stderr = r.communicate()
    except OSError as e:
        logging.error(e)
        logging.error("failed")
        sys.exit()

if result.rg:
    try:
        r = subprocess.Popen([
            "vmd", "-dispdev", "text", "-e", 
            analysis_dict["Rg"]
            ], stderr=subprocess.PIPE)
        r.wait()
        stdout, stderr = r.communicate()
    except OSError as e:
        logging.error(e)
        logging.error("failed")
        sys.exit()

if result.ss:
    try:
        r = subprocess.Popen([
            "vmd", "-dispdev", "text", "-e", 
            analysis_dict["SS"]
            ], stderr=subprocess.PIPE)
        r.wait()
        stdout, stderr = r.communicate()
    except OSError as e:
        logging.error(e)
        logging.error("failed")
        sys.exit()

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
            rg_dict = {
                    'Filename': '{0}/sim_{1}/protein_radius_gyration_{1}.txt'.format(raw, i), 
                    'Result':   'result.rg',
                    'xlabel':   'Simulation time (ns)',
                    'ylabel':   'R$_g$ ($\AA$)',
                    'ymin'	:   0,
                    'ofile'	:   '{0}/rg_plot_{1}'.format(out_d, i)}
            rmsd_dict = {
                    'Filename': '{0}/sim_{1}/rmsd_protein_{1}.txt'.format(raw, i), 
                    'Result':   'result.rmsd',
                    'xlabel':   'Simulation time (ns)',
                    'ylabel':   'RMSD ($\AA$)',
                    'ymin'	:   0,
                    'ofile'	:   '{0}/rmsd_plot_{1}'.format(out_d, i)}
            rmsf_dict = {
                    'Filename': '{0}/sim_{1}/rmsf_protein_backbone_'.format(raw, i), 
                    'File_all': '{0}/sim_{1}/rmsf_all_protein_backbone'.format(raw, i), 
                    'Result':   'result.rmsf',
                    'xlabel':   'Residue No.',
                    'ylabel':   'RMSF ($\AA$)',
                    'ymin'	:   0,
                    'ymax'	:   10,
                    'ofile'	:   '{0}/rmsf_plot_{1}'.format(out_d, i)}
            sasa_dict = {
                    'Filename': '{0}/sim_{1}/protein_sasa_{1}.txt'.format(raw, i), 
                    'Result':   'result.sasa',
                    'xlabel':   'Simulation time (ns)',
                    'ylabel':   'Solvent-accessible surface area ($\AA^2$)',
                    'ymin'	:   0,
                    'ofile'	:   '{0}/sasa_plot_{1}'.format(out_d, i)}
            ss_dict = {
                    'Filename_helix': '{0}/sim_{1}/SecondaryStructure/helixPercent.plt'.format(raw, i), 
                    'Filename_beta': '{0}/sim_{1}/SecondaryStructure/betaPercent.plt'.format(raw, i), 
                    'Filename_coil': '{0}/sim_{1}/SecondaryStructure/coilPercent.plt'.format(raw, i), 
                    'Filename_turn': '{0}/sim_{1}/SecondaryStructure/turnPercent.plt'.format(raw, i), 
                    'Result':   'result.ss',
                    'xlabel':   'Simulation time (ns)',
                    'ylabel':   'Proportion Secondary Structure',
                    'ymin'	:   0,
                    'ofile'	:   '{0}/ss_plot_{1}'.format(out_d, i)}

            for dict in [ss_dict]:
                """
                Making an assumption here that if the helix file exists, the
                others do as well. This is very fragile and could easily be
                improved, but I don't care enough right now
                """
                if os.path.isfile(dict['Filename_helix']):
                    data_h = np.loadtxt(dict['Filename_helix'])
                    data_b = np.loadtxt(dict['Filename_beta'])
                    data_c = np.loadtxt(dict['Filename_coil'])
                    data_t = np.loadtxt(dict['Filename_turn'])
                    # Row-wise read in ss elements into array ss
                    ss = np.row_stack([data_h, data_b, data_c, data_t])
                    # Dummy Y-data for plotting
                    y = np.arange(len(ss[1]))
                    # Use more appropriate RGBY colour palette
                    plt.rc('axes', color_cycle=['r', 'g', 'b', 'y'])
                    ax = plt.subplot(111)
                    ax.spines["top"].set_visible(False)
                    ax.spines["right"].set_visible(False)
                    ax.get_xaxis().tick_bottom()  
                    ax.get_yaxis().tick_left()
                    plt.xlabel('{0}'.format(dict['xlabel']), fontsize=16)
                    plt.ylabel('{0}'.format(dict['ylabel']), fontsize=16)
                    plt.xticks(fontsize=14)
                    plt.yticks(fontsize=14)
                    plt.stackplot(y, ss, lw=0.1, alpha=0.7)
                    # Hack to give labels for ss elements
                    plt.plot([], [], color='r', alpha=0.5, lw=10,label='helix')
                    plt.plot([], [], color='b', alpha=0.7, linewidth=10,label='coil')
                    plt.plot([], [], color='y', alpha=0.7, linewidth=10,label='turn')
                    plt.plot([], [], color='g', alpha=0.7, linewidth=10,label='strand')
                    # Legend
                    legend = ax.legend(loc='right', shadow=True)
                    legend.get_frame().set_facecolor('white')
                    # Y limits
                    plt.ylim(dict['ymin'])
                    ax.spines["top"].set_visible(False)
                    # Write the file out
                    plt.savefig('{0}.pdf'.format(dict['ofile']))
                    plt.close()

            for dict in [rmsd_dict, sasa_dict, rg_dict]:
                if os.path.isfile(dict['Filename']):
                    data = np.loadtxt(dict['Filename'])
                    ax = plt.subplot(111)
                    ax.spines["top"].set_visible(False)
                    ax.spines["right"].set_visible(False)
                    ax.get_xaxis().tick_bottom()  
                    ax.get_yaxis().tick_left()
                    plt.xlabel('{0}'.format(dict['xlabel']), fontsize=16)
                    plt.ylabel('{0}'.format(dict['ylabel']), fontsize=16)
                    plt.xticks(fontsize=14)
                    plt.yticks(fontsize=14)
                    plt.plot(data[:,0]/10, data[:,1,], lw=2)
                    # Y limits
                    plt.ylim(dict['ymin'])
                    ax.spines["top"].set_visible(False)
                    # Write the file out
                    plt.savefig('{0}.pdf'.format(dict['ofile']))
                    plt.close()

            for dict in [rmsf_dict]:
                if glob.glob('{0}*'.format(dict['Filename'])):
                    a = []
                    for rmsf_file in sorted(glob.glob('{0}*'.format(dict['Filename']))):
                        a.append(rmsf_file)
                    n = 5
                    count = 1
                    color=iter(plt.cm.Blues(np.linspace(0,1,n)))
                    for fname in a:
                        if os.path.isfile(fname):
                            c=next(color)
                            oname = os.path.splitext(fname)[0]
                            data = np.loadtxt('{0}.txt'.format(oname))
                            path, prefix = os.path.split('{0}.txt'.format(oname))
                            ax = plt.subplot(111)
                            plt.plot(data[:,0], data[:,1,], lw=1, c=c,
                                    label='Fraction {0} of 5'.format(count))
                            count = count + 1
                    if glob.glob('{0}*'.format(dict['File_all'])):
                    	b = []
                    	for rmsf_file in glob.glob('{0}*'.format(dict['File_all'])):
                    		b.append(rmsf_file)
                    	for fname in b:
							if os.path.isfile(fname):
								oname = os.path.splitext(fname)[0]
								data = np.loadtxt('{0}.txt'.format(oname))
								path, prefix = os.path.split('{0}.txt'.format(oname))
								ax = plt.subplot(111)
								plt.plot(data[:,0], data[:,1,], lw=1, c='r',
                                    label='All')
                    plt.xlabel('{0}'.format(dict['xlabel']), fontsize=16)
                    plt.ylabel('{0}'.format(dict['ylabel']), fontsize=16)
                    ax.get_xaxis().tick_bottom()  
                    ax.get_yaxis().tick_left()
                    ax.spines["top"].set_visible(False)
                    ax.spines["right"].set_visible(False)
                    plt.xticks(fontsize=14)
                    plt.yticks(fontsize=14)
                    legend = ax.legend(loc='upper left', shadow=True)
                    for label in legend.get_texts():
                        label.set_fontsize('small')
                    for label in legend.get_lines():
                        label.set_linewidth(1)
                    plt.ylim(dict['ymin'], dict['ymax'])
                    plt.savefig('{0}/rmsf.pdf'.format(out_d))
                    plt.close()
        except OSError as e:
            logging.error(e)
