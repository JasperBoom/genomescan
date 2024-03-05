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

#SBATCH --job-name="uk-genome-project"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_replace(){
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
        --tab "/mnt/titan/users/j.boom/r-analysis/pgpuk/FR07961008/FR07961008.pass.recode.annotated.edit.tab" \
        --skip 52 \
        --clinvar-skip 0 \
        --clinvar "/mnt/titan/users/j.boom/r-analysis/2024-02-29-combined/meningioma.pathogenic.set.tsv" \
        --output "/mnt/titan/users/j.boom/r-analysis/2024-02-29-combined/FR07961008.meningioma.pathogenic.set.tsv"
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

# Additional information:
# =======================
#