nextflow.enable.dsl = 2



// FastQC Process
process FASTQC {
    tag "FASTQ QC on ${sample_id}"
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_fastqc.{html,zip}"

    script:
    """
    fastqc ${reads}
    """
}

// Alignment Process
process ALIGN {
    tag "Aligning ${sample_id}"
    publishDir "${params.outdir}/alignments"
    mode: 'copy'

    input:
    tuple val(sample_id), path(reads)
    path reference

    output:
    tuple val(sample_id), path("${sample_id}.sam")

    script:
    """
    bwa index ${reference}

    bwa mem ${reference} ${reads[0]} ${reads[1]} > ${sample_id}.sam
    """
}

// SAMtools Sorting Process
process SAMTOOLS_SORT {
    tag "Sorting ${sample_id}"
    publishDir "${params.outdir}/bams"
    mode: 'copy'

    input:
    tuple val(sample_id), path(sam_file)

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam")

    script:
    """
    samtools view -bS ${sam_file} | samtools sort -o ${sample_id}.sorted.bam
    """
}
// Variant Calling Process
process BCFTOOLS_CALL {
    tag "Calling variants for ${sample_id}"
    publishDir "${params.outdir}/variants",
    mode: 'copy'

    input:
    tuple val(sample_id), path(sorted_bam)
    path reference

    output:
    tuple val(sample_id), path("${sample_id}.vcf.gz")

    script:
    """
    # Generate pileup and call variants
    bcftools mpileup -f ${reference} ${sorted_bam} | bcftools call -mv -Oz -o ${sample_id}.vcf.gz
    """
}

// MultiQC
process MULTIQC {
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path '*'

    output:
    path 'multiqc_report.html'

    script:
    """
    multiqc .
    """
}

// Workflow
workflow {
    read_pairs_ch = Channel.fromFilePairs(params.input, checkIfExists: true)
    ref_ch = Channel.value(file('data/reference.fasta'))

    // QC
    FASTQC(read_pairs_ch)

    // Alignment & Sorting
    ALIGN(read_pairs_ch, ref_ch)
    SAMTOOLS_SORT(ALIGN.out)

    // Variant Calling
    BCFTOOLS_CALL(SAMTOOLS_SORT.out, ref_ch)

    // MultiQC
    MULTIQC(
        FASTQC.out.collect()
    )
}
