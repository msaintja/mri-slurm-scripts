import os
import glob
import shutil
from tqdm import tqdm
import pandas as pd


#################### DESTRUCTIVE, uncomment and place in directory that is a copy of the original data ####################
#################### Redownloading and processing the original data will take a while otherwise ------ ####################

# for directory in tqdm(os.listdir()):
#     if os.path.isdir(directory):
#         tbl = pd.read_table(glob.glob(directory + '/' + directory + "_sessions.tsv")[0], sep='\t')
#         first_visit = sorted(tbl.session_id)[0]
#         tbl[tbl.session_id == first_visit].to_csv(directory + '/' + directory + "_sessions.tsv", sep='\t', index=False)
#         for subdir in os.listdir(directory):
#             path_subdir = os.path.join(directory, subdir)
#             if os.path.isdir(path_subdir) and subdir != first_visit:
#                 shutil.rmtree(path_subdir)