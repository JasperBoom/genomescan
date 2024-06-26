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

#SBATCH --job-name="meningioma-test-set"
#SBATCH --mem=200G
#SBATCH --cpus-per-task=5
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

#INPUT_VCF="/mnt/flashblade01/scratch/j.boom/data/FR07961000.pathogenic.general.vcf"
#INPUT_VCF="/mnt/flashblade01/scratch/j.boom/data/FR07961001.pathogenic.general.vcf"
INPUT_VCF="/mnt/flashblade01/scratch/j.boom/data/FR07961006.pathogenic.meningioma.vcf"

run_monte_carlo_simulation() {
    # The run_monte_carlo_simulation function:
    #     This function uses a python script to run a Monte-Carlo simulation
    #     on the ranked variants in order to determine the performance.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/monte-carlo-simulation.py \
        --tsv "/mnt/flashblade01/scratch/j.boom/data/FR07961006.ranking.tsv"
}

run_ranking() {
    # The run_ranking function:
    #     This function runs the python script that takes care of ranking the
    #     variants in pathogenic order.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/rank-variants.py \
        --phen2gene "/mnt/flashblade01/scratch/j.boom/phen2gene/meningioma.associated_gene_list" \
        --filtered-vcf "/mnt/flashblade01/scratch/j.boom/data/FR07961006.pathogenic.meningioma.fixed.sorted.annotated.vep.filtered.exomiser.024.passonly.vcf" \
        --output "/mnt/flashblade01/scratch/j.boom/data/FR07961006.ranking"
}

run_exomiser() {
    # The run_exomiser function:
    #     This function runs exomiser on the test dataset.
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
                    --analysis "/home/j.boom/develop/genomescan/src/genome.v14.threshold.024.PASSONLY.yml" \
                    --assembly "GRCh37" \
                    --vcf "${INPUT_VCF::-3}fixed.sorted.annotated.vep.filtered.vcf" \
                    --spring.config.location=/mnt/titan/users/j.boom/tools/Exomiser/application.properties
}

filter_vep() {
    # The filter_vep function:
    #     This function runs a python script to filter a vcf file annotated by
    #     vep based on predetermined thresholds.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/filter-vep-vcf.py \
        --vcf "${INPUT_VCF::-3}fixed.sorted.annotated.vcf"
}

run_vep() {
    # The run_vep function:
    #     This function runs vep on the test dataset.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_111.0 \
                vep \
                    --input_file "${INPUT_VCF::-3}fixed.sorted.vcf" \
                    --output_file "${INPUT_VCF::-3}fixed.sorted.annotated.vcf" \
                    --stats_file "${INPUT_VCF::-3}fixed.sorted.annotated.stats.html" \
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
}

prepare_vcf_file() {
    # The prepare_vcf_file function:
    #     This function makes sure the test dataset is sorted and indexed.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0 \
                picard SortVcf \
                    --INPUT "${INPUT_VCF::-3}fixed.vcf" \
                    --OUTPUT "${INPUT_VCF::-3}fixed.sorted.vcf" \
                    --TMP_DIR "/mnt/flashblade01/scratch/j.boom/tmp"

    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/pbgzip:2016.08.04--h9d449c0_5 \
            pbgzip \
                -n 5 \
                "${INPUT_VCF::-3}fixed.sorted.vcf"

    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
            tabix \
                --preset "vcf" \
                "${INPUT_VCF::-3}fixed.sorted.vcf.gz";
}

add_class_info() {
    # The add_class_info function:
    #     This function runs a python script to add class info to the vcf file.
    source /home/j.boom/miniconda3/bin/activate base
    python3 /home/j.boom/develop/genomescan/src/python/prepare-exomiser-files.py \
        --vcf "${INPUT_VCF}" \
        --update
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    #add_class_info
    #prepare_vcf_file
    #run_vep
    #filter_vep
    #run_exomiser
    #run_ranking
    run_monte_carlo_simulation
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-meningioma-test-set.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-meningioma-test-set.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs VEP, Exomiser and ranking to mimic the"
            echo "final pipeline."
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