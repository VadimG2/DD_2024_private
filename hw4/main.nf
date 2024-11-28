#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Define base directory for input files
def baseDir = file('test_input')

// Input parameters
params.spades = [threads: 2, memory: '4g']

// Load samples from CSV
Channel
    .fromPath('samples.csv')
    .splitCsv(header: true)
    .map { row ->
        def read_1_file = baseDir.resolve(row.read_1)
        def read_2_file = baseDir.resolve(row.read_2)
        def assembly_file = row.assembly ? baseDir.resolve(row.assembly) : null

        if (!read_1_file.exists()) {
            log.error "Read 1 file not found for sample ${row.sample_id}: ${read_1_file}"
        }
        if (!read_2_file.exists()) {
            log.error "Read 2 file not found for sample ${row.sample_id}: ${read_2_file}"
        }

        [
            sample_id: row.sample_id,
            read_1: read_1_file,
            read_2: read_2_file,
            assembly: assembly_file
        ]
    }
    .set { samples }

samples_with_assembly = samples.filter { it.assembly != null }
samples_without_assembly = samples.filter { it.assembly == null }

// Define processes
process fastqc {
    input:
    tuple val(sample_id), path(read_1), path(read_2)

    output:
    path("fastqc_output/*")

    publishDir './test_output/fastqc', mode: 'copy'

    container 'staphb/fastqc:latest'

    script:
    """
    mkdir -p fastqc_output
    fastqc ${read_1} ${read_2} -o fastqc_output
    """
}

process spades {
    input:
    tuple val(sample_id), path(read_1), path(read_2)

    output:
    tuple val(sample_id), path("spades_output/${sample_id}/scaffolds.fasta")

    publishDir './test_output/spades/${sample_id}', mode: 'copy'

    container 'staphb/spades:latest'

    script:
    """
    spades.py -1 ${read_1} -2 ${read_2} -o spades_output/${sample_id} -t ${params.spades.threads} -m ${params.spades.memory}
    """
}

process quast {
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("quast_output/${sample_id}")

    publishDir './test_output/quast/${sample_id}', mode: 'copy'

    container 'staphb/quast:latest'

    script:
    """
    quast.py ${assembly} -o quast_output/${sample_id}
    """
}

process prokka {
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("prokka_output/${sample_id}")

    publishDir './test_output/prokka/${sample_id}', mode: 'copy'

    container 'staphb/prokka:latest'

    script:
    """
    prokka --outdir prokka_output/${sample_id} --prefix scaffolds_annotation --force ${assembly}
    """
}

process abricate {
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("abricate_output/${sample_id}")

    publishDir './test_output/abricate/${sample_id}', mode: 'copy'

    container 'staphb/abricate:latest'

    script:
    """
    mkdir -p abricate_output/${sample_id}
    abricate --db ncbi ${assembly} > abricate_output/${sample_id}/ncbi_results.txt
    abricate --db resfinder ${assembly} > abricate_output/${sample_id}/resfinder_results.txt
    """
}

// Workflow definition
workflow {
    // Run FastQC
    samples
        .map { tuple(it.sample_id, it.read_1, it.read_2) }
        | fastqc

    // Run SPAdes on samples without assemblies
    spades_assemblies = samples_without_assembly
        .map { tuple(it.sample_id, it.read_1, it.read_2) }
        | spades

    // Collect assemblies (from SPAdes and existing ones)
    all_assemblies = samples_with_assembly
        .map { tuple(it.sample_id, it.assembly) }
        .concat(spades_assemblies)

    // Run downstream processes
    all_assemblies | quast
    all_assemblies | prokka
    all_assemblies | abricate
}