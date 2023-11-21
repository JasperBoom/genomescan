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

#SBATCH --job-name="neat-4.0"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/home/j.boom/logs/neat-4.0.log"
#SBATCH --error="/home/j.boom/errors/neat-4.0.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

source /home/j.boom/mambaforge/bin/activate neat

time_stamp="$(date +"%d-%m-%y-%T")"

neat \
    read-simulator \
    -c "/home/j.boom/genomescan/src/template_neat_config.yml" \
    -o "/home/j.boom/tool-testing/simulated_data/${time_stamp}"