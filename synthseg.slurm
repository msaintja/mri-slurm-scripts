#!/bin/bash
#SBATCH -p gpu-a100
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=24G
#SBATCH --array=1-931:10
#SBATCH --time=0-2:00:00
#SBATCH --mail-user=martin.saintjalmes@student.unimelb.edu.au
#SBATCH --mail-type=ALL

# Retrieve BIDS_ROOT as $1
BIDS_ROOT=$1

# Load required modules
module load fosscuda/2020b cuda/10.1.243 cudnn/7.6.4.38-cuda-10.1.243 python/3.8.6 # requires keras<2.4.0 & tensorflow<2.3.0

# Activate pre-installed virtualenv
# pre-ran: module load module load gcccore/10.2.0 python/3.8.6; virtualenv ~/venvs/synthseg; source ~/venvs/synthseg/bin/activate; pip install -r requirements_python3.8.txt 
source ~/venvs/synthseg/bin/activate

# # Explicitly specify where to find PTXAS for cuda 10.1 in PATH
# export PATH=/usr/local/easybuild-2019/easybuild/software/core/cuda/10.1.243/bin:$PATH

# execute line

for i in {0..9}; do
    if [ $((SLURM_ARRAY_TASK_ID+i)) -le 931 ]
    then
        sed -n $((SLURM_ARRAY_TASK_ID+i))p $BIDS_ROOT/.tmp/commands-synthseg.list | bash;
        current_date_time="`date "+%Y-%m-%d %H:%M:%S"`";
        echo $current_date_time;
        wait; 
    fi
done