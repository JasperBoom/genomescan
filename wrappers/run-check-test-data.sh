#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="check-test-data"
#SBATCH --mem=100G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_check_test_data() {
    # The run_check_test_data function:
    #     This function runs the python script check-test-dataset-variants to
    #     investigate variants in the test dataset and create a confusion
    #     matrix.
    INPUT_DIR="/mnt/flashblade01/scratch/j.boom/data/"
    source /home/j.boom/miniconda3/bin/activate base

    python3 /home/j.boom/develop/genomescan/src/python/check-test-dataset-variants.py \
        -a "${INPUT_DIR}FR07961006.pathogenic.meningioma.fixed.sorted.vcf" \
        -f "${INPUT_DIR}FR07961006.ranking.tsv" \
        --output "${INPUT_DIR}"
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    run_check_test_data
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-check-test-data.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-check-test-data.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script a python script that checks the performance"
            echo "of the method on the test dataset."
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