# -----------------------------------------------------------------------------
# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.
# -----------------------------------------------------------------------------

# Define which version of snakemake (or higher) should be used.
from snakemake.utils import min_version

min_version("7.23")


# A yaml file for example, that stores lists with for example sample names,
# or file names.
configfile: "/home/j.boom/genomescan/snakemake-tutorial/envs/config.yaml"


# Use "include" to be able to add rules from another Snakefile to
# the workflow
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
