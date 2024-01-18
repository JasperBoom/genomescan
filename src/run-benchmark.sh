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

#SBATCH --job-name="benchmark"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --time=1:15:0
#SBATCH --partition=all

download_variation_ids() {
    # The download_variation_ids function:
    #     This function contains examples of how to search the clinvar database
    #     using a rest api, the first command retrieves pathogenic variation
    #     ids for a specific diseaese (search term), the second retrieves the
    #     record for a variation id.
    wget \
        --verbose \
        --output-document="/home/j.boom/develop/genomescan/data/api.txt" \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=clinvar&term=ependymomas+AND+single_gene+AND+(("clinsig+pathogenic"))&retmax=5000&retmode=json"

    wget \
        --verbose \
        --output-document="/home/j.boom/develop/genomescan/data/gene.txt" \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=clinvar&id=13919&retmode=json"
}

run_python_script() {
    # The run_python_script function:
    #     This function runs the python script benchmark.py.
    source /home/j.boom/mambaforge/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/benchmark.py \
        --giab "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.annotated.maxaf.vcf" \
        --disease-groups "meningioma,ependymomas" \
        --clinvar "/mnt/titan/users/j.boom/clinvar/clinvar.grch37.vcf" \
        --header "/home/j.boom/develop/genomescan/data/default-vcf-header.txt" \
        --output "/home/j.boom/develop/genomescan/data/benchmark-vcf/benchmark.vcf" \
        --pathogenic "/home/j.boom/develop/genomescan/data/benchmark-vcf/pathogenic.vcf" \
        --benign "/home/j.boom/develop/genomescan/data/benchmark-vcf/benign.vcf"
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    run_python_script
    #download_variation_ids
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
            echo "run-benchmark.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-benchmark.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the benchmark script that generates a test"
            echo "set of mutations on which threshold can be determined."
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