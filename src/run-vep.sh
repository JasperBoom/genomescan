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
#SBATCH --mem=15G
#SBATCH --cpus-per-task=5
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

create_benchmark_set(){
    # The create_benchmark_set function:
    #     This function contains commands used to create a sample set for
    #     benchmarking.
    #     Giab vcf files can be found here:
    #     https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/NISTv4.2.1/GRCh37/
    wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/NISTv4.2.1/GRCh37/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf.gz
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_111.0 \
                vep \
                    --input_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf" \
                    --output_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.annotated.maxaf.vcf" \
                    --stats_file "/mnt/titan/users/j.boom/vcf/giab/HG001_GRCh37_1_22_v4.2.1_benchmark.summary.maxaf.html" \
                    --species "human" \
                    --format "vcf" \
                    --assembly "GRCh37" \
                    --dir_cache "/mnt/titan/users/j.boom/r-analysis/vep" \
                    --dir_plugins "/mnt/titan/users/j.boom/r-analysis/vep/plugins" \
                    --vcf \
                    --cache \
                    --fork 8 \
                    --max_af
}

index_fathmm_mkl(){
    # The index_fathm_mkl function:
    #     This function creates an index of the fathmm mkl database using tabix.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://quay.io/biocontainers/tabix:1.11--hdfd78af_0 \
            tabix \
                -f \
                -p "bed" \
                "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/fathmm-MKL_Current.tab.gz"
}

index_alphamissense(){
    # The index_alphamissense function:
    #     This function creates an index of the alphamissenese database using
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
                "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/AlphaMissense_hg19.tsv.gz"
}

setup_bayesdel_plugin(){
    # The setup_bayesdel_plugin function:
    #     This function runs the bash commands required to setup the database
    #     for the bayesdel plugin. These commands are described in the vep
    #     plugin file for bayesdel.
    source /home/j.boom/miniconda3/bin/activate base
    tar \
        -zxvf "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF.tgz" \
        -C "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data"
    rm \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/*.gz.tbi
    gunzip \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/*.gz
    for file in /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_chr*;
    do
        grep -v "^#" ${file} \
            >> "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF.txt";
    done
    cat \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF.txt \
        | sort \
              -k1,1 \
              -k2,2n \
              > "/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_sorted.txt"
    grep \
        "^#" \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_chr1 \
        > /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_all_scores.txt
    cat \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_sorted.txt \
        >> /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_all_scores.txt
    bgzip \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_all_scores.txt
    tabix \
        -s 1 \
        -b 2 \
        -e 2 \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_all_scores.txt.gz
}

setup_revel_plugin(){
    # The setup_revel_plugin function:
    #     This function runs the bash commands required to setup the database
    #     for the revel plugin. These commands are described in the vep
    #     plugin file for revel.
    source /home/j.boom/miniconda3/bin/activate base
    unzip \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/revel-v1.3_all_chromosomes.zip
    cat \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/revel_with_transcript_ids \
        | tr "," "\t" \
            > /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/tabbed_revel.tsv
    sed \
        '1s/.*/#&/' \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/tabbed_revel.tsv \
        > /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/new_tabbed_revel.tsv
    bgzip /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/new_tabbed_revel.tsv
    tabix \
        -f \
        -s 1 \
        -b 2 \
        -e 2 \
        /mnt/titan/users/j.boom/r-analysis/vep/plugins_data/new_tabbed_revel.tsv.gz
}

install_plugins(){
    # The install_plugins function:
    #     This function will install vep plugins in the specified directory.
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
    #     Data for FATHMM-MKL:
    #         http://fathmm.biocompute.org.uk/database/fathmm-MKL_Current.tab.gz
    #     Data for BayesDel:
    #         Requires a google account to access.
    #         https://drive.google.com/drive/folders/1K4LI6ZSsUGBhHoChUtegC8bgCt7hbQlA
    #         tar -zxvf BayesDel_170824_addAF.tgz
    #         rm *.gz.tbi
    #         gunzip *.gz
    #         for f in BayesDel_170824_addAF_chr*; do grep -v "^#" $f >> BayesDel_170824_addAF.txt; done
    #         cat BayesDel_170824_addAF.txt | sort -k1,1 -k2,2n > BayesDel_170824_addAF_sorted.txt
    #         grep "^#" BayesDel_170824_addAF_chr1 > BayesDel_170824_addAF_all_scores.txt
    #         cat BayesDel_170824_addAF_sorted.txt >> BayesDel_170824_addAF_all_scores.txt
    #         bgzip BayesDel_170824_addAF_all_scores.txt
    #         tabix -s 1 -b 2 -e 2 BayesDel_170824_addAF_all_scores.txt.gz
    #     Data REVEL:
    #         https://sites.google.com/site/revelgenomics/downloads
    #         unzip revel-v1.3_all_chromosomes.zip
    #         cat revel_with_transcript_ids | tr "," "\t" > tabbed_revel.tsv
    #         sed '1s/.*/#&/' tabbed_revel.tsv > new_tabbed_revel.tsv
    #         bgzip new_tabbed_revel.tsv
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_111.0 \
                INSTALL.pl \
                    --CACHEDIR "/mnt/titan/users/j.boom/r-analysis/vep" \
                    --AUTO p \
                    --SPECIES homo_sapiens \
                    --ASSEMBLY GRCh37 \
                    --PLUGINS AlphaMissense,CADD,CAPICE,FATHMM_MKL,dbNSFP \
                    --PLUGINSDIR "/mnt/titan/users/j.boom/r-analysis/vep/plugins/"
}

install_cache(){
    # The install_cache function:
    #     This function installs the vep cache in the vep sif file using the
    #     perl install script. Sadly this didn´t seem to work.
    singularity pull --name vep.sif docker://ensemblorg/ensembl-vep:latest
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://ensemblorg/ensembl-vep:release_111.0 \
                INSTALL.pl \
                    --CACHEDIR "/mnt/titan/users/j.boom/r-analysis/vep" \
                    --AUTO cf \
                    --SPECIES homo_sapiens \
                    --ASSEMBLY GRCh37 \
                    --PLUGINS all \
                    --PLUGINSDIR "/mnt/titan/users/j.boom/r-analysis/vep/plugins/"
}

run_vep() {
    # The run_vep function:
    #     This function runs the vep annotation tool on all vcf files in the
    #     specified folder.
    #     https://www.ensembl.org/info/docs/tools/vep/script/vep_options.html
    for file in /mnt/titan/users/j.boom/r-analysis/pgpuk/FR07961009/*.vcf;
    do
        singularity \
            exec \
                --containall \
                --bind /mnt,/home \
                docker://ensemblorg/ensembl-vep:release_111.0 \
                    vep \
                        --input_file "${file}" \
                        --output_file "${file::-3}annotated.tab" \
                        --stats_file "${file::-3}summary.html" \
                        --species "human" \
                        --format "vcf" \
                        --assembly "GRCh37" \
                        --dir_cache "/mnt/titan/users/j.boom/r-analysis/vep" \
                        --dir_plugins "/mnt/titan/users/j.boom/r-analysis/vep/plugins" \
                        --tab \
                        --cache \
                        --fork 5 \
                        --plugin "AlphaMissense,file=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/AlphaMissense_hg19.tsv.gz" \
                        --plugin "CADD,snv=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/whole_genome_SNVs.tsv.gz,indels=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/InDels.tsv.gz" \
                        --plugin "CAPICE,snv=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/capice_v1.0_build37_snvs.tsv.gz,indels=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/capice_v1.0_build37_indels.tsv.gz" \
                        --plugin "FATHMM_MKL,/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/fathmm-MKL_Current.tab.gz" \
                        --custom file=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/clinvar.vcf.gz,short_name=ClinVar,format=vcf,type=exact,coords=0,fields=CLNSIG \
                        --plugin "BayesDel,file=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/BayesDel_170824_addAF/BayesDel_170824_addAF_all_scores.txt.gz" \
                        --plugin "REVEL,file=/mnt/titan/users/j.boom/r-analysis/vep/plugins_data/new_tabbed_revel.tsv.gz";
    done
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
    #setup_bayesdel_plugin
    #setup_revel_plugin
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