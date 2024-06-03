#!/usr/bin/env python3

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

# Imports:
import argparse


def test():
    # Example set of scores for a variant:
    cadd_phred = 32.0000
    cadd_raw = 4.5817
    capice = 0.0602
    fathmm_mkl_c = 0.9845
    fathmm_mkl_nc = 0.9950
    exomiser = 0.9760
    phen2gene = 15

    # Weights assigned to all scores, how important are they?
    cadd_phred_weight = 0.15
    cadd_raw_weight = 0.15
    capice_weight = 0.15
    fathmm_mkl_c_weight = 0.1
    fathmm_mkl_nc_weight = 0.1
    exomiser_weight = 0.2
    phen2gene_weight = 0.15

    # Normalize the scores to all match the same range of numbers:
    # Collect the lowest and highest value in the dataset for each score.
    # Then do min-maxing:
    #     (x - min) / (max - min)
    # This is not needed for CAPICE and EXOMISER, since they are already 0 to 1.
    cadd_phred_normalized = 0
    cadd_raw_normalized = 0
    capice_normalized = 0
    fathmm_mkl_c_normalized = 0
    fathmm_mkl_nc_normalized = 0
    exomiser_normalized = 0
    phen2gene_normalized = 0

    # Then calculate the overall score by adding up all normalized scores.
    # Make sure to first multiply each normalized score by their weight.
    overall_score = (
        (cadd_phred_normalized * cadd_phred_weight)
        + (cadd_raw_normalized * cadd_raw_weight)
        + (capice_normalized * capice_weight)
        + (fathmm_mkl_c_normalized * fathmm_mkl_c_weight)
        + (fathmm_mkl_nc_normalized * fathmm_mkl_nc_weight)
        + (exomiser_normalized * exomiser_weight)
        + (phen2gene_normalized * phen2gene_weight)
    )

    # IDEA:
    #     Maybe don´t use phen2gene directly in the score, but as a modifier.
    #     If the rank is closer to 1, give extra weight to the score.


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "."
    epilog = "This python script has no dependencies."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s [1.0]]"
    )
    argvs = parser.parse_args()
    return argvs


def main():
    """
    The main function:
        This function calls all processing functions in correct order.
    """
    user_arguments = parse_argvs()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
