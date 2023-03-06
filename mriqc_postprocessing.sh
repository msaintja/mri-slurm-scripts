#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=0-00:30:00
#SBATCH --mail-user=martin.saintjalmes@student.unimelb.edu.au
#SBATCH --mail-type=ALL

# Retrieve BIDS_ROOT as $1
BIDS_ROOT=$1

# Load Python
module load gcccore/8.3.0
module load python/3.7.4

# Load xvfb
module load xvfb/1.20.8

# Load singularity
module load singularity/3.5.3

# Set ENV variables
export FREESURFER_HOME=/data/gpfs/projects/punim1484/msaintjalmes/fs_synthstrip/

# clean up previous temporary folder
rm -rf $BIDS_ROOT-tmp

# run group-level analysis after mriqc individual-level analysis (dispatched in parallel)
singularity run -e mriqc-0.15.2rc1.simg $BIDS_ROOT $BIDS_ROOT/derivatives/mriqc group --no-sub --verbose --work-dir /tmp

# Obtain classifier predictions to exclude scans as mclf_run*.csv
cd $BIDS_ROOT/derivatives/mriqc
singularity exec -e ../../../mriqc-0.15.2rc1.simg mriqc_clf --verbose --load-classifier -X group_T1w.tsv


