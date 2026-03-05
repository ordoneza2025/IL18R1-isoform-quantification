### Short-read Isoform quantification. 

Species-specific RefSeq GTF files were obtained from UCSC for all mammals except human, mouse, and Jamaican fruit bat. For the Jamaican fruit bat, our previously generated A. jamaicensis GTF was used; for human, the GTEx FLAIR transcriptome was used (https://www.gtexportal.org/home/datasets); for mouse, the TAMI long-read transcriptome (https://vollmerslab.soe.ucsc.edu/tami/) was merged with the GENCODE mouse annotation (https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M37/gencode.vM37.annotation.gtf.gz), and redundant and single-exon transcripts were removed (gffcompare -M)

For short-read quantification, each GTF file was modified to retain one long and one short IL18R1 isoform. As most species lacked annotation for the short isoform, it was generated using exons 1–9 of IL18R1-Long, with exon 9 extended to the end of the L2-derived polyadenylation signal (PAS) sequence.

## Salmon-quant

GTF files were converted to FASTA format using gffread (Cufflinks v2.2.1 (Trapnell et al. 2010)) to generate a Salmon transcript index, which was subsequently used to quantify short-read data, as bbduk-trimmed fastq  
