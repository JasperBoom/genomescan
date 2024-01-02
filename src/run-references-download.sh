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

#SBATCH --job-name="reference-download"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --time=1:15:0
#SBATCH --partition=all

genome_file="/mnt/titan/users/j.boom/tool-testing/data/Homo_sapiens.GRCh37.dna.primary_assembly.chr.fa"

add_chr_to_fasta() {
    # The add_chr_to_fasta function:
    #     This function adds a string "chr" at the start of each fasta record
    #     in the genome fasta file.
    #     https://okko73313.blogspot.com/2013/01/chromosome-names-with-chr-prefix-or.html
    cat ${genome_file} \
        | sed -r 's/^>/>chr/' \
        > "${genome_file::-3}.chr.fa"
}

download_genome() {
    # The download_genome function:
    #     This function downloads the reference genome fasta file.
    #     It also decompresses the downloaded file.
    wget \
        --directory-prefix="/mnt/titan/users/j.boom/tool-testing/data" \
        ftp://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    gzip \
        -d "${genome_file}.gz"
}

create_dictionary() {
    # The create_dictionary function:
    #     This function creates a dictionary using the genome reference using
    #     picard.
    singularity \
        exec \
            --containall \
           --bind /home docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0 \
            picard CreateSequenceDictionary \
                R=${genome_file} \
                O=${genome_file}.dict
}

create_genome_index() {
    # The create_genome_index function:
    #     This function creates an index using the genome reference using
    #     samtools.
    singularity \
        exec \
            --containall \
            --bind /home docker://quay.io/biocontainers/samtools:1.18--h50ea8bc_1 \
            samtools faidx \
                ${genome_file}
}

get_annotation() {
    # The get_annotation function:
    #     This function downloads the GTF annotation file for humans.
    wget \
        --directory-prefix="/mnt/titan/users/j.boom/tool-testing/data" \
        ftp://ftp.ensembl.org/pub/release-110/gtf/homo_sapiens/Homo_sapiens.GRCh38.110.gtf.gz
}

create_annotation_index() {
    # The create_annotation_index function:
    #     This function downloads the gtfToGenePred software and uses it to
    #     create and index for the GTF file.
    wget \
        --directory-prefix="/mnt/titan/users/j.boom/tool-testing/data" \
        http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred

    # Fix permissions:
    chmod 777 /mnt/titan/users/j.boom/tool-testing/data/gtfToGenePred
    gtf_file="/mnt/titan/users/j.boom/tool-testing/data/Homo_sapiens.GRCh38.110"
    gzip \
        -d "${gtf_file}.gtf.gz"

    # Run gtfToGenePred:
    /mnt/titan/users/j.boom/tool-testing/simulating-data/data/gtfToGenePred \
        -genePredExt \
        ${gtf_file}.gtf \
        /mnt/titan/users/j.boom/tool-testing/data/genePredFile.file

    # Isolate correct columns:
    awk 'BEGIN { OFS="\t"} {print $12, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' /mnt/titan/users/j.boom/tool-testing/data/genePredFile.file \
        > ${gtf_file}.refflat
}

main() {
    # The main function:
    #     This function simply calls the functions above so they are run
    #     when this script is called.
    #add_chr_to_fasta
    #download_genome
    create_dictionary
    create_genome_index
    #get_annotation
    #create_annotation_index
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-references-download.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-references-download.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs the commands for downloading reference"
            echo "files such as the genome and annotation, it also creates"
            echo "indexes for these files."
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
# hg19: https://ftp.ensembl.org/pub/grch37/current/
# hg38: https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/
