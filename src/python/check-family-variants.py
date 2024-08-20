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
import pandas as pd


def find_common_rows_two(files, common_identifiers, family, output_folder):
    common_rows = []
    for identifier in common_identifiers:
        row1 = files[0][files[0]["ID"] == identifier].iloc[0]
        row2 = files[1][files[1]["ID"] == identifier].iloc[0]
        common_rows.append(
            {
                "CHROM": row1["CHROM"],
                "POS": row1["POS"],
                "REF": row1["REF"],
                "ALT": row1["ALT"],
                "CADD_PHRED": row1["CADD_PHRED"],
                "CADD_RAW": row1["CADD_RAW"],
                "CAPICE_SCORE": row1["CAPICE_SCORE"],
                "FATHMM_MKL_C": row1["FATHMM_MKL_C"],
                "FATHMM_MKL_NC": row1["FATHMM_MKL_NC"],
                "EXOMISER_GENE_COMBINED_SCORE": row1[
                    "EXOMISER_GENE_COMBINED_SCORE"
                ],
                "PHEN2GENE_RANK": row1["PHEN2GENE_RANK"],
                "VARIANT_SCORE": row1["VARIANT_SCORE"],
                "ROW_NUM_ONE": row1["ROW_NUM"],
                "ROW_NUM_TWO": row2["ROW_NUM"],
            }
        )
    common_df = pd.DataFrame(common_rows)
    common_df = common_df.sort_values(by="VARIANT_SCORE", ascending=False)
    common_df.to_csv(
        output_folder + family + "-COMMON-ROWS-TWO.tsv", sep="\t", index=False
    )


def find_common_rows_three(files, common_identifiers, family, output_folder):
    common_rows = []
    for identifier in common_identifiers:
        row1 = files[0][files[0]["ID"] == identifier].iloc[0]
        row2 = files[1][files[1]["ID"] == identifier].iloc[0]
        row3 = files[2][files[2]["ID"] == identifier].iloc[0]
        common_rows.append(
            {
                "CHROM": row1["CHROM"],
                "POS": row1["POS"],
                "REF": row1["REF"],
                "ALT": row1["ALT"],
                "CADD_PHRED": row1["CADD_PHRED"],
                "CADD_RAW": row1["CADD_RAW"],
                "CAPICE_SCORE": row1["CAPICE_SCORE"],
                "FATHMM_MKL_C": row1["FATHMM_MKL_C"],
                "FATHMM_MKL_NC": row1["FATHMM_MKL_NC"],
                "EXOMISER_GENE_COMBINED_SCORE": row1[
                    "EXOMISER_GENE_COMBINED_SCORE"
                ],
                "PHEN2GENE_RANK": row1["PHEN2GENE_RANK"],
                "VARIANT_SCORE": row1["VARIANT_SCORE"],
                "ROW_NUM_ONE": row1["ROW_NUM"],
                "ROW_NUM_TWO": row2["ROW_NUM"],
                "ROW_NUM_THREE": row3["ROW_NUM"],
            }
        )
    common_df = pd.DataFrame(common_rows)
    common_df = common_df.sort_values(by="VARIANT_SCORE", ascending=False)
    common_df.to_csv(
        output_folder + family + "-COMMON-ROWS-THREE.tsv", sep="\t", index=False
    )


def find_common_rows_four(files, common_identifiers, family, output_folder):
    common_rows = []
    for identifier in common_identifiers:
        row1 = files[0][files[0]["ID"] == identifier].iloc[0]
        row2 = files[1][files[1]["ID"] == identifier].iloc[0]
        row3 = files[2][files[2]["ID"] == identifier].iloc[0]
        row4 = files[3][files[3]["ID"] == identifier].iloc[0]
        common_rows.append(
            {
                "CHROM": row1["CHROM"],
                "POS": row1["POS"],
                "REF": row1["REF"],
                "ALT": row1["ALT"],
                "CADD_PHRED": row1["CADD_PHRED"],
                "CADD_RAW": row1["CADD_RAW"],
                "CAPICE_SCORE": row1["CAPICE_SCORE"],
                "FATHMM_MKL_C": row1["FATHMM_MKL_C"],
                "FATHMM_MKL_NC": row1["FATHMM_MKL_NC"],
                "EXOMISER_GENE_COMBINED_SCORE": row1[
                    "EXOMISER_GENE_COMBINED_SCORE"
                ],
                "PHEN2GENE_RANK": row1["PHEN2GENE_RANK"],
                "VARIANT_SCORE": row1["VARIANT_SCORE"],
                "ROW_NUM_ONE": row1["ROW_NUM"],
                "ROW_NUM_TWO": row2["ROW_NUM"],
                "ROW_NUM_THREE": row3["ROW_NUM"],
                "ROW_NUM_FOUR": row4["ROW_NUM"],
            }
        )
    common_df = pd.DataFrame(common_rows)
    common_df = common_df.sort_values(by="VARIANT_SCORE", ascending=False)
    common_df.to_csv(
        output_folder + family + "-COMMON-ROWS-FOUR.tsv", sep="\t", index=False
    )


def intersect(files):
    common_identifiers = set(files[0]["ID"])
    for file in files[1:]:
        common_identifiers.intersection_update(set(file["ID"]))
    return common_identifiers


def load_files(file_one, file_two, file_three=None, file_four=None):
    df_one = pd.read_csv(file_one, sep="\t")
    df_one["ROW_NUM"] = df_one.index + 1
    df_one["ID"] = df_one.drop(columns=["ROW_NUM"]).apply(
        lambda row: tuple(row), axis=1
    )
    df_two = pd.read_csv(file_two, sep="\t")
    df_two["ROW_NUM"] = df_two.index + 1
    df_two["ID"] = df_two.drop(columns=["ROW_NUM"]).apply(
        lambda row: tuple(row), axis=1
    )
    if file_three is not None and file_four is None:
        df_three = pd.read_csv(file_three, sep="\t")
        df_three["ROW_NUM"] = df_three.index + 1
        df_three["ID"] = df_three.drop(columns=["ROW_NUM"]).apply(
            lambda row: tuple(row), axis=1
        )
        return df_one, df_two, df_three
    elif file_three is not None and file_four is not None:
        df_three = pd.read_csv(file_three, sep="\t")
        df_three["ROW_NUM"] = df_three.index + 1
        df_three["ID"] = df_three.drop(columns=["ROW_NUM"]).apply(
            lambda row: tuple(row), axis=1
        )
        df_four = pd.read_csv(file_four, sep="\t")
        df_four["ROW_NUM"] = df_four.index + 1
        df_four["ID"] = df_four.drop(columns=["ROW_NUM"]).apply(
            lambda row: tuple(row), axis=1
        )
        return df_one, df_two, df_three, df_four
    else:
        return df_one, df_two


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = ""
    epilog = "This python script has no dependencies"
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-1",
        "--file-one",
        action="store",
        dest="file_one",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the tsv file with ranked variants, first of the\
              family data.",
    )
    parser.add_argument(
        "-2",
        "--file-two",
        action="store",
        dest="file_two",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the tsv file with ranked variants, second of the\
              family data.",
    )
    parser.add_argument(
        "-3",
        "--file-three",
        action="store",
        dest="file_three",
        type=str,
        default=None,
        help="the full path to the tsv file with ranked variants, third of the\
              family data, optional argument just for family A, unless combined\
              with family B.",
    )
    parser.add_argument(
        "-4",
        "--file-four",
        action="store",
        dest="file_four",
        type=str,
        default=None,
        help="the full path to the tsv file with ranked variants, fourth of\
              the family data, used when looking at both A and B.",
    )
    parser.add_argument(
        "-f",
        "--family",
        action="store",
        dest="family",
        type=str,
        default=argparse.SUPPRESS,
        help="the letter used to define the families.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_folder",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the output folder.",
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
    if (
        user_arguments.file_three is not None
        and user_arguments.file_four is None
    ):
        files = load_files(
            user_arguments.file_one,
            user_arguments.file_two,
            user_arguments.file_three,
        )
    elif (
        user_arguments.file_three is not None
        and user_arguments.file_four is not None
    ):
        files = load_files(
            user_arguments.file_one,
            user_arguments.file_two,
            user_arguments.file_three,
            user_arguments.file_four,
        )
    else:
        files = load_files(user_arguments.file_one, user_arguments.file_two)
    common_identifiers = intersect(files)
    if (
        user_arguments.file_three is not None
        and user_arguments.file_four is None
    ):
        find_common_rows_three(
            files,
            common_identifiers,
            user_arguments.family,
            user_arguments.output_folder,
        )
    elif (
        user_arguments.file_three is not None
        and user_arguments.file_four is not None
    ):
        find_common_rows_four(
            files,
            common_identifiers,
            user_arguments.family,
            user_arguments.output_folder,
        )
    else:
        find_common_rows_two(
            files,
            common_identifiers,
            user_arguments.family,
            user_arguments.output_folder,
        )


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
