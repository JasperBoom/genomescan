#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="phen2gene"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_phen2gene() {
    # The run_phen2gene function:
    #     This function runs Phen2Gene using a customized container build for
    #     GenomeScan.
    singularity \
        exec \
            --containall \
            --bind /home,/mnt \
            --cleanenv \
            /mnt/shared/tools/phen2gene/phen2gene-1.2.3.sif \
            /root/Scripts/phen2gene.py \
                --file "/mnt/flashblade01/scratch/j.boom/phen2gene/meningioma_hpo.txt" \
                --verbosity \
                --output "/mnt/flashblade01/scratch/j.boom/phen2gene" \
                --name "meningioma" \
                --database "/root/Knowledgebase"
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    run_phen2gene
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-phen2gene.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-phen2gene.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs trial commands for testing phen2gene."
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