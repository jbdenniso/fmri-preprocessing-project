#!/usr/bin/env bash
SUB=$1
set -e
if [ -d "$PROJECT_ROOT/bids/derivatives/fmriprep/sub-$SUB" ]; then
    echo "Subject already processed. Skipping."
    continue
fi
# -----------------------------
# Determine project directories
# -----------------------------

# Absolute path to this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Project root (two levels up from code/preprocess)
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

BIDS_DIR="$PROJECT_ROOT/bids/ds005123"
DERIV_DIR="$PROJECT_ROOT/bids/derivatives"
SCRATCH_DIR="$PROJECT_ROOT/bids/scratch"
LICENSE_FILE="$PROJECT_ROOT/license.txt"

# -----------------------------
# Subject argument
# -----------------------------



echo "Running fMRIPrep for subject: $SUB"
echo "Project root: $PROJECT_ROOT"

# -----------------------------
# Run Docker
# -----------------------------

docker run -it --rm \
  -v "$BIDS_DIR":/data:ro \
  -v "$DERIV_DIR":/out \
  -v "$SCRATCH_DIR":/scratch \
  -v "$LICENSE_FILE":/license.txt \
  nipreps/fmriprep:25.2.5 \
  /data /out participant \
  --participant-label "$SUB" \
  --stop-on-first-crash \
  --me-output-echos \
  --output-spaces MNI152NLin6Asym \
  --fs-no-reconall \
  --fs-license-file /license.txt \
  --nthreads 8 \
  --omp-nthreads 8 \
  --mem-mb 30000 \
  -w /scratch
