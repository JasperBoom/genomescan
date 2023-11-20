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

#SBATCH --job-name="exomizer"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/exomiser.log"
#SBATCH --error="/home/j.boom/errors/exomiser.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

#exomiser-rest-prioritiser \
#    --analysis /home/j.boom/tool-testing/exomiser-cli-13.3.0/examples/NA19722_601952_AUTOSOMAL_RECESSIVE_POMP_13_29233225_5UTR_38.yml

#java \
#    -Xms4g \
#    -Xmx8g \
#    -jar /home/j.boom/tool-testing/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar

#java \
#    -Xms4g \
#    -Xmx8g \
#    -jar /home/j.boom/tool-testing/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
#    --analysis /home/j.boom/tool-testing/exomiser-cli-13.3.0/examples/NA19722_601952_AUTOSOMAL_RECESSIVE_POMP_13_29233225_5UTR_38.yml

java \
    -Xms2g \
    -Xmx4g \
    -jar /home/j.boom/tool-testing/exomiser-cli-13.3.0/exomiser-cli-13.3.0.jar \
    --prioritiser=hiphive \
    -I AD \
    -F 1 \
    -D OMIM:101600 \
    -v /home/j.boom/tool-testing/exomiser-cli-13.3.0/examples/Pfeiffer.vcf