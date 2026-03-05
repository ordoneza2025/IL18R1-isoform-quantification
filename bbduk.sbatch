#!/bin/bash
#==============================================================================
# BBDuk Paired-End Trimming Script
#
# Description: Adapter trimming and quality filtering of paired-end reads
#              using BBDuk (BBTools)
# Requirements: bbmap module
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch --array=0-N bbduk_PE.sbatch
#   where N = number of sample pairs in INPUT_DIR minus 1
#==============================================================================
#SBATCH --job-name=bbduk_PE
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32gb
#SBATCH --time=4:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%A_%a.out
#SBATCH --error=%x.%A_%a.err

# --- Load modules ---
module load bbmap

# --- Configuration: modify these paths before submitting ---
INPUT_DIR="/path/to/fastq"
OUTPUT_DIR="/path/to/bbduk/output"
ADAPTER_FILE="/opt/bbmap/38.05/resources/adapters.fa"
THREADS=1

# --- Setup ---
mkdir -p "${OUTPUT_DIR}/stats"
queries=($(ls "${INPUT_DIR}"/*fastq | xargs -n 1 basename | sed 's/_1.fastq//g' | sed 's/_2.fastq//g' | uniq))
SAMPLE="${queries[$SLURM_ARRAY_TASK_ID]}"

# --- Job Info ---
echo "$(date +'[%Y-%m-%d %H:%M:%S]') Starting BBDuk on $(hostname)"
echo "BBDuk version: $(bbduk.sh --version)"
echo "Processing file: ${SAMPLE}"

# --- Run BBDuk ---
bbduk.sh -Xmx4g \
    in1="${INPUT_DIR}/${SAMPLE}_1.fastq" \
    in2="${INPUT_DIR}/${SAMPLE}_2.fastq" \
    out1="${OUTPUT_DIR}/${SAMPLE}_R1_paired.fastq.gz" \
    out2="${OUTPUT_DIR}/${SAMPLE}_R2_paired.fastq.gz" \
    ref="${ADAPTER_FILE}" \
    qin=33 ktrim=r k=31 mink=11 hdist=1 tpe tbo \
    qtrim=r trimq=10 \
    stats="${OUTPUT_DIR}/stats/${SAMPLE}_stats.txt" \
    t="${THREADS}"

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Done!"
