#!/bin/bash
#==============================================================================
# Salmon Index Script
#
# Description: Build a Salmon index from a reference transcriptome
# Requirements: Salmon
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch salmon_index.sbatch
#==============================================================================
#SBATCH --job-name=salmon_index
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=32gb
#SBATCH --time=5:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# --- Actiate envrionment ---
conda activate salmon

# --- Configuration: modify these paths before submitting ---
REFERENCE="/path/to/reference.fa"
OUTPUT_DIR="/path/to/salmon/index"
THREADS=8

# --- Setup ---
mkdir -p "${OUTPUT_DIR}"

# --- Job Info ---
echo "$(date +'[%Y-%m-%d %H:%M:%S]') Starting Salmon index on $(hostname)"
echo "Salmon version: $(salmon --version)"
echo "Reference:  ${REFERENCE}"
echo "Output:     ${OUTPUT_DIR}"

# --- Build index ---
salmon index -t "${REFERENCE}" -i "${OUTPUT_DIR}" -p "${THREADS}"

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Done!"
