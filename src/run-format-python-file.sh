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
#SBATCH --output="/home/j.boom/logs/format-python-file.log"
#SBATCH --error="/home/j.boom/errors/format-python-file.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     This function runs black in singularity to format an input
    #     python file.
    singularity \
        exec \
            --containall \
           --bind /home docker://pyfound/black:latest_release \
            black \
                --help
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
            echo " -v                    Show the software's version number"
            echo "                       and exit."
            echo " -h                    Show this help page and exit."
            echo ""
            echo "This script runs the black tool on an input python file."
            echo "Black is used to format python code and convert to PEP8."
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