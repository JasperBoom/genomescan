# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.

# Define which version of Snakemake (or higher) should be used.
from snakemake.utils import min_version
min_version("7.23")

# A yaml file for example, that stores list with for
# example sample names, or file names.
configfile: "/home/j.boom/genomescan/tutorial-workflow/envs/config.yaml"

# A function that extracts a string from the yaml object
# defined above. "samples" is the first list defined in
# a .yaml file. Depending on the wildcard a specific item
# in that list is extracted.
# "wildcards" is a Snakemake object, that stores all
# wildcards in the Snakefile, depending on the name these
# can be extracted.
def get_bwa_map_input_fastqs(wildcards):
    return config["directories"]["input"] + "/" + config["samples"][wildcards.sample]

rule bwa_map:
    # The files required as input for the tool you want
    # to run. The second line calls the function above.
    input:
        config["directories"]["input"] + "/data/genome.fa",
        get_bwa_map_input_fastqs
    # The output files that a tool will produce and
    # need to be collected by Snakemake.
    output:
        # Setting "temp" lets Snakemake know that this
        # file does not need to be kept, and will be
        # removed after it has been used by all rules
        # defined in the snakefile.
        temp(config["directories"]["output"] + "/mapped_reads/{sample}.bam")
    # This directive allows for defining special
    # parameters that should be passed to the tool.
    # This can also be used to extract the definition
    # for a parameter from the configfile.
    params:
        rg=r"@RG\tID:{sample}\tSM:{sample}"
    # If a tool outputs log information, this directive
    # can be used to store that log info instead of
    # printing to the terminal.
    log:
        config["directories"]["output"] + "/logs/bwa_mem/{sample}.log"
    # The threads this rule can maximally use for
    # running the tool.
    threads:
        8
    # The terminal/shell command that needs to be
    # defined in order to run a tool.
    # The "2> {log}" is used to output the terminal
    # output to the file defined in the log directive.
    shell:
        "(bwa mem -R '{params.rg}' -t {threads} {input} | "
        "samtools view -Sb - > {output}) 2> {log}"

rule samtools_sort:
    input:
        config["directories"]["output"] + "/mapped_reads/{sample}.bam"
    output:
        # Setting "protected" will make sure the file
        # in question won't be accidentally deleted or
        # modified.
        protected(config["directories"]["output"] + "/sorted_reads/{sample}.bam")
    # A rule (so basically a tool) can be benchmarked.
    # Snakemake will measure wall clock time and memory usage
    # and store it in a tab-delimited file defined below.
    # The "repeat" allows you to run the rule multiple times
    # so you get a clearer idea of what the variability is in
    # running a tool.
    benchmark:
        repeat(config["directories"]["output"] + "/benchmarks/{sample}.samtools_sort.benchmarkt.tbl", 3)
    log:
        config["directories"]["output"] + "/logs/samtools_sort/{sample}.log"
    shell:
        "samtools sort -T /sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output} 2> {log}"

rule samtools_index:
    input:
        config["directories"]["output"] + "/sorted_reads/{sample}.bam"
    output:
        config["directories"]["output"] + "/sorted_reads/{sample}.bam.bai"
    log:
        config["directories"]["output"] + "/logs/samtools_index/{sample}.log"
    shell:
        "samtools index {input} 2> {log}"