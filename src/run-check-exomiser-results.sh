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

#SBATCH --job-name="check-exomiser-results"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/flashblade01/scratch/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/flashblade01/scratch/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

# Function to process each file
process_file() {
    file=$1

    # Count occurrences in KNOWN_CLASS and PREDICTED_CLASS columns
    total_benign_known=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Benign") count++} END{print count}' "$file")
    total_pathogenic_known=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Pathogenic") count++} END{print count}' "$file")
    total_benign_predicted=$(awk -F'\t' 'BEGIN{count=0} {if($20=="Benign") count++} END{print count}' "$file")
    total_pathogenic_predicted=$(awk -F'\t' 'BEGIN{count=0} {if($20=="Pathogenic") count++} END{print count}' "$file")

    # Calculate true positives, true negatives, false positives, and false negatives
    true_positives=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Pathogenic" && $20=="Pathogenic") count++} END{print count}' "$file")
    true_negatives=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Benign" && $20=="Benign") count++} END{print count}' "$file")
    false_positives=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Benign" && $20=="Pathogenic") count++} END{print count}' "$file")
    false_negatives=$(awk -F'\t' 'BEGIN{count=0} {if($19=="Pathogenic" && $20=="Benign") count++} END{print count}' "$file")

    # Output results
    echo "File: $file"
    echo "KNOWN_CLASS - Benign: $total_benign_known"
    echo "KNOWN_CLASS - Pathogenic: $total_pathogenic_known"
    echo "PREDICTED_CLASS - Benign: $total_benign_predicted"
    echo "PREDICTED_CLASS - Pathogenic: $total_pathogenic_predicted"
    echo "True Positives: $true_positives"
    echo "True Negatives: $true_negatives"
    echo "False Positives: $false_positives"
    echo "False Negatives: $false_negatives"
    echo "----------------------------------"
}

# Process each .tsv file in the current directory
for file in /mnt/flashblade01/scratch/j.boom/results/*.tsv; do
    process_file "$file"
done
