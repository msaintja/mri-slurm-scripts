#!/bin/bash

mkdir $1/.tmp -p
truncate -s 0 $1/.tmp/commands.list
for subject_img in $(find $1/ -name 'sub*nii.gz'); do
subject_id=$(awk -F / '{ print $2; }' <<< $subject_img);
echo "mkdir -p $1/derivatives/freesurfer/ && rm -rf $1/derivatives/freesurfer/$subject_id && recon-all -all -i $subject_img -s $subject_id -qcache && mkdir -p $1/derivatives/fs_minimal/$subject_id/mri/ && mri_convert $1/derivatives/freesurfer/$subject_id/mri/brainmask.mgz $1/derivatives/fs_minimal/$subject_id/mri/brainmask.nii.gz && mri_convert $1/derivatives/freesurfer/$subject_id/mri/brainmask.mgz --apply_transform $1/derivatives/freesurfer/$subject_id/mri/transforms/talairach.xfm -o $1/derivatives/freesurfer/$subject_id/mri/brainmask_align.mgz && mri_convert $1/derivatives/freesurfer/$subject_id/mri/brainmask_align.mgz $1/derivatives/fs_minimal/$subject_id/mri/brainmask_align.nii.gz && mri_convert $1/derivatives/freesurfer/$subject_id/mri/brain.finalsurfs.mgz $1/derivatives/fs_minimal/$subject_id/mri/brain.finalsurfs.nii.gz" >> $1/.tmp/commands.list; done
