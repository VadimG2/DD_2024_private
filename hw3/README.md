```markdown
# README.md

This Snakemake pipeline performs quality control, assembly, annotation, and antimicrobial resistance gene detection of bacterial genomes.  It supports two modes: processing raw reads or using pre-assembled genomes.


## Pipeline Steps

1. **Quality Control (FastQC):**  Performs quality control analysis of raw sequencing reads.  This step is skipped if a pre-assembled genome is provided.  Results are saved in the `test_output/fastqc` directory.


2. **Genome Assembly (SPAdes):** Assembles raw sequencing reads into contigs and scaffolds using SPAdes. This step is skipped if a pre-assembled genome is provided. Results are saved in the `test_output/spades` directory.


3. **Genome Assessment (QUAST):** Evaluates the quality of the assembled genome by comparing the contigs to a reference genome (if provided). This step is performed for all samples, whether they were assembled using SPAdes or a pre-assembled genome was used.  Results are saved in the `test_output/quast` directory.

4. **Genome Annotation (Prokka):**  Annotates the assembled genome using Prokka. This step is performed for all samples (using either the provided genome or the result from SPAdes). Results are saved in the `test_output/prokka` directory.


5. **Antimicrobial Resistance Gene Detection (Abricate):** Detects antimicrobial resistance genes in the assembled genome using Abricate.  This step is performed for all samples. Results are saved in the `test_output/abricate` directory.



## Input Data

*   **`samples.csv`:** A comma-separated value (CSV) file containing sample information.  It should have the following columns:
    *   `sample_id`: A unique identifier for each sample.
    *   `read_1`: The absolute path to the forward read file (FASTQ format).
    *   `read_2`: The absolute path to the reverse read file (FASTQ format).
    *   `assembly`: The name of the pre-assembled genome file (FASTA format) located in the `test_input` directory. Leave this column empty if you are providing raw reads instead of a pre-assembled genome.
*   **`params.json`:** A JSON file containing parameters for the pipeline.  It should have the following structure:
    ```json
    {
      "global_params": {
        "threads": 2, //Number of threads
        "outdir": "test_output" //Output directory
      },
      "spades": {
        "threads": 2, //Number of threads for spades
        "memory": "4G"  //Memory for spades
      },
      "quast": {
        "reference": "/path/to/reference/genome.fasta" //Optional reference genome for QUAST. Leave empty if not using
      },
      "abricate": {
        "database": "ResFinder" //Database for abricate
      }
    }
    ```
    Remember to replace `/path/to/reference/genome.fasta` with the actual path to your reference genome if you are using one.
* **Pre-assembled genomes:** If you provide pre-assembled genomes, make sure they are located in the `test_input` directory.

## Output Data

The pipeline will create the following output directories: `test_output/fastqc`, `test_output/spades`, `test_output/quast`, `test_output/prokka`, and `test_output/abricate`.


## Running the Pipeline

1.  **Install Conda:** If you don't have Conda installed, install it from [https://docs.conda.io/en/latest/miniconda.html](https://docs.conda.io/en/latest/miniconda.html).
2.  **Create conda environments:** Create conda environments for each tool specified in the Snakefile using the `envs/*.yaml` files.
3.  **Run Snakemake:** Execute the pipeline using the following command:

    ```bash
    snakemake --use-conda
    ```
    Make sure that `samples.csv` and `params.json` are in the same directory as the `Snakefile`.
