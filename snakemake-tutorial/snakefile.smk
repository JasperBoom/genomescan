# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

# Define which version of snakemake (or higher) should be used.
from snakemake.utils import min_version

min_version("7.23")


# A yaml file for example, that stores lists with for example sample names,
# or file names.
configfile: "/home/j.boom/develop/genomescan/snakemake-tutorial/envs/config.yaml"


# Use "include" to be able to add rules from another Snakefile to
# the workflow.
include: config["directories"]["script"] + "/rules/read-mapping.smk"


# This rule is used to define the output of the Snakefile. The first rule
# structured like this is used as the default output, which is why it is
# defined at the top of the snakefile.
rule all:
    input:
        config["directories"]["output"] + "/plots/quals.svg",
    default_target: True


rule bcftools_call:
    input:
        fa=config["directories"]["input"] + "/data/genome.fa",
        # Setting "expand" will create a python list of strings with all
        # possible files it can find in "sorted_reads". The {sample} part will
        # translate to A, B and C.
        bam=expand(
            "{output}/sorted_reads/{sample}.bam",
            output=config["directories"]["output"],
            sample=config["samples"],
        ),
        bai=expand(
            "{output}/sorted_reads/{sample}.bam.bai",
            output=config["directories"]["output"],
            sample=config["samples"],
        ),
    output:
        config["directories"]["output"] + "/calls/all.vcf",
    params:
        rate=config["prior_mutation_rate"]["default"],
    log:
        config["directories"]["output"] + "/logs/bcftools_call/all.log",
    shell:
        "(bcftools mpileup -f {input.fa} {input.bam} | "
        "bcftools call -mv -P '{params.rate}' - > {output}) 2> {log}"


rule plot_quals:
    input:
        config["directories"]["output"] + "/calls/all.vcf",
    output:
        config["directories"]["output"] + "/plots/quals.svg",
    script:
        config["directories"]["script"] + "/scripts/plot-quals.py"
