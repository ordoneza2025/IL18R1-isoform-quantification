#!/bin/bash
#==============================================================================
# GTF to FASTA Script
#
# Description: Extract transcript sequences from a genome FASTA using a GTF
# Requirements: cufflinks (gffread), samtools
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch gtf_to_fasta.sbatch
#==============================================================================
#SBATCH --job-name=GTF_to_FASTA
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mem=12gb
#SBATCH --time=24:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# --- Load modules ---
module load cufflinks
module load samtools

# --- Configuration: modify these paths before submitting ---
GTF_FILE="/path/to/reference.gtf"
GENOME_FASTA="/path/to/genome.fa"
OUTPUT_FASTA="/path/to/output_transcripts.fa"

# --- Job Info ---
echo "$(date +'[%Y-%m-%d %H:%M:%S]') Starting GTF to FASTA on $(hostname)"
echo "GTF:    ${GTF_FILE}"
echo "Genome: ${GENOME_FASTA}"
echo "Output: ${OUTPUT_FASTA}"

# --- Index genome and extract transcript sequences ---
samtools faidx "${GENOME_FASTA}"
gffread -w "${OUTPUT_FASTA}" -g "${GENOME_FASTA}" "${GTF_FILE}"

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Done!"
