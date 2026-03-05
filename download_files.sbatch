#!/bin/bash
#==============================================================================
# SRA Download Script
#
# Description: Download SRA files using fasterq-dump
# Requirements: sra-tools
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch --array=0-N sra_download.sbatch
#   where N = number of SRA accessions in SRA_LIST minus 1
#==============================================================================
#SBATCH --job-name=sraDownloads
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=64gb
#SBATCH --time=24:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%A_%a.out
#SBATCH --error=%x.%A_%a.err

# --- Load modules ---
module load sra

# --- Configuration: modify these paths before submitting ---
SRA_LIST="/path/to/sra.txt"       # text file with one SRA accession per line
OUTPUT_DIR="/path/to/output"
TEMP_DIR="/path/to/temp"
THREADS=8

# --- Setup ---
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${TEMP_DIR}"
queries=($(cat "${SRA_LIST}"))

# --- Job Info ---
echo "$(date +'[%Y-%m-%d %H:%M:%S]') Starting SRA download on $(hostname)"
echo "Processing accession: ${queries[$SLURM_ARRAY_TASK_ID]}"

# --- Download ---
fasterq-dump -e "${THREADS}" \
    -O "${OUTPUT_DIR}" \
    --include-technical \
    --split-files \
    -v -v \
    -t "${TEMP_DIR}" \
    "${queries[$SLURM_ARRAY_TASK_ID]}"

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Done!"
