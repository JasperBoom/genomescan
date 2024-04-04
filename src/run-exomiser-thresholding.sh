#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# GenomeScan internship repository.
# Copyright (C) 2024 Jasper Boom

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
#SBATCH --mem=40G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_exomiser_thresholding() {
    # The run_exomiser_thresholding function:
    #     This function calls the exomiser-thresholding.py python script.
    #     This script tries to determine the optimal threshold at which to
    #     separate benign from pathogenic variants.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/exomiser-thresholding.py \
        --yaml "/home/j.boom/develop/genomescan/src/genome.yml" \
        --vcf "/mnt/titan/users/j.boom/r-analysis/2024-02-29-exomiser-thresholding/FR07961000.pathogenic.general.vcf" \
        --output "/mnt/titan/users/j.boom/exomiser_thresholding" \
        --name "" \
        --log "/mnt/titan/users/j.boom/logs" \
        --hpo "HP:0002858,HP:0500089,HP:0100009,HP:0100010,HP:0033714" \
        --temp "/mnt/titan/users/j.boom/tmp" \
        --config "/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties" \
        --docker "amazoncorretto:21.0.2-alpine3.19" \
        --jar "/mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar" \
        --cores 3
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    run_exomiser_thresholding
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
            echo "This script runs a python script that does thresholding on"
            echo "exomiser options."
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