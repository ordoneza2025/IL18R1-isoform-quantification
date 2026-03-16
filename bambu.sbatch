#!/bin/bash
#SBATCH --job-name=bambu_quant
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --partition=short
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# =============================================================
# Job info
# =============================================================
echo "Job name:       $SLURM_JOB_NAME"
echo "Job ID:         $SLURM_JOB_ID"
echo "Nodes:          $SLURM_JOB_NODELIST"
echo "Date:           $(date)"

# =============================================================
# Load modules
# =============================================================
module load R/4.3.1

# =============================================================
# Run Bambu quantification
# =============================================================
R --vanilla << 'EOF'

# =============================================================
# Configuration
# =============================================================
r_lib_path      <- "/path/to/R/bambu_env"
work_dir        <- "/path/to/work_dir"
genome_path     <- "/path/to/genome.fa"
annotation_path <- "/path/to/annotation.gtf"
bam_dir         <- "/path/to/bam_dir"
output_path     <- "quant_only"
output_prefix   <- "se.quantOnly"

# =============================================================
# Setup
# =============================================================
.libPaths(c(r_lib_path, .libPaths()))
cat("Library paths:\n"); print(.libPaths())

library(bambu)
library(Rsamtools)

# =============================================================
# Step 1: Load genome and annotation
# =============================================================
cat("Loading genome and annotation files...\n")
genomeSequence <- genome_path
annotation     <- prepareAnnotations(annotation_path)

# =============================================================
# Step 2: Collect BAM files
# =============================================================
cat("Searching for BAM files in:", bam_dir, "\n")
file_paths_panel <- list.files(
    path       = bam_dir,
    pattern    = "\\.bam$",
    full.names = TRUE,
    ignore.case = TRUE
)
cat("Found", length(file_paths_panel), "BAM files:\n")
print(file_paths_panel)

if (length(file_paths_panel) == 0) {
    stop("No BAM files found. Please check the directory path and file names.")
}

# =============================================================
# Step 3: Create BamFileList
# =============================================================
cat("Creating BamFileList object...\n")
bamFiles_panel <- Rsamtools::BamFileList(file_paths_panel)

# =============================================================
# Step 4: Run Bambu (quantification only)
# =============================================================
cat("Starting Bambu quantification (discovery = FALSE)...\n")
se.quantOnly <- bambu(
    reads       = bamFiles_panel,
    annotations = annotation,
    genome      = genomeSequence,
    discovery   = FALSE
)

# =============================================================
# Step 5: Write output
# =============================================================
cat("Writing output files...\n")
writeBambuOutput(se.quantOnly, path = output_path, prefix = output_prefix)
cat("Output written to:", output_path, "\n")
cat("Output prefix:    ", output_prefix, "\n")
cat("Job completed:    ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

EOF

echo "R session completed: $(date)"
