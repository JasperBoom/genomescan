#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="feature-weights"
#SBATCH --mem=50G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_ranking() {
    # The run_ranking function:
    #     This function runs the python script that takes care of ranking the
    #     variants in pathogenic order.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/calculate-final-rank.py \
        --vep-training "/mnt/flashblade01/scratch/j.boom/data/FR07961000.pathogenic.general.fixed.sorted.annotated.vcf" \
        --exomiser-training "/mnt/flashblade01/scratch/j.boom/data/FR07961000.pathogenic.general.fixed.sorted.exomiser.024.vcf" \
        --output_training "/mnt/flashblade01/scratch/j.boom/data/xFR07961000" \
        --phen2gene "/mnt/flashblade01/scratch/j.boom/phen2gene/meningioma.associated_gene_list"
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    run_ranking
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-feature-weights.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-feature-weights.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This scripts determines the feature weights using a python"
            echo "script."
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