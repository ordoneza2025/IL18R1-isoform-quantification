#!/bin/bash
#==============================================================================
# Salmon Quantification Script
#
# Description: Pseudo-align paired-end reads and quantify transcript abundance
#              using Salmon
# Requirements: Salmon
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch --array=0-N salmon_quant.sbatch
#   where N = number of sample pairs in INPUT_DIR minus 1
#==============================================================================
#SBATCH --job-name=salmon_quant
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=32gb
#SBATCH --time=05:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%A_%a.out
#SBATCH --error=%x.%A_%a.err

# --- Configuration: modify these paths before submitting ---
INDEX_DIR="/path/to/salmon/index"
INPUT_DIR="/path/to/bbduk/output"
OUTPUT_DIR="/path/to/salmon/output"
GTF_FILE="/path/to/reference.gtf"
THREADS=24

# --- Setup ---
mkdir -p "${OUTPUT_DIR}"
queries=($(ls "${INPUT_DIR}"/*_paired.fastq.gz | xargs -n 1 basename | sed 's/_R1_paired.fastq.gz//g' | sed 's/_R2_paired.fastq.gz//g' | uniq))
SAMPLE="${queries[$SLURM_ARRAY_TASK_ID]}"

# --- Job Info ---
echo "$(date +'[%Y-%m-%d %H:%M:%S]') Starting Salmon quantification on $(hostname)"
echo "Salmon version: $(salmon --version)"
echo "Processing file: ${SAMPLE}"

# --- Run Salmon ---
salmon quant \
    -i "${INDEX_DIR}" \
    --libType A \
    -p "${THREADS}" \
    -1 "${INPUT_DIR}/${SAMPLE}_R1_paired.fastq.gz" \
    -2 "${INPUT_DIR}/${SAMPLE}_R2_paired.fastq.gz" \
    --geneMap "${GTF_FILE}" \
    --rangeFactorizationBins 4 \
    --gcBias \
    -o "${OUTPUT_DIR}/${SAMPLE}_transcripts_quant"

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Done!"
