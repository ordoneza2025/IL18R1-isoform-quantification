#!/bin/bash
#SBATCH --job-name=transcript_filter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=1:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# =============================================================
# Configuration
# =============================================================
QUANT=/path/to/se.quantOnly_transcript.txt
OUTDIR=/path/to/filtered_transcripts

CPM_THRESHOLD=5
ISOFORM_FRAC_THRESHOLD=0.3

# =============================================================
# Job info
# =============================================================
echo "Job name:       $SLURM_JOB_NAME"
echo "Job ID:         $SLURM_JOB_ID"
echo "Nodes:          $SLURM_JOB_NODELIST"
echo "Date:           $(date)"

# =============================================================
# Setup
# =============================================================
mkdir -p ${OUTDIR}

# =============================================================
# Step 1: Filter transcripts by expression
# =============================================================
echo "=== Filtering transcripts by expression ==="
echo "CPM threshold:            ${CPM_THRESHOLD}"
echo "Isoform fraction threshold: ${ISOFORM_FRAC_THRESHOLD}"
echo "Input:                    ${QUANT}"

awk -v cpm_thresh="${CPM_THRESHOLD}" -v frac_thresh="${ISOFORM_FRAC_THRESHOLD}" '
BEGIN { FS=OFS="\t" }
NR==1 {
    for(i=3; i<=NF; i++) {
        tissue[i] = $i
        gsub(/SRR[0-9]+_/, "", tissue[i])
        gsub(/\.sorted\.bam|\.bam/, "", tissue[i])
    }
    next
}
{
    tid=$1
    match($2, /XLOC_[0-9]+/, a); gid=a[0]
    gene_of[tid] = gid
    for(i=3; i<=NF; i++) expr[tid][i] = $i
    ncols = NF
}
END {
    for(tid in gene_of) {
        gid = gene_of[tid]
        for(i=3; i<=ncols; i++) gene_cpm[gid][i] += expr[tid][i]
    }
    print "transcript_id\tgene_id\ttissue\tCPM\tisoform_fraction"
    for(tid in gene_of) {
        gid = gene_of[tid]
        max_cpm = 0; max_col = -1
        for(i=3; i<=ncols; i++) {
            if(expr[tid][i]+0 > max_cpm+0) {
                max_cpm = expr[tid][i]
                max_col = i
            }
        }
        if(max_cpm+0 < cpm_thresh+0) continue
        if(gene_cpm[gid][max_col]+0 == 0) continue
        frac = expr[tid][max_col] / gene_cpm[gid][max_col]
        if(frac >= frac_thresh+0) print tid, gid, tissue[max_col], max_cpm, frac
    }
}
' ${QUANT} > ${OUTDIR}/filtered_transcripts.txt

# =============================================================
# Step 2: Summary
# =============================================================
echo "Total transcripts passing filters: $(wc -l < ${OUTDIR}/filtered_transcripts.txt)"
echo "Preview (first 5 lines):"
head -5 ${OUTDIR}/filtered_transcripts.txt

echo "Done: $(date)"
