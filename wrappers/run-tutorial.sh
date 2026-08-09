#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="snakemake-tutorial"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
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