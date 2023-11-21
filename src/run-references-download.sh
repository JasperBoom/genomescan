#!/usr/bin/env bash

# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.

#SBATCH --job-name="reference_download"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/reference_download.log"
#SBATCH --error="/home/j.boom/errors/reference_download.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

# Reference genome:
wget \
    --directory-prefix="/home/j.boom/tool-testing/data" \
    ftp://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
genome_file="/home/j.boom/tool-testing/data/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
gzip \
    -d "${genome_file}.gz"

# Create dictionary:
singularity \
    exec \
        --containall \
        --bind /home docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0 \
        picard CreateSequenceDictionary \
            R=${genome_file} \
            O=${genome_file}.dict

# Create genome index:
singularity \
    exec \
        --containall \
        --bind /home docker://quay.io/biocontainers/samtools:1.18--h50ea8bc_1 \
        samtools faidx \
            ${genome_file}

# Reference annotation:
wget \
    --directory-prefix="/home/j.boom/tool-testing/data" \
    ftp://ftp.ensembl.org/pub/release-110/gtf/homo_sapiens/Homo_sapiens.GRCh38.110.gtf.gz

# Download gtfToGenePred:
wget \
    --directory-prefix="/home/j.boom/tool-testing/data" \
    http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred

# Fix permissions:
chmod 777 /home/j.boom/tool-testing/data/gtfToGenePred
gtf_file="/home/j.boom/tool-testing/data/Homo_sapiens.GRCh38.110"
gzip \
    -d "${gtf_file}.gtf.gz"

# Run gtfToGenePred:
/home/j.boom/tool-testing/simulating-data/data/gtfToGenePred \
    -genePredExt \
    ${gtf_file}.gtf \
    /home/j.boom/tool-testing/data/genePredFile.file

# Isolate correct columns:
awk 'BEGIN { OFS="\t"} {print $12, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' /home/j.boom/tool-testing/data/genePredFile.file \
    > ${gtf_file}.refflat