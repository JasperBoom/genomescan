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
#SBATCH --partition=all

download_variation_ids() {
    # The download_variation_ids function:
    #     This function contains examples of how to search the clinvar database
    #     using a rest api, the first command retrieves pathogenic variation
    #     ids for a specific diseaese (search term), the second retrieves the
    #     record for a variation id.
    source /home/j.boom/miniconda3/bin/activate base
    wget \
        --verbose \
        --output-document="/mnt/titan/users/j.boom/test-data/api.txt" \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=clinvar&term=ependymomas+AND+single_gene+AND+(("clinsig+pathogenic"))&retmax=5000&retmode=json"
    wget \
        --verbose \
        --output-document="/mnt/titan/users/j.boom/test-data/gene.txt" \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=clinvar&id=13919&retmode=json"
}

run_python_script() {
    # The run_python_script function:
    #     This function runs the python script benchmark.py.
    #     The main subject is meningioma.
    #     https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/
    #     Brain tumours: astrocytomas,oligodendroglioma,glioblastoma,
    #                    craniopharyngioma,ependymoma,medulloblastoma,glioma
    #     Cancer in general: breast,prostate,lung,bronchus,colon,rectum,
    #                        pancreas,cancer,tumour
    #     TODO #FIX THE FIRST VARIANT IS ON THE SAME LINE AS THE HEADERS IN VCF
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/benchmark.py \
        --giab "/mnt/titan/users/j.boom/r-analysis/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.annotated.maxaf.vcf" \
        --disease-groups "breast,prostate,lung,bronchus,colon,rectum,pancreas,cancer,tumour" \
        --clinvar "/mnt/titan/users/j.boom/r-analysis/clinvar/clinvar_20240206.vcf" \
        --header "/mnt/titan/users/j.boom/test-data/default-vcf-header.txt" \
        --output "/mnt/titan/users/j.boom/test-data/clinvar-giab-test-data/giab-clinvar.vcf" \
        --pathogenic "/mnt/titan/users/j.boom/test-data/clinvar-giab-test-data/pathogenic.vcf" \
        --benign "/mnt/titan/users/j.boom/test-data/clinvar-giab-test-data/benign.vcf"
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
            echo "set of mutations on which thresholds can be determined."
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