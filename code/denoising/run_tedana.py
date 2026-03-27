import os
import re
import json
import argparse
from tedana import workflows

# -----------------------------
# Arguments
# -----------------------------

parser = argparse.ArgumentParser(
    description="Run TEDANA on fMRIPrep outputs (default: one subject)"
)

parser.add_argument(
    "--fmriprepDir",
    required=True,
    type=str,
    help="Full path to fMRIPrep derivatives directory"
)

parser.add_argument(
    "--bidsDir",
    required=True,
    type=str,
    help="Full path to BIDS directory"
)

parser.add_argument(
    "--subject",
    default="10317",
    type=str,
    help="Subject label (default: 10317)"
)

args = parser.parse_args()

prep_data = args.fmriprepDir
bids_dir = args.bidsDir
subject = args.subject

# -----------------------------
# Find echo images for subject
# -----------------------------

echo_images = [
    f for root, dirs, files in os.walk(prep_data)
    for f in files
    if (f"sub-{subject}" in f)
    and ("_echo-" in f)
    and f.endswith("_desc-preproc_bold.nii.gz")
]

if len(echo_images) == 0:
    raise ValueError(f"No echo files found for sub-{subject}")

# Get acquisition prefixes
image_prefix_list = set(
    re.search("(.*)_echo-", f).group(1)
    for f in echo_images
)

# -----------------------------
# Process each acquisition
# -----------------------------

for acq in image_prefix_list:

    print(f"Processing {acq}")
    mask_files = [
        os.path.join(root, f)
        for root, dirs, files in os.walk(prep_data)
        for f in files
        if (
            f.startswith(acq)
            and f.endswith("_desc-brain_mask.nii.gz")
            and "space-" not in f   # otherwise we're grabbing the transformed brain mask as well
        )
    ]
   

    if len(mask_files) == 0:
        raise ValueError(f"No mask found for {acq}")
    elif len(mask_files) > 1:
        print(f"WARNING: Multiple masks found for {acq}, using first")

    mask_file = sorted(mask_files)[0]

    print(f"Using mask: {mask_file}")

    # Find matching JSON files for echo times
    ME_headerinfo = [
        os.path.join(root, f)
        for root, dirs, files in os.walk(bids_dir)
        for f in files
        if (
            f.startswith(acq)
            and "_echo-" in f
            and "part-mag" in f
            and f.endswith("_bold.json")
        )]

    echo_times = [
        json.load(open(f))["EchoTime"]
        for f in ME_headerinfo
    ]
   

    # Convert to milliseconds (TEDANA expects ms)
    echo_times = [1000 * float(te) for te in echo_times]
    echo_times.sort()

    # Find matching echo images
    acq_image_files = [
        os.path.join(root, f)
        for root, dirs, files in os.walk(prep_data)
        for f in files
        if (acq in f)
        and ("echo" in f)
        and f.endswith("_desc-preproc_bold.nii.gz")
    ]

    acq_image_files.sort()

    # Output directory
    out_dir = os.path.join(
        os.path.dirname(prep_data),
        "tedana",
        f"sub-{subject}"
    )

    os.makedirs(out_dir, exist_ok=True)

    # -----------------------------
    # Run TEDANA
    # -----------------------------

    workflows.tedana_workflow(
        acq_image_files,
        echo_times,
        out_dir=out_dir,
        prefix=f"{acq}",
        fittype="curvefit",
        tedpca="kic",
        mask=mask_file,
        overwrite=True,
        verbose=True,
        gscontrol=None
    )

print("Done.")
