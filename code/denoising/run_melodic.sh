#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

DERIV_DIR="$PROJECT_ROOT/bids/derivatives"
FMRIPREP_DIR="$DERIV_DIR/fmriprep"
MELODIC_DIR="$DERIV_DIR/melodic_tensor"

DEFAULT_SUBJECT="10317"
RUN_ALL=false

if [ "$RUN_ALL" = true ]; then
    SUBJECTS=$(ls "$FMRIPREP_DIR" | grep sub- | sed 's/sub-//')
else
    SUBJECTS=$DEFAULT_SUBJECT
fi

for SUB in $SUBJECTS; do

echo "Running Tensor MELODIC for sub-$SUB"

INPUT_FILE="$FMRIPREP_DIR/sub-$SUB/func/*space-MNI*.nii.gz"
OUTPUT_DIR="$MELODIC_DIR/sub-$SUB"

mkdir -p "$OUTPUT_DIR"

melodic \
    -i "$INPUT_FILE" \
    -o "$OUTPUT_DIR" \
    --nobet \
    --tr=2 \
    --dim=automatic \
    --tensor

done
