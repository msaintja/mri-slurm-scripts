#!/bin/bash

mkdir ./.tmp -p
truncate -s 0 ./.tmp/commands.list
for subject_img in $(find ./ -name 'sub*nii.gz'); do
subject_id=$(awk -F / '{ print $2; }' <<< $subject_img);
echo "mkdir -p ./derivatives/freesurfer/ && rm -rf ./derivatives/freesurfer/$subject_id && recon-all -all -i $subject_img -s $subject_id -qcache && mkdir -p ./derivatives/fs_minimal/$subject_id/mri/ && mri_convert ./derivatives/freesurfer/$subject_id/mri/brainmask.mgz ./derivatives/fs_minimal/$subject_id/mri/brainmask.nii.gz && mri_convert ./derivatives/freesurfer/$subject_id/mri/brainmask.mgz --apply_transform ./derivatives/freesurfer/$subject_id/mri/transforms/talairach.xfm -o ./derivatives/freesurfer/$subject_id/mri/brainmask_align.mgz && mri_convert ./derivatives/freesurfer/$subject_id/mri/brainmask_align.mgz ./derivatives/fs_minimal/$subject_id/mri/brainmask_align.nii.gz && mri_convert ./derivatives/freesurfer/$subject_id/mri/brain.finalsurfs.mgz ./derivatives/fs_minimal/$subject_id/mri/brain.finalsurfs.nii.gz" >> ./.tmp/commands.list; done

# Ensure that FS directory exists, and that it is empty
# mkdir ./derivatives/freesurfer -p
# rm -rf ./derivatives/freesurfer/*