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

#SBATCH --job-name="check-exomiser-logs"
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

check_files() {
    # The check_files function:
    #     This function loops over all files in a directory and check for the
    #     string java.io.IOException:, if present, it prints the file name.
    #directory="/mnt/titan/users/j.boom/logs/PASS_ONLY"
    directory="/mnt/titan/users/j.boom/logs/FULL"
    for file in  "${directory}"/*;
    do
        if grep -q "java\.io\.IOException:" "$file";
        then
            echo "$(basename "${file}")"
        fi
    done
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    check_files
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-check-exomiser-logs.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-check-exomiser-logs.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script loops over all files in a directory checking for"
            echo "a java error. If the error was reported, the filename is"
            echo "shown in the terminal."
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