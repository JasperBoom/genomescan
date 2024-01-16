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

#SBATCH --job-name="format-python-file"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --time=1:15:0
#SBATCH --partition=all

main() {
    # The main function:
    #     This function runs black in singularity to format the input
    #     python files.
    singularity \
        exec \
            --containall \
           --bind /home,/mnt docker://pyfound/black:latest_release \
            black \
                --line-length 80 \
                --target-version py312 \
                --verbose \
                /home/j.boom/develop/galaxy-tools-umi-isolation/src/umi-isolation.py \
                /home/j.boom/develop/genomescan/src/process-xml.py \
                /home/j.boom/develop/genomescan/src/imiv.py \
                /home/j.boom/develop/genomescan/snakemake-tutorial/scripts/plot-quals.py \
                /home/j.boom/develop/genomescan/src/benchmark.py
                # The script below is python 2. Black does not support python 2.
                # /mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data/fathmm.py
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
            echo "run-format-python-file.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-format-python-file.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the black tool on an input python file."
            echo "Black is used to format python code and convert to"
            echo "their adjusted version of PEP8."
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
# https://black.readthedocs.io/en/stable/usage_and_configuration/black_docker_image.html
