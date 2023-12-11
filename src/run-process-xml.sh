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

#SBATCH --job-name="process-xml"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/process-xml.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/process-xml.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

run_python_script() {
    # The run_python_script function:
    #  
    source /mnt/titan/users/j.boom/mambaforge/bin/activate base
    python3 \
        "/mnt/titan/users/j.boom/develop/genomescan/src/process-xml.py" \
            -i "/mnt/titan/users/j.boom/clinvar/clinvar_small.xml" \
            2>&1 | tee "/mnt/titan/users/j.boom/logs/tee-process-xml.log"
}

main() {
    # The main function:
    #     
    run_python_script
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-process-xml.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-process-xml.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the python script process-xml.py on the"
            echo "GenomeScan HPC cluster."
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
# The ClinVar database vcf file: https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/
# The ClinVar database xml file: https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/
# The clinvar directory files/folders:
#     ClinVarFullRelease_00-latest.xml (the XML version of the full ClinVar
#                                       database).
#     clinvar.vcf (the VCF version of the full ClinVar database).
#     gene_comparison.txt (the output of this script comparing the gene list
#                          from alicia to the one from ClinVar).
#     gene_list_alicia.txt (genes found by Alicia that are associated to
#                           meningiomas, there is also a sorted version in this
#                           folder).
#     gene_list_script_meningioma-variants.txt (genes found by me using the
#                                               ClinVar website, also a sorted
#                                               version present).
#     stats.txt (the output from the first function in this script, simply
#                counting the number of genes found through variations on
#                downloading variants for meningioma).
#     ./clinvar_website_search (intermediate files used in the first function,
#                               see the description there for more information).
