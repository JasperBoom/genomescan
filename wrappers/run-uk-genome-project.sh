#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="uk-genome-project"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_replace() {
    # The run_replace function:
    #     This function calls the uk-genome-project python script which
    #     replaces the clinvar clinical significance column into just benign
    #     classification and adds the pathogenic variants extracted from
    #     clinvar as additional variants.
    #     FR07961000: general-cancer subsets 1 & 2
    #     FR07961001: general-cancer subsets 3 & 4
    #     FR07961004: brain-tumour subset 1
    #     FR07961005: brain-tumour subset 2
    #     FR07961008: meningioma
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/uk-genome-project.py \
        --tab "/mnt/titan/users/j.boom/data/pgpuk/FR07961008/FR07961008.pass.recode.annotated.edit.tab" \
        --skip 52 \
        --clinvar-skip 0 \
        --clinvar "/mnt/titan/users/j.boom/data/tsv/meningioma.pathogenic.set.tsv" \
        --output "/mnt/titan/users/j.boom/data/tsv/FR07961008.meningioma.pathogenic.set.tsv"
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    run_replace
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
            echo "run-uk-genome-project.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-uk-genome-project.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the uk-genome-project python script."
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