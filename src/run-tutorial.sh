#!/usr/bin/env bash

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

#SBATCH --job-name="snakemake-tutorial"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_tutorial() {
    # The run_tutorial function:
    #     This function contains all test code for running the snakemake
    #     tutorial code locally.
    source /mnt/titan/users/j.boom/mambaforge/bin/activate snakemake-tutorial

    # The output file you use at the end of the snakemake command is the
    # "target", this will make snakemake run all rules to create that "target".
    snakemake \
        --snakefile "/mnt/titan/users/j.boom/genomescan/snakemake-tutorial/snakefile.smk" \
        -n \
        -p \
        --verbose \
        /mnt/titan/users/j.boom/genomescan/snakemake-tutorial/plots/quals.svg

    # You can also use a rule as a target, these should be created at the top
    # of the workflow. The first is used by default when no target is given.
    # But any of them can be called in command line (in this case the
    # rule "all").
    snakemake \
        --snakefile "/mnt/titan/users/j.boom/genomescan/snakemake-tutorial/snakefile.smk" \
        --use-singularity \
        -p \
        --verbose \
        --cores 10 \
        --local-cores 10 \
        --forceall \
        all

    # If I want an image of the directed graph of the pipeline I can use the
    # command below.
    snakemake --dag sorted_reads/{A,B}.bam.bai | dot -Tsvg > dag.svg
    snakemake --dag calls/all.vcf | dot -Tsvg > dag.svg

    # If I want to archive my workflow and share it with other people I could
    # use the "--archive" argument to create a tarball.
    snakemake --archive my-workflow.tar.gz
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    run_tutorial
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-tutorial.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-tutorial.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs code that executes the tutorial snakemake"
            echo "pipeline."
            echo ""

            exit
            ;;
        \?)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
        :)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
    esac
done

main

# Additional information:
# =======================
# Apart from the very common thread resource, Snakemake provides
# a resources directive that can be used to specify arbitrary
# resources, e.g., memory usage or auxiliary computing devices
# like GPUs. Similar to threads, these can be considered by the
# scheduler when an available amount of that resource is given
# with the command line argument --resources (see Resources).
 #
# --forcerun [TARGET ...], -R [TARGET ...]
#     Force the re-execution or creation of the given rules
#     or files. Use this option if you changed a rule and
#     want to have all its output in your workflow updated.
#     (default: None)
#
# With the flag --forceall you can enforce a complete
# re-execution of the workflow.
#
# -R STR 
#     Read group header line such as '@RG\tID:foo\tSM:bar' [null]