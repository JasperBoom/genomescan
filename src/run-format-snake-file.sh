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

#SBATCH --job-name="format-snake-file"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/format-snake-file.log"
#SBATCH --error="/home/j.boom/errors/format-snake-file.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

main() {
    # The main function:
    #     This function runs snakefmt in singularity to format an input
    #     snake file.
    singularity \
        exec \
            --containall \
           --bind /home docker://quay.io/biocontainers/snakefmt:0.8.5--pyhdfd78af_0 \
            snakefmt \
                --line-length 80 \
                --verbose \
                /home/j.boom/develop/genomescan/snakemake-tutorial/snakefile.smk
                # /home/j.boom/develop/genomescan/snakemake-tutorial/rules/read-mapping.smk
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="i:vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        i)
            snake_file=${OPTARG}
            ;;
        v)
            echo ""
            echo "run-format-snake-file.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-format-snake-file.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v                    Show the software's version number"
            echo "                       and exit."
            echo " -h                    Show this help page and exit."
            echo ""
            echo "This script runs the snakefmt tool on an input snakefile."
            echo "Black is used to format python code and snake code is"
            echo "formatted to adhere to something similar to PEP8."
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
# https://github.com/snakemake/snakefmt