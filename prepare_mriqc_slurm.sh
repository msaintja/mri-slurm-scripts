#!/bin/bash

mkdir $1/.tmp -p
truncate -s 0 $1/.tmp/commands-mriqc.list
for subject_img in $(find $1/ -name 'sub*nii.gz' | awk -F / '{ print $2; }'); do
echo "singularity run -e mriqc-0.15.2rc1.simg $1 $1-tmp participant --participant-label $(awk -F - '{ print $2; }' <<< $subject_img) --no-sub --verbose --nprocs 1 --work-dir /tmp && mv -v $1-tmp/$subject_img $1/derivatives/mriqc/ && mv -v $1-tmp/$subject_img* $1/derivatives/mriqc/" >> $1/.tmp/commands-mriqc.list; done

# Ensure that MRIQC and tmporary directory exist, and that they are empty
mkdir $1/derivatives/mriqc -p
rm -rf $1/derivatives/mriqc/*

mkdir $1-tmp -p
rm -rf $1-tmp/*

# Prepare save location for synthstrip model
mkdir /data/gpfs/projects/punim1484/msaintjalmes/fs_synthstrip/models/ -p

# Download synthstrip model
wget -N https://surfer.nmr.mgh.harvard.edu/ftp/dist/freesurfer/synthstrip/models/synthstrip.1.pt -P /data/gpfs/projects/punim1484/msaintjalmes/fs_synthstrip/models/