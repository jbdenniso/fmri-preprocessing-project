#!/usr/bin/env bash
set -e

python code/denoising/run_tedana.py \
    --fmriprepDir bids/derivatives/fmriprep \
    --bidsDir bids/ds005123 \
    --subject 10317
