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

#SBATCH --job-name="family-data"
#SBATCH --mem=50G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_exomiser() {
    # The run_exomiser function:
    #     This function runs exomiser on the datasets.
    VCF=/mnt/flashblade01/scratch/j.boom/data/family/103003-007-071-12433993.hard-filtered.sorted.vcf
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://amazoncorretto:21.0.2-alpine3.19 \
            java \
                -Xms60g \
                -Xmx80g \
                -Djava.io.tmpdir=/mnt/flashblade01/scratch/j.boom/tmp \
                -jar /mnt/titan/users/j.boom/tools/Exomiser/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar \
                    --analysis "/mnt/flashblade01/scratch/j.boom/data/family/genome.v14.threshold.024.FULL.yaml" \
                    --assembly "GRCh37" \
                    --vcf "${VCF}" \
                    --spring.config.location=/mnt/titan/users/j.boom/tools/Exomiser/application.properties
}

run_vep() {
    # The run_vep function:
    #     This function runs vep on the datasets.
    INPUT_DIR="/mnt/flashblade01/scratch/j.boom/data/family"

    for VCF in "${INPUT_DIR}"/*.hard-filtered.sorted.vcf;
    do
        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://ensemblorg/ensembl-vep:release_111.0 \
                    vep \
                        --input_file "${VCF}" \
                        --output_file "${VCF::-3}annotated.vcf" \
                        --stats_file "${VCF::-3}annotated.stats.html" \
                        --species "human" \
                        --format "vcf" \
                        --assembly "GRCh37" \
                        --dir_cache "/mnt/titan/users/j.boom/data/vep" \
                        --dir_plugins "/mnt/titan/users/j.boom/data/vep/plugins" \
                        --vcf \
                        --cache \
                        --fork 10 \
                        --plugin "CADD,snv=/mnt/titan/users/j.boom/data/vep/plugins_data/whole_genome_SNVs.tsv.gz,indels=/mnt/titan/users/j.boom/data/vep/plugins_data/InDels.tsv.gz" \
                        --plugin "CAPICE,snv=/mnt/titan/users/j.boom/data/vep/plugins_data/capice_v1.0_build37_snvs.tsv.gz,indels=/mnt/titan/users/j.boom/data/vep/plugins_data/capice_v1.0_build37_indels.tsv.gz" \
                        --plugin "FATHMM_MKL,/mnt/titan/users/j.boom/data/vep/plugins_data/fathmm-MKL_Current.tab.gz"
    done
}

prepare_vcf_file() {
    # The prepare_vcf_file function:
    #     This function makes sure the datasets are sorted and indexed.
    INPUT_DIR="/mnt/flashblade01/scratch/j.boom/data/family"

    for VCF in "${INPUT_DIR}"/*.hard-filtered.vcf;
    do
        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0 \
                    picard SortVcf \
                        --INPUT "${VCF}" \
                        --OUTPUT "${VCF::-3}sorted.vcf" \
                        --TMP_DIR "/mnt/flashblade01/scratch/j.boom/tmp"

        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://quay.io/biocontainers/pbgzip:2016.08.04--h9d449c0_5 \
                pbgzip \
                    -n 5 \
                    "${VCF::-3}sorted.vcf"

        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
                tabix \
                    --preset "vcf" \
                    "${VCF::-3}sorted.vcf.gz";
    done
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    #prepare_vcf_file
    #run_vep
    run_exomiser
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-family-data.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-family-data.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs VEP, Exomiser and ranking to mimic the"
            echo "final pipeline, on the family data."
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