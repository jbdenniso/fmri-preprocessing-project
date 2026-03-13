#!/usr/bin/env bash
set -e

#################################
# Paths
#################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

BIDS_DIR="$PROJECT_ROOT/bids/ds005123"

#################################
# Default subject
#################################

SUBJECTS=("10317")

#################################
# Loop
#################################

cd "$BIDS_DIR"

for SUB in "${SUBJECTS[@]}"; do

    echo "----------------------------------"
    echo "Processing subject $SUB"
    echo "----------------------------------"

    #################################
    # Download subject data
    #################################

    echo "Downloading data..."
    datalad get sub-$SUB

    #################################
    # Run your existing fmriprep script
    #################################

    echo "Running fmriprep..."
    "$PROJECT_ROOT/code/preprocess/fmriprep.sh" "$SUB"

    #################################
    # Wait happens automatically
    #################################

    echo "fmriprep finished for $SUB"

    #################################
    # Drop raw data
    #################################

    echo "Dropping raw subject data..."
    datalad drop sub-$SUB --reckless availability

    echo "Finished subject $SUB"

done

echo "Pipeline finished."
