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

#SBATCH --job-name="exomizer"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/exomiser.log"
#SBATCH --error="/home/j.boom/errors/exomiser.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     Contains all test code for running exomizer.
    #     As seen below, the tool is java based. It also has a version on
    #     conda, but this doesn't seem to run the same jar file as is
    #     downloaded via Git.
    #     The example data doesn't work for some reason, missing some input
    #     either because the files are incomplete or the example command is
    #     incomplete.
    java \
        -Xms2g \
        -Xmx4g \
        -jar /home/j.boom/tool-testing/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
            --prioritiser=hiphive \
            -I AD \
            -F 1 \
            -D OMIM:101600 \
            -v /home/j.boom/tool-testing/exomiser-cli-13.3.0/examples/Pfeiffer.vcf
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-exomizer.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-exomizer.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs trial commands for testing exomizer on the"
            echo "GenomeScan HPC."
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