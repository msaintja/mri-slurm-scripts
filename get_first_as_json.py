import argparse
import tempfile
import os
import glob
import shutil
from tqdm import tqdm
import pandas as pd
import ujson


def insert_line_front(insert_filename, to_insert):

    with open(insert_filename) as src, tempfile.NamedTemporaryFile(
            'w', dir=os.path.dirname(insert_filename), delete=False) as dst:

        # Discard first line
        src.readline()

        # Save the new first line
        dst.write(to_insert + '\n')

        # Copy the rest of the file
        shutil.copyfileobj(src, dst)

    # remove old version
    os.unlink(insert_filename)

    # rename new version
    os.rename(dst.name, insert_filename)

    return()


def main(base_dir):
    ids = []
    for f in tqdm(glob.glob(f"{base_dir}/**/*_sessions.tsv")):
        visit = f'{os.path.basename(f).split("sub-")[-1].split("_sessions")[0]}_MR_'+pd.read_table(f, sep="\t").source_session_id[0]
        ids.append(visit)

    # with open('first_visits.json', 'w') as f:
    #     ujson.dump(ids, f)

    insert_line_front(f"./check_first_visits.js", f"var first_mr_visits = {ids}")


parser = argparse.ArgumentParser(formatter_class = argparse.RawDescriptionHelpFormatter,
                                    description = "Get first MR visit for each subject and prepare a JS selection script")
 
parser.add_argument("-b", "--base_dir", required=True, help = "Base directory")
args = vars(parser.parse_args())

if os.path.isdir(args["base_dir"]):
    main(args["base_dir"])
