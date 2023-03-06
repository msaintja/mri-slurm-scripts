#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=24G
#SBATCH --array=1-932
#SBATCH --time=0-1:00:00
#SBATCH --mail-user=martin.saintjalmes@student.unimelb.edu.au
#SBATCH --mail-type=ALL

# Load Python
module load gcccore/8.3.0
module load python/3.7.4

# Load xvfb
module load xvfb/1.20.8

# Load singularity
module load singularity/3.5.3


# Activate pre-installed virtualenv
# pre-ran: module load gcccore/8.3.0 python/3.7.4; virtualenv ~/venvs/3.8.6; source ~/venvs/mriqc/bin/activate; pip install mriqc
# Install mriqc package in virtualenv -- https://dashboard.hpc.unimelb.edu.au/software/python/
source ~/venvs/mriqc/bin/activate

# Load required modules
# https://mriqc.readthedocs.io/en/latest/install.html
module load foss/2019b
module load ants/2.3.2-python-3.7.4
module load fsl/6.0.1-python-3.7.4
module load afni/22.0.06-python-3.7.4

# Set ENV variables
export FREESURFER_HOME=/data/gpfs/projects/punim1484/msaintjalmes/fs_synthstrip/


# mkdir ./derivatives/mriqc -p


#####
# Ants 2.3.2 as provided by Spartan has an issue where antsRegistration --version yields an empty string
# Manually patch this in /home/msaintjalmes/venvs/mriqc/lib/python3.7/site-packages/nipype/interfaces/ants/base.py
            # if line.startswith("ANTs Version: "):
            #     v_string = line.split()[2]
            #     break
# Replace with:
            # if line.startswith("ANTs Version: "):
            #     try:
            #         v_string = line.split()[2]
            #     except:
            #         v_string = "2.3.2"
            #     break
####

# Disable

# execute line
sed -n ${SLURM_ARRAY_TASK_ID}p OASIS3-BIDS-first/.tmp/commands-mriqc.list | bash
