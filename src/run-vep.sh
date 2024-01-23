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

#SBATCH --job-name="vep"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --time=200:15:0
#SBATCH --partition=all

create_benchmark_set(){
    # The create_benchmark_set function:
    #     This function contains commands used to create a sample set for
    #     benchmarking.
    #     Giab vcf files can be found here:
    #     https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/NISTv4.2.1/GRCh37/
    source /home/j.boom/mambaforge/bin/activate base
    #wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/NISTv4.2.1/GRCh37/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf.gz
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_110.1 \
                vep \
                    --input_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf" \
                    --output_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.annotated.maxaf.vcf" \
                    --stats_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.summary.maxaf.html" \
                    --species "human" \
                    --format "vcf" \
                    --assembly "GRCh37" \
                    --dir_cache "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37" \
                    --dir_plugins "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins" \
                    --vcf \
                    --cache \
                    --fork 8 \
                    --max_af
}

index_fathmm_mkl(){
    # The index_fathm_mkl function:
    #     This function creates an index of the FATHMM MKL database using tabix.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
            tabix \
                -f \
                -p "bed" \
                "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/fathmm-MKL_Current.tab.gz"
}

index_alphamissense(){
    # The index_alphamissense function:
    #     This function creates an index of the AlphaMissenese database using
    #     tabix.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
            tabix \
                -s 1 \
                -b 2 \
                -e 2 \
                -f \
                -S 1 \
                "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/AlphaMissense_hg19.tsv.gz"
}

install_plugins(){
    # The install_plugins function:
    #     This function will install VEP plugins in the specified directory.
    #     It also includes the link to the individual files for downloading
    #     manually. There are some steps like indexing after download that are
    #     described in the readme's for each annotation source.
    #     AlphaMissense:
    #         https://storage.googleapis.com/dm_alphamissense/AlphaMissense_hg19.tsv.gz
    #         tabix -s 1 -b 2 -e 2 -f -S 1 AlphaMissense_hg19.tsv.gz
    #     Data for CADD:
    #         https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz
    #         https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz.tbi
    #         https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh37/InDels.tsv.gz
    #         https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh37/InDels.tsv.gz.tbi
    #     Data for CAPICE:
    #         https://zenodo.org/records/3928295/files/capice_v1.0_build37_snvs.tsv.gz
    #         https://zenodo.org/records/3928295/files/capice_v1.0_build37_snvs.tsv.gz.tbi
    #         https://zenodo.org/records/3928295/files/capice_v1.0_build37_indels.tsv.gz
    #         https://zenodo.org/records/3928295/files/capice_v1.0_build37_indels.tsv.gz.tbi
    #     Data for FATHMM:
    #         https://raw.github.com/HAShihab/fathmm/master/cgi-bin/fathmm.py
    #         http://fathmm.biocompute.org.uk/database/fathmm.v2.3.SQL.gz
    #     Data for FATHMM-MKL:
    #         http://fathmm.biocompute.org.uk/database/fathmm-MKL_Current.tab.gz
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_110.1 \
                INSTALL.pl \
                    --CACHEDIR "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37" \
                    --AUTO p \
                    --SPECIES homo_sapiens \
                    --ASSEMBLY GRCh37 \
                    --PLUGINS AlphaMissense,CADD,CAPICE,FATHMM,FATHMM_MKL,dbNSFP \
                    --PLUGINSDIR "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins/"
}

install_cache(){
    # The install_cache function:
    #     This function install the VEP cache in the VEP sif file using the
    #     perl install script. Sadly this didn´t seem to work.
    #singularity pull --name vep.sif docker://ensemblorg/ensembl-vep:latest
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_110.1 \
                INSTALL.pl \
                    --CACHEDIR "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37" \
                    --AUTO cf \
                    --SPECIES homo_sapiens \
                    --ASSEMBLY GRCh37 \
                    --PLUGINS all \
                    --PLUGINSDIR "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins/"
}

run_vep() {
    # The run_vep function:
    #     This function runs the VEP annotation tool on all vcf files in the
    #     specified folder.
    #     https://www.ensembl.org/info/docs/tools/vep/script/vep_options.html
    #     mysql -h localhost -P 3307 -u j.boom -p 12345 -e "CREATE DATABASE fathmm"
    #     mysql -h localhost -P 3307 -u j.boom -p 12345 -Dfathmm < /mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/fathmm.v2.3.SQL
    source /home/j.boom/mambaforge/bin/activate base
    for file in /mnt/titan/users/j.boom/vcf/personalgenomesuk/*.vcf.gz;
    do
        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://ensemblorg/ensembl-vep:release_110.1 \
                    vep \
                        --input_file "${file}" \
                        --output_file "${file::-3}annotated.tab" \
                        --stats_file "${file::-3}summary.html" \
                        --species "human" \
                        --format "vcf" \
                        --assembly "GRCh37" \
                        --dir_cache "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37" \
                        --dir_plugins "/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins" \
                        --tab \
                        --cache \
                        --fork 8 \
                        --sift "b" \
                        --polyphen "b" \
                        --af \
                        --max_af \
                        --af_gnomade \
                        --plugin "AlphaMissense,file=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/AlphaMissense_hg19.tsv.gz" \
                        --plugin "CADD,snv=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/whole_genome_SNVs.tsv.gz,indels=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/InDels.tsv.gz" \
                        --plugin "CAPICE,snv=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/capice_v1.0_build37_snvs.tsv.gz,indels=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/capice_v1.0_build37_indels.tsv.gz" \
                        --plugin "FATHMM_MKL,/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/fathmm-MKL_Current.tab.gz" \
                        --custom file=/mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/clinvar.vcf.gz,short_name=ClinVar,format=vcf,type=exact,coord=0,fields=CLNSIG;
    done
    # --plugin "FATHMM,python /mnt/titan/users/j.boom/tool-testing/vep/vep_grch37/plugins_data_20240117/fathmm.py";
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    #install_cache
    run_vep
    #index_alphamissense
    #install_plugins
    #index_fathmm_mkl
    #create_benchmark_set
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-vep.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-vep.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs vep or supporting commands like indexing"
            echo "annotation databases or downloading reference files."
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