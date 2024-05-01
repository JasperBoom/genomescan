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
import json
import requests
import numpy as np
import pandas as pd


def extract_annotation(file):
    """
    The extract_annotation function:
        This function selects the columns of interest containing just the
        annotation added by vep.
    """
    column_names = [
        "Uploaded_variation",
        "Consequence",
        "IMPACT",
        "CADD_PHRED",
        "CADD_RAW",
        "CAPICE_SCORE",
        "FATHMM_MKL_C",
        "FATHMM_MKL_NC",
        "ClinVar_CLNSIG",
    ]
    annotation = file[column_names]
    return annotation


def replace_clinvar_column(file, clinvar_file, skip, clinvar_skip, output_file):
    """
    The replace_clinvar_column file:
        This function reads in the truth set created using clinvar and
        benchmark.py. The uk personal genome variant set is converted to purely
        benign variants. These two tables are then merged and written to a file.
    """
    truth_set = extract_annotation(
        read_tabular(
            clinvar_file,
            clinvar_skip,
        )
    )
    truth_set_dedup = truth_set.drop_duplicates(
        subset="Uploaded_variation", keep="first"
    )
    personal_genome = extract_annotation(file)
    personal_genome.loc[
        personal_genome["ClinVar_CLNSIG"] != "Benign", "ClinVar_CLNSIG"
    ] = "Benign"
    personal_genome_dedup = personal_genome.drop_duplicates(
        subset="Uploaded_variation", keep="first"
    )
    pd.concat([personal_genome_dedup, truth_set_dedup], axis=0).to_csv(
        output_file,
        sep="\t",
        index=False,
        header=True,
    )


def read_tabular(path, skip):
    """
    The read_tabular function:
        This function reads in a tabular file, skips the number of rows
        indicated by "skip" and converts dash values tot nan.
    """
    file = pd.read_table(
        path,
        sep="\t",
        skiprows=skip,
        na_values="-",
        keep_default_na=True,
        low_memory=False,
    )
    return file


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This python script combines an individuals tsv file with\
                   pathogenic variants extracted from clinvar. This combined\
                   tsv is deduplicated and only the interesting annotation\
                   columns are kept."
    epilog = "This python script has one dependencie: pandas"
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-t",
        "--tab",
        action="store",
        dest="tab_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input tabular file containing variants and annotation.",
    )
    parser.add_argument(
        "-s",
        "--skip",
        action="store",
        dest="skip_lines",
        type=int,
        default=argparse.SUPPRESS,
        help="The number of lines to skip when reading in the main sample\
              tabular file.",
    )
    parser.add_argument(
        "-k",
        "--clinvar-skip",
        action="store",
        dest="clinvar_skip_lines",
        type=int,
        default=argparse.SUPPRESS,
        help="The number of lines to skip when reading in the clinvar\
              tabular file.",
    )
    parser.add_argument(
        "-c",
        "--clinvar",
        action="store",
        dest="clinvar_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The clinvar tabular file containing pathogenic variants.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The output file location.",
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
    variant_file = read_tabular(
        user_arguments.tab_file, user_arguments.skip_lines
    )
    replace_clinvar_column(
        variant_file,
        user_arguments.clinvar_file,
        user_arguments.skip_lines,
        user_arguments.clinvar_skip_lines,
        user_arguments.output_file,
    )


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
