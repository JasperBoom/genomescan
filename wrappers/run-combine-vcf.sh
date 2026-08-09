#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="combine-vcf"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_combine() {
    # The run_replace function:
    #     This function calls the combine-vcf python script which
    #     combines two vcf files based on the IDs found in a tabular file.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/combine-vcf.py \
        --benign "/mnt/titan/users/j.boom/data/pgpuk/FR07961001/FR07961001.pass.recode.vcf" \
        --pathogenic "/mnt/titan/users/j.boom/clinvar-giab-data/general-cancer/pathogenic.vcf" \
        --tabular "/mnt/titan/users/j.boom/data/tsv/FR07961001.general.cancer.subset.3.plus.4.filtered.tsv" \
        --output "/mnt/titan/users/j.boom/data/tsv/FR07961001.general.cancer.subset.3.plus.4.filtered.vcf" \
        --header "/mnt/titan/users/j.boom/clinvar-giab-data/default-vcf-header.txt"
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    run_combine
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
            echo "run-combine-vcf.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-combine-vcf.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the combine-vcf python script. Which"
            echo "combines a vcf file of benign variants with that of"
            echo "pathogenic variants. Using a default header found in a"
            echo "separate file."
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