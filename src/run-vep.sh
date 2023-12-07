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

#SBATCH --job-name="vep"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/home/j.boom/errors/R-%x-%j.error"
#SBATCH --time=120:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     https://www.ensembl.org/info/docs/tools/vep/script/vep_options.html
    input_file="/home/j.boom/tool-testing/simulated_data/R-neat-3.4-174801_golden.vcf"
    singularity \
        exec \
            --containall \
            --bind /home docker://quay.io/biocontainers/ensembl-vep:110.1--pl5321h2a3209d_0  \
                vep \
                    --input_file "${input_file}" \
                    --output_file "${input_file::-4}-annotated.tab" \
                    --species "human" \
                    --format "vcf" \
                    --everything \
                    --tab \
                    --cache \
                    --dir_cache "/home/j.boom/tool-testing/VEP" \
                    --fork 4
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-vep.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-vep.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs vep on the GenomeScan HPC."
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
#