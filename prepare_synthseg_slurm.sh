#!/bin/bash

mkdir $1/.tmp -p
truncate -s 0 $1/.tmp/commands-synthseg.list
for subject_img in $(find $1/ -name 'sub*nii.gz'); do
subject_id=$(awk -F / '{ print $2; }' <<< $subject_img);
echo "mkdir -p $1/derivatives/synthseg/ && rm -rf $1/derivatives/synthseg/$subject_id && mkdir -p $1/derivatives/synthseg/$subject_id/segmentations/ && mkdir -p $1/derivatives/synthseg/$subject_id/probability_maps/  && mkdir -p $1/derivatives/synthseg/$subject_id/segmentations_resampled_1mm/ && python /data/gpfs/projects/punim1484/msaintjalmes/synthseg/SynthSeg/scripts/commands/SynthSeg_predict.py --i $subject_img  --o $1/derivatives/synthseg/$subject_id/segmentations/ --parc --vol $1/derivatives/synthseg/$subject_id/volumetrics.csv --qc $1/derivatives/synthseg/$subject_id/qc.csv --post $1/derivatives/synthseg/$subject_id/probability_maps/ --resample $1/derivatives/synthseg/$subject_id/segmentations_resampled_1mm/" >> $1/.tmp/commands-synthseg.list; done
