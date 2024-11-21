import pandas as pd
import json
import os

SAMPLES = "samples.csv"
PARAMS = "params.json"

# Загрузка данных
samples = pd.read_csv(SAMPLES).set_index("sample_id").fillna("")
samples["read_1"] = samples["read_1"].apply(lambda x: os.path.abspath(x) if x else "")
samples["read_2"] = samples["read_2"].apply(lambda x: os.path.abspath(x) if x else "")
samples["assembly"] = samples["assembly"].apply(lambda x: os.path.abspath(os.path.join("test_input", x)) if x else "")

with open(PARAMS) as f:
    params = json.load(f)

# Разделяем образцы с и без сборки
samples_with_assembly = samples.loc[samples["assembly"] != ""].index.tolist()
samples_without_assembly = samples.loc[samples["assembly"] == ""].index.tolist()

# Создаем словарь accession И обратный словарь
accession_dict = {sample_id: os.path.basename(samples.loc[sample_id, "read_1"]).split('.fastq')[0] for sample_id in samples_without_assembly}
accession_dict_reversed = {v: k for k, v in accession_dict.items()}


rule all:
    input:
        expand("test_output/fastqc/{accession}_fastqc.zip", accession=[accession_dict[sample_id] for sample_id in samples_without_assembly]),
        expand("test_output/fastqc/{accession}_fastqc.html", accession=[accession_dict[sample_id] for sample_id in samples_without_assembly]),
        expand("test_output/spades/{sample_id}/scaffolds.fasta", sample_id=samples_without_assembly),
        expand("test_output/quast/{sample_id}/report.html", sample_id=samples.index),
        expand("test_output/prokka/{sample_id}/scaffolds_annotation.gff", sample_id=samples.index),
        expand("test_output/abricate/{sample_id}/ncbi_results.txt", sample_id=samples.index),
        expand("test_output/abricate/{sample_id}/resfinder_results.txt", sample_id=samples.index)


rule fastqc:
    input:
        r1=lambda wildcards: samples.loc[accession_dict_reversed[wildcards.accession], "read_1"],
        r2=lambda wildcards: samples.loc[accession_dict_reversed[wildcards.accession], "read_2"]
    output:
        zipfile="test_output/fastqc/{accession}_fastqc.zip",
        htmlfile="test_output/fastqc/{accession}_fastqc.html"
    params:
        outdir="test_output/fastqc"
    conda:
        "envs/fastqc.yaml"
    shell:
        """
        fastqc {input.r1} {input.r2} -o {params.outdir}
        """
rule spades:
    input:
        r1=lambda wildcards: samples.loc[wildcards.sample_id, "read_1"],
        r2=lambda wildcards: samples.loc[wildcards.sample_id, "read_2"]
    output:
        scaffolds="test_output/spades/{sample_id}/scaffolds.fasta"
    params:
        threads=min(params["spades"]["threads"], 2),
        memory=params["spades"]["memory"]
    conda:
        "envs/spades.yaml"
    shell:
        """
        spades.py -1 {input.r1} -2 {input.r2} -o test_output/spades/{wildcards.sample_id} -t {params.threads} -m {params.memory}
        """

rule quast:
    input:
        scaffolds=lambda wildcards: os.path.join("test_input", samples.loc[wildcards.sample_id, "assembly"]) if samples.loc[wildcards.sample_id, "assembly"] else os.path.join("test_output", "spades", wildcards.sample_id, "scaffolds.fasta")
    output:
        "test_output/quast/{sample_id}/report.html"
    params:
        reference=params["quast"]["reference"] if "reference" in params["quast"] else ""
    conda:
        "envs/quast.yaml"
    shell:
        """
        quast.py {input.scaffolds} -o test_output/quast/{wildcards.sample_id} {params.reference}
        """

rule prokka:
    input:
        lambda wildcards: samples.loc[wildcards.sample_id, "assembly"] if samples.loc[wildcards.sample_id, "assembly"] else os.path.join("test_output", "spades", wildcards.sample_id, "scaffolds.fasta")
    output:
        "test_output/prokka/{sample_id}/scaffolds_annotation.gff"
    params:
        outdir="test_output/prokka/{sample_id}"
    conda:
        "envs/prokka.yaml"
    shell:
        """
        prokka --outdir {params.outdir} --prefix scaffolds_annotation --force {input}
        """

rule abricate:
    input:
        lambda wildcards: samples.loc[wildcards.sample_id, "assembly"] if samples.loc[wildcards.sample_id, "assembly"] else os.path.join("test_output", "spades", wildcards.sample_id, "scaffolds.fasta")

    output:
        ncbi = "test_output/abricate/{sample_id}/ncbi_results.txt",
        resfinder ="test_output/abricate/{sample_id}/resfinder_results.txt"
    params:
        database=params["abricate"]["database"]
    conda:
        "envs/abricate.yaml"
    shell:
        """
        abricate --db ncbi {input} > {output.ncbi}
        abricate --db resfinder {input} > {output.resfinder}
        """