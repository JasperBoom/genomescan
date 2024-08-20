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

# Additional information:
# =======================
#