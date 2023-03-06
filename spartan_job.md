#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-1083
#SBATCH --time=0-12:00:00

# Load required modules
module load foss/2019b
module load freesurfer/6.0.1-centos6_x86_64
module load ants/2.3.2-python-3.7.4
module load fsl/6.0.1-python-3.7.4
module load python/3.7.4
module load perl/5.32.0


sinteractive -p interactive --time=0-48:00:00 --nodes=1 --ntasks=1



# /data/gpfs/projects/punim1484/msaintjalmes/

export SUBJECTS_DIR=/data/gpfs/projects/punim1484/msaintjalmes/OASIS3-BIDS-first/derivatives/freesurfer/
mkdir ./.tmp -p
truncate -s 0 ./.tmp/commands.list
for subject_img in $(find ./ -name 'sub*nii.gz'); do
echo "recon-all -all -i $subject_img -s $(awk -F / '{ print $2; }' <<< $subject_img) -qcache" >> ./.tmp/commands.list; done
parallel --bar --jobs 3 :::: ./.tmp/commands.list





sinteractive -p interactive --time=00:15:00 --nodes=1 --ntasks=1

module load foss/2019b
module load freesurfer/6.0.1-centos6_x86_64

export PATH=/usr/local/easybuild-2019/easybuild/software/core/freesurfer/6.0.1-centos6_x86_64/mni/bin:$PATH
export SUBJECTS_DIR=/data/gpfs/projects/punim1484/msaintjalmes/OASIS3-subset/OASIS-BIDS-converted/derivatives/freesurfer/
mkdir ./.tmp -p
truncate -s 0 ./.tmp/commands.list
for subject_img in $(find ./ -name 'sub*nii.gz'); do
echo "recon-all -all -i $subject_img -s $(awk -F / '{ print $2; }' <<< $subject_img) -qcache" >> ./.tmp/commands.list; done
parallel --bar --jobs 3 :::: ./.tmp/commands.list





# 40768240
# 40776113


#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-3
#SBATCH --time=0-12:00:00


# Load required modules
module load foss/2019b
module load freesurfer/6.0.1-centos6_x86_64

# Set ENV variables
export PATH=/usr/local/easybuild-2019/easybuild/software/core/freesurfer/6.0.1-centos6_x86_64/mni/bin:$PATH
export SUBJECTS_DIR=/data/gpfs/projects/punim1484/msaintjalmes/OASIS3-subset/OASIS-BIDS-converted/derivatives/freesurfer/

# Cleanup previous FS computation
rm -rf ./derivatives/freesurfer/*

# execute line
sed -n ${SLURM_ARRAY_TASK_ID}p | bash 


# Find jobs that died because of time limit:

grep -H "DUE TO TIME LIMIT" OASIS3-BIDS-first/slurm-40768240_*.out