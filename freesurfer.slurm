#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-55
#SBATCH --time=0-23:59:55
#SBATCH --mail-user=martin.saintjalmes@student.unimelb.edu.au
#SBATCH --mail-type=ALL

# Retrieve BIDS_ROOT as $1
BIDS_ROOT=$1

# Load required modules
module load foss/2019b
module load freesurfer/6.0.1-centos6_x86_64

# Set ENV variables
export PATH=/usr/local/easybuild-2019/easybuild/software/core/freesurfer/6.0.1-centos6_x86_64/mni/bin:$PATH
export SUBJECTS_DIR=$PWD/$BIDS_ROOT/derivatives/freesurfer/

# Cleanup previous FS computation
# rm -rf ./derivatives/freesurfer/* # don't do this in parallel

# execute line
sed -n ${SLURM_ARRAY_TASK_ID}p $BIDS_ROOT/.tmp/commands.list | bash
