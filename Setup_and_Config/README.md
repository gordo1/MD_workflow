# Notes for Setup_and_Config directory

This directory contains scripts to help set up and manage jobs on a large
cluster.

Molecular dynamics simulations can take advantage of large cluster systems by
launching either one large simulation or a large numer of smaller simulations
depending on the type of analysis required.

These scripts are primarily designed to help set up multiple NAMD jobs on the
BlueGene/Q but could be adapted for any program or system or used just for
single simulations.

The architecture is designed so as to run individual jobs under /MainJob_dir in
a directory structure based on /Setup_and_Config/JobTemplate By editing the sims
variable in the "master_config_file" one can specify how many jobs instances to
run  (from 1 to 999).

To create the job directories, simply run:

```sh
./create_job_directories
```

This will create incremented job directories copied from "/JobTemplate" as
specified in "master_config_file" with the "BaseDirName" variable Note: The
Jobtemplate can take any structure you like! The default scripts use this
particular structure to direct output.

Make sure to edit your optimization and production configuration files to point
to your structure input files and parameter files. (We use "sim_opt.conf" and
"sim_production.conf" as default files here).

Before you go further, often it is a good idea to *benchmark* your simulation so
you can get an idea of how well it runs on the system, and what optimal number
of cores and configuration should be used.  Change into the /Benchmarking
directory and follow the README there.

Once you have chosen the numbers of cores to use and made the appropriate
changes into the sbatch files make sure to populate your job directories with
your input files. Use:

```sh
./populate_config_files
```

You can also use this script to make bulk updates to your job directories on
the fly.

Occasionally you might want to create a new simulation directory but without the
existing data you already have.  You can do this easily with:

```sh
 ./clone_this_directory_without_data
```

This will clone your existing directory without most of the data, (but leaving
the BUILD_DIR intact) to:  temporary_cloned_md_workflow  which you can then
rename to something more appropriate.

In the top main directory there are scripts to start, stop and monitor all
simulations at once.  After you have created your directories and populated with
your files, you are ready to submit the jobs.  We do this one directory up under
the top directory. Change up to the top directory. To start your jobs use:

```sh
./start_and_initialize_all_jobs.sh
```

This is designed to initialize and start the jobs in each job directory.
Typically we start with the "sbatch_start" script which runs sim_opt.conf.  This
is usually an equilibration simulation before the production run. The end of the
equilibration job "sbatch_start" will start the production runs with
"sbatch_production"

If you need to stop all jobs use either:

```sh
./stop_all_jobs_gently.sh
```

or:

```sh
./stop_all_jobs_immediately.sh
```

The first option is preferable and allows the job to finish its current block,
which can be restarted at a later date.  The second will immediately stop the
job, but may leave untidy or corrupted data.

If jobs have crashed, it is possible to restart them with:

./restart_all_production_jobs.sh

This will check if jobs are running and restart them if possible.

There are more control options to be found in the README files in the top directory.
