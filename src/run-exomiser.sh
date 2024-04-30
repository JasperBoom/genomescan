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

#SBATCH --job-name="exomiser"
#SBATCH --mem=80G
#SBATCH --cpus-per-task=3
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

run_version_14() {
    # The run_version_14 function:
    #     This function runs the newest version of Exomiser which includes a
    #     lot of updates and a new version of the input databases (which are
    #     now much smaller).
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://amazoncorretto:21.0.2-alpine3.19 \
            java \
                -Xms60g \
                -Xmx80g \
                -Djava.io.tmpdir=/mnt/titan/users/j.boom/tmp \
                -jar /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar \
                    --analysis "/home/j.boom/develop/genomescan/src/genome.v14.yml" \
                    --assembly "GRCh37" \
                    --vcf "/mnt/titan/users/j.boom/r-analysis/2024-02-29-exomiser-thresholding/FR07961000.pathogenic.general.test.vcf" \
                    --spring.config.location=/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties \
                    2>&1 | tee /mnt/titan/users/j.boom/tool-testing/Exomiser/results/command.v14.log
}

run_exomiser_docker() {
    # The run_exomiser_docker function:
    #     This function uses a java container to run the exomiser program in.
    #     This uses the version 13 of Exomiser.
    singularity \
        exec \
            --containall \
            --bind /mnt,/home \
            docker://amazoncorretto:21.0.2-alpine3.19 \
            java \
                -Xms15g \
                -Xmx20g \
                -Djava.io.tmpdir=/mnt/titan/users/j.boom/tmp \
                -jar /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
                    --analysis "/mnt/titan/users/j.boom/tool-testing/Exomiser/genome.v13.yml" \
                    --assembly "GRCh37" \
                    --vcf "/mnt/titan/users/j.boom/r-analysis/2024-02-29-exomiser-thresholding/FR07961000.pathogenic.general.test.vcf" \
                    --spring.config.location=/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties.v13 \
                    2>&1 | tee /mnt/titan/users/j.boom/tool-testing/Exomiser/results/command.v13.log
}

run_test() {
    # The run_test function:
    #     This function runs a test set from the exomiser repository.
    java \
        -jar /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
            --spring.config.location=/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties.v13 \
            --sample /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/examples/pfeiffer-phenopacket.yml \
            --vcf /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/examples/Pfeiffer.vcf.gz \
            --assembly hg19
}

run_exomiser() {
    # The run_exomiser function:
    #     Contains all test code for running exomiser.
    #     As seen below, the tool is java based. It also has a version on
    #     conda, but this doesn't seem to run the same jar file as is
    #     downloaded via git.
    #     The example data doesn't work for some reason, missing some input
    #     either because the files are incomplete or the example command is
    #     incomplete.
    java \
        -Xms15g \
        -Xmx20g \
        -Djava.io.tmpdir=/mnt/titan/users/j.boom/tmp \
        -jar /mnt/titan/users/j.boom/tool-testing/Exomiser/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
            --analysis "/mnt/titan/users/j.boom/tool-testing/Exomiser/genome.yml" \
            --assembly "GRCh37" \
            --vcf "/mnt/titan/users/j.boom/r-analysis/2024-02-29-exomiser-thresholding/FR07961000.pathogenic.general.vcf" \
            --spring.config.location=/mnt/titan/users/j.boom/tool-testing/Exomiser/application.properties \
            2>&1 | tee /mnt/titan/users/j.boom/tool-testing/Exomiser/results/command.v13.log
}

main() {
    # The main function:
    #     This function runs all processing function in correct order.
    #run_exomiser_docker
    #run_exomiser
    #run_test
    run_version_14
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-exomiser.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-exomiser.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs test commands for exomiser. It is used as"
            echo "an example for how to run Exomiser in general."
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