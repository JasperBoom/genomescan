#!/usr/bin/env bash

# GenomeScan internship repository.
# Copyright (C) 2021 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# his program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.

#SBATCH --job-name="neat-3.4"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/neat-3.4.log"
#SBATCH --error="/home/j.boom/errors/neat-3.4.error"
#SBATCH --time=12:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     Contains all test code for running neat v3.4 code locally.
    source /home/j.boom/mambaforge/bin/activate neat

    time_stamp="$(date +"%d-%m-%y-%T")"

    python3 /home/j.boom/tool-testing/NEAT-3.4/gen_reads.py \
        -r "/home/j.boom/tool-testing/data/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
        -R 101 \
        -o "/home/j.boom/tool-testing/simulated_data/${time_stamp}" \
        --vcf \
        --bam
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPTSTRING="vh"
while getopts ${OPTSTRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-neat-3.4.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-neat-3.4.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v                    Show the software's version number"
            echo "                       and exit."
            echo " -h                    Show this help page and exit."
            echo ""
            echo "This script runs trial commands for testing neat v3.4 on"
            echo "the GenomeScan HPC."
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
