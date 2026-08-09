#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="training-test-subsets"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_script() {
    # The run_script function:
    #     This function runs the training-test-subsets python script which
    #     creates training and test sets used for thresholding in variant
    #     filtering.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/training-test-subsets.py \
        --output "/mnt/titan/users/j.boom/data/vcf/" \
        --clinvar "/mnt/titan/users/j.boom/data/pathogenic-variants/pathogenic.general.vcf" \
        --testset "/mnt/titan/users/j.boom/data/pgpuk/FR07961001/FR07961001.pass.recode.vcf" \
        --trainingset "/mnt/titan/users/j.boom/data/pgpuk/FR07961000/FR07961000.pass.recode.vcf"
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    run_script
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="i:vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        i)
            python_file=${OPTARG}
            ;;
        v)
            echo ""
            echo "run-training-test-subsets.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-training-test-subsets.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the training-test-subsets script that"
            echo "creates vcf training and test sets used for thresholding."
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