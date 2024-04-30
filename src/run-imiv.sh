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

#SBATCH --job-name="imiv"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_script() {
    # The run_script function:
    #     This function runs the imiv script on all vcf files in the specified
    #     folder. This inserts a meningioma pathogenic variant, sorts the vcf
    #     file, compresses it and creates an index. The additional parts like
    #     compression and indexing do not yet work.
    source /home/j.boom/miniconda3/bin/activate base
    for file in /mnt/titan/users/j.boom/test-data/vcf/*.vcf;
    do
        python3 /home/j.boom/develop/genomescan/src/python/imiv.py \
            --input "${file}" \
            --stats "/mnt/titan/users/j.boom/test-data/vcf/stats.tsv" \
            --meningioma "/mnt/titan/users/j.boom/test-data/clinvar-giab-test-data/meningioma/pathogenic.vcf" \
            --output "/mnt/titan/users/j.boom/test-data/vcf/adjusted/";
    done
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
            echo "run-imiv.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-imiv.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the imiv script that adjusts vcf files."
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