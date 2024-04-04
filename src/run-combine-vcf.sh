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

#SBATCH --job-name="combine-vcf"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
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
        --benign "/mnt/titan/users/j.boom/r-analysis/pgpuk/FR07961001/FR07961001.pass.recode.vcf" \
        --pathogenic "/mnt/titan/users/j.boom/test-data/clinvar-giab-test-data/general-cancer/pathogenic.vcf" \
        --tabular "/mnt/titan/users/j.boom/r-analysis/2024-02-29-first-filter/FR07961001.general.cancer.subset.3.plus.4.filtered.tsv" \
        --output "/mnt/titan/users/j.boom/r-analysis/2024-02-29-first-filter/FR07961001.general.cancer.subset.3.plus.4.filtered.vcf" \
        --header "/mnt/titan/users/j.boom/test-data/default-vcf-header.txt"
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

# Additional information:
# =======================
#