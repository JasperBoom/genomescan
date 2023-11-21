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

#SBATCH --job-name="genebreaker"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/genebreaker.log"
#SBATCH --error="/home/j.boom/errors/genebreaker.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     Contains all test code for running genebreaker code locally.
    python3 \
        /home/j.boom/tool-testing/GeneBreaker/GeneBreaker/src/variants.py \
        --help
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPTSTRING="vh"
while getopts ${OPTSTRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-genebreaker.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-genebreaker.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v                    Show the software's version number"
            echo "                       and exit."
            echo " -h                    Show this help page and exit."
            echo ""
            echo "This script runs trial commands for testing genebreaker on"
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
