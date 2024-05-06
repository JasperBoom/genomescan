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

#SBATCH --job-name="exomiser-thresholding"
#SBATCH --mem=50G
#SBATCH --cpus-per-task=8
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_exomiser_thresholding_oop() {
    # The run_exomiser_thresholding_oop function:
    #     This function calls the prepare-exomiser-files.py python script.
    #     This script prepares Exomiser results to determine the optimal
    #     threshold at which to separate benign from pathogenic variants.
    #     This is the version of the script that uses OOP.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/prepare-exomiser-files.py \
        --yaml "/home/j.boom/develop/genomescan/src/genome.v14.yml" \
        --vcf "/mnt/flashblade01/scratch/j.boom/data/FR07961000.pathogenic.general.test.vcf" \
        --output "/mnt/flashblade01/scratch/j.boom/test" \
        --log "/mnt/flashblade01/scratch/j.boom/test/logs" \
        --hpo "HP:0002858,HP:0500089,HP:0100009,HP:0100010,HP:0033714" \
        --temp "/mnt/flashblade01/scratch/j.boom/tmp" \
        --config "/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties" \
        --jar "/mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar" \
        --cores 8
}

run_exomiser_thresholding_original() {
    # The run_exomiser_thresholding_original function:
    #     This function calls the exomiser-thresholding.py python script.
    #     This script prepares Exomiser results to determine the optimal
    #     threshold at which to separate benign from pathogenic variants.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/exomiser-thresholding.py \
        --yaml "/home/j.boom/develop/genomescan/src/genome.v14.yml" \
        --vcf "/mnt/flashblade01/scratch/j.boom/data/FR07961000.pathogenic.general.vcf" \
        --output "/mnt/flashblade01/scratch/j.boom/results" \
        --name "" \
        --log "/mnt/flashblade01/scratch/j.boom/logs" \
        --hpo "HP:0002858,HP:0500089,HP:0100009,HP:0100010,HP:0033714" \
        --temp "/mnt/flashblade01/scratch/j.boom/tmp" \
        --config "/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties" \
        --docker "amazoncorretto:21.0.2-alpine3.19" \
        --jar "/mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar" \
        --cores 8
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    #run_exomiser_thresholding_original
    run_exomiser_thresholding_oop
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-exomiser-thresholding.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-exomiser-thresholding.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs a python script that runs Exomiser and"
            echo "prepares results in order to determine thresholds later."
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
#