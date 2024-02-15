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

#SBATCH --job-name="picard"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

main() {
    # The main function:
    #     This function runs pbgzip and picard in order to sort, compress and
    #     index the input vcf files.
    source /home/j.boom/mambaforge/bin/activate base
    for file in /mnt/titan/users/j.boom/clinvar/*.vcf;
    do
        singularity \
            exec \
                --containall \
                --bind /mnt \
                docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0 \
                picard SortVcf \
                    --INPUT "${file}" \
                    --OUTPUT "${file::-3}sorted.vcf" \
                    --TMP_DIR "/mnt/titan/users/j.boom/tmp"

        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://quay.io/biocontainers/pbgzip:2016.08.04--h9d449c0_4 \
                pbgzip \
                    -n 5 \
                    "${file::-3}sorted.vcf"

        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
                tabix \
                    --preset "vcf" \
                    "${file::-3}sorted.vcf.gz";
    done
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
            echo "run-picard.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-picard.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs pbgzip and picard in order to sort,"
            echo "compress and index input vcf files."
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