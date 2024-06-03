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

#SBATCH --job-name="neat-3.4"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_neat() {
    # The run_neat function:
    #     Contains all test code for running neat v3.4 code locally.
    #     This tool is python based, and seems to work. Sadly the most recent
    #     version (4.0) got recalled due to issues. The example below is the
    #     most basic way of generating reads and a vcf + bam file of simulated
    #     data. I still need to add a predefined VCF and random variant
    #     generator flag.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /mnt/titan/users/j.boom/tools/NEAT-3.4/gen_reads.py \
        -r "/mnt/titan/users/j.boom/tools/data/Homo_sapiens.GRCh37.dna.primary_assembly.chr.fa" \
        -R 147 \
        -o "/mnt/titan/users/j.boom/tools/simulated_data/R-${SLURM_JOB_NAME}-${SLURM_JOB_ID}" \
        -p 2 \
        -M 0.016 \
        -tr /mnt/titan/users/j.boom/capture-kit-bed-files/hg19/S31285117_Covered_50bpFlank.tiny.bed \
        -m "/mnt/titan/users/j.boom/tools/NEAT-3.4/models/MutModel_NA12878.pickle.gz" \
        --pe 300 30 \
        -v "/mnt/titan/users/j.boom/tools/NEAT-3.4/data/small.vcf" \
        --rng 1995 \
        --no-fastq \
        --vcf
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    run_neat
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
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
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs test commands for neat v3.4."
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