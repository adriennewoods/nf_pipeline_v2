# Viral Variant Calling Pipeline

A Nextflow DSL2 pipeline for automated qc, alignment, and variant calling of high-throughput sequencing data.

## Pipeline Architecture
This workflow processes raw paired-end FASTQ files through a bioinformatics workflow:
1. FastQC: Evaluates raw read quality.
2. ALIGN: Aligns paired-end reads against a reference genome.
3. SAMtools: Converts SAM files to binary format and sorts alignments.
4. BCFtools: Performs mpileup and variant calling to detect SNPs and indels.
5. MultiQC: Aggregates all execution metrics and QC reports into a single interactive HTML dashboard.

## Project Structure
```text

├── bin/
├── data/
├── results/
│   ├── fastqc/
│   ├── alignments/
│   ├── bams/
│   ├── variants/
│   └── multiqc/
├── main.nf
├── nextflow.config
├── .gitignore
└── README.md
