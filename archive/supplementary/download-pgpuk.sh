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

#SBATCH --job-name="download-pgpuk"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

download_files() {
    # The download_files function:
    #     This function contains wget commands for downloading the PGP-UK data.

    ## FR07961005
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389534&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389534/FR07961005.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389534/FR07961005.pass.recode.vcf.gz.tbi

    ## FR07961008
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389529&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389529/FR07961008.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389529/FR07961008.pass.recode.vcf.gz.tbi

    ## FR07961006
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389524&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389524/FR07961006.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389524/FR07961006.pass.recode.vcf.gz.tbi

    ## FR07961009
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389527&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389527/FR07961009.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389527/FR07961009.pass.recode.vcf.gz.tbi

    ## FR07961000
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389532&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389532/FR07961000.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389532/FR07961000.pass.recode.vcf.gz.tbi

    ## FR07961001
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389530&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389530/FR07961001.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389530/FR07961001.pass.recode.vcf.gz.tbi

    ## FR07961003
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389525&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389525/FR07961003.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389525/FR07961003.pass.recode.vcf.gz.tbi

    ## FR07961004
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389531&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389531/FR07961004.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389531/FR07961004.pass.recode.vcf.gz.tbi

    ## FR07961002
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389528&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389528/FR07961002.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389528/FR07961002.pass.recode.vcf.gz.tbi
    
    ## FR07961007
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389526&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389526/FR07961007.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389526/FR07961007.pass.recode.vcf.gz.tbi

    ## PG0000894
    ## https://www.ebi.ac.uk/ena/browser/view/ERZ389533&display
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389533/PG0000894.pass.recode.vcf.gz
    wget \
        -nc \
        ftp://ftp.sra.ebi.ac.uk/vol1/ERZ389/ERZ389533/PG0000894.pass.recode.vcf.gz.tbi
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
    download_files
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
            echo "download-pgpuk.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: download-pgpuk.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script downloads vcf files from individuals from the"
            echo "personal genome project uk."
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
# https://www.personalgenomes.org.uk/data/