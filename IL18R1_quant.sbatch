#!/bin/bash
#==============================================================================
# Salmon TPM Extraction Script
#
# Description: Extract TPM values for specific transcripts from all Salmon
#              quant.sf output files
# Requirements: Salmon output directories containing quant.sf files
#
# Usage:
#   Edit the configuration variables below, then submit with:
#   sbatch salmon_extract_tpm.sbatch
#==============================================================================
#SBATCH --job-name=isoform_quant
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=32gb
#SBATCH --time=5:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# --- Configuration: modify these paths before submitting ---
SALMON_OUTPUT_DIR="/path/to/salmon/output"
OUTPUT_FILE="/path/to/transcript_TPMs.txt"

# --- Transcripts of interest: modify as needed ---
transcripts=(
    "XM_005075366.4"
    "XM_040729504.1"
)

# --- Validate input ---
if [ ! -d "${SALMON_OUTPUT_DIR}" ]; then
    echo "ERROR: Directory not found: ${SALMON_OUTPUT_DIR}"
    exit 1
fi

# --- Find all quant.sf files ---
samples=()
while IFS= read -r -d '' sample_dir; do
    base=$(basename "$sample_dir")
    clean_name=${base%_transcripts_quant}
    samples+=("${base}:${clean_name}")
done < <(find "${SALMON_OUTPUT_DIR}" -maxdepth 2 -name "quant.sf" -printf '%h\0')

if [ ${#samples[@]} -eq 0 ]; then
    echo "ERROR: No quant.sf files found in ${SALMON_OUTPUT_DIR}"
    exit 1
fi

echo "$(date +'[%Y-%m-%d %H:%M:%S]') Found ${#samples[@]} samples"

# --- Build header ---
header="Sample"
for transcript in "${transcripts[@]}"; do
    header="${header}\t${transcript}_TPM"
done
echo -e "${header}" > "${OUTPUT_FILE}"

# --- Extract TPM for each sample ---
for sample_pair in "${samples[@]}"; do
    dir_name="${sample_pair%%:*}"
    clean_name="${sample_pair##*:}"
    quant_file="${SALMON_OUTPUT_DIR}/${dir_name}/quant.sf"
    row="${clean_name}"

    for transcript in "${transcripts[@]}"; do
        if [ -f "${quant_file}" ]; then
            tpm=$(awk -v trans="^${transcript}\t" '$0 ~ trans {print $4; exit}' "${quant_file}")
            if [ -z "$tpm" ]; then
                tpm="NA"
            fi
        else
            tpm="NA"
        fi
        row="${row}\t${tpm}"
    done

    echo -e "${row}" >> "${OUTPUT_FILE}"
done

echo "$(date +'[%Y-%m-%d %H:%M:%S]') TPM table created: ${OUTPUT_FILE}"
