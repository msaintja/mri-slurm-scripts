import argparse
import glob
import os
import types

import pandas as pd
from neuroharmony import fetch_trained_model, combine_freesurfer, combine_mriqc



def main(mri_path, metadata, modalities=["T1w"], fs_dir="freesurfer"):
    ### Helper: Inclusion of fine-grained scanner information
    mr_info = pd.read_csv(metadata)
    mr_info = mr_info[mr_info.loc[:, "scan category"].isin(modalities)]

    subjects = glob.glob(os.path.join(mri_path, "*/sub-*_sessions.tsv"))
    sessions = pd.concat([pd.read_csv(s, sep='\t').assign(subject=s.split("/")[-1].split("_")[0]) for s in subjects])

    subjects_sessions = glob.glob(os.path.join(mri_path, "*/ses-*"))
    l = [s.split("/")[-2:] for s in subjects_sessions]
    assert len(set([ll[0] for ll in l])) == len(l), "Subjects have more than 1 visit each"
    mapping = {ll[0] : ll[0].strip("sub-") + "_MR_" + sessions.loc[(sessions.subject == ll[0]) & (sessions.session_id == ll[1]), "source_session_id"].values[0] for ll in l}
    mapping
    def get_scanner_id(subject, info = ["Manufacturer", "ManufacturersModelName", "MagneticFieldStrength", "SeriesDescription"]):
        session_from_subject = mapping[subject]
        filtr = mr_info[(mr_info.label == session_from_subject)]
        filtr = filtr[filtr.filename == sorted(filtr.filename)[0]].to_dict('records')[0]
        filtr = "_".join([str(filtr[attr]) for attr in info])
        return filtr


    ## Experimental zone: remove dependencies on covariates for inference
    neuroharmony = fetch_trained_model()
    # Overriding the prediction method in neuroharmony.models.harmonization.Neuroharmony to disregard all fluff
    # including checking covariates, etc. that are only used for ComBat, not relevant at inference.
    def _predict(self, df, index="participant_id"):
        # Check data
        self._check_trained_model()
        assert isinstance(df, pd.DataFrame), TypeError("Input data should be a pandas dataframe (NDFrame).")
        self._check_vars(df, self.features)
        self._check_prediction_ranges(df.copy())
        df = self._check_index(df.copy())
        df.set_index(index, inplace=True)
        self.predicted_ = pd.DataFrame([], columns=self.features, index=df.index)
        self.models_by_feature_[self.features[0]]._check_is_fitted("predict")
        for var in self.features:
            predicted_y_1 = self.models_by_feature_[var].predict(df[self.regression_features + [var]])
            self.predicted_[var] = df[var] - predicted_y_1
        self.predicted_ = pd.DataFrame(self.predicted_, index=df.index, columns=self.features)
        return self.predicted_

    neuroharmony.predict = types.MethodType(_predict, neuroharmony)

    # Gathering only freesurfer, eTIV, MRIQC and Qoala data


    freesurfer_data = combine_freesurfer(f'{mri_path}/derivatives/{fs_dir}/')
    participants_data = pd.read_csv(f'{mri_path}/participants.tsv', header=0, sep='\t', index_col=0)
    MRIQC = combine_mriqc(f'{mri_path}/derivatives/mriqc/').rename(columns = {"prob_y": "mriqc_prob"})
    X = pd.merge(participants_data, MRIQC, left_on='participant_id', right_on='participant_id')
    X = pd.merge(X, freesurfer_data, left_on='participant_id', right_on='participant_id')

    # retrieve total intracranial volume because `combine_freesurfer` does not include it
    eTIV = pd.read_csv(f"{mri_path}/derivatives/{fs_dir}/aseg_stats.txt", sep='\t')[['Measure:volume', "EstimatedTotalIntraCranialVol"]].rename(columns={'Measure:volume': "participant_id"})
    X = pd.merge(X, eTIV, right_on="participant_id", left_on='participant_id')

    # Get Qoala T values (as a probability 0-1 of exclusion, use `QoalaQC.R`)
    qoala_data = pd.read_csv(f"{mri_path}/derivatives/qoala/qc.csv")[['participant_id', "qoala_prob"]]
    X = pd.merge(X, qoala_data, right_on="participant_id", left_on='participant_id')

    x_harmonized = neuroharmony.transform(X)
    print("Out of range subjects: ", neuroharmony.subjects_out_of_range_)

    neuroharmony_dir = os.path.join(mri_path, "derivatives", "neuroharmony")
    os.makedirs(neuroharmony_dir, exist_ok=True)

    freesurfer_data.to_csv(os.path.join(neuroharmony_dir, "freesurferdata_harmony_pre.csv"))
    x_harmonized.to_csv(os.path.join(neuroharmony_dir, "freesurferdata_harmony_post.csv"))
    (freesurfer_data - x_harmonized).to_csv(os.path.join(neuroharmony_dir, "freesurferdata_harmony_adjustment.csv"))



parser = argparse.ArgumentParser(formatter_class = argparse.RawDescriptionHelpFormatter,
                                    description = "Apply neuroharmony to a BIDS dataset (req. MRIQC, Qoala, Freesurfer)")
 
parser.add_argument("-b", "--base_dir", required=True, help = "Base BIDS directory")
parser.add_argument("-d", "--metadata", required=True, help = "Metadata CSV on scanner params")
parser.add_argument("-m", "--modalities", required=True, help = "Comma-separated list of modalities to consider")
parser.add_argument("-f", "--freesurfer_dir", default="freesurfer", help = "Name of freesurfer dir in derivatives")
args = vars(parser.parse_args())

if os.path.isdir(args["base_dir"]):
    main(args["base_dir"] + "/" if "/" not in args["base_dir"] else args["base_dir"], args["metadata"], args["modalities"].split(",") if "," in args["modalities"] else [args["modalities"]], args["freesurfer_dir"])
