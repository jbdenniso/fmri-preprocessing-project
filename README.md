# Multi-Echo fMRI Denoising Comparison Pipeline

This repository contains a preprocessing and analysis pipeline for multi-echo fMRI data. The long-term goal of the project is to compare denoising performance between:

TEDANA multi-echo denoising methods

A tensor-ICA approach implemented using FSL MELODIC

The pipeline is designed to:

Download subject data on demand using DataLad

Run preprocessing using fMRIPrep

Drop raw data afterward to conserve disk space

Store only derivative outputs needed for analysis

This approach allows large neuroimaging datasets to be processed while minimizing local storage requirements.

## Project Goals

The primary scientific objective is to evaluate how different denoising strategies affect signal quality and downstream analysis in multi-echo fMRI datasets.

Specifically, we will compare:

### Method 1: Multi-echo denoising

Using TEDANA, which leverages TE-dependence to separate BOLD and non-BOLD components.

Key advantages:

Physically grounded separation of signal sources

Widely used in multi-echo pipelines

Automatically identifies BOLD-like components

### Method 2: Tensor ICA

Using FSL MELODIC to perform tensor-ICA across subjects and echoes.

Potential advantages:

Captures shared spatiotemporal structure

May identify noise sources missed by TE-based methods

Provides a group-level decomposition framework

### Comparison Metrics

The two approaches will be compared using:

temporal SNR

residual motion artifacts

task signal detection

functional connectivity stability


