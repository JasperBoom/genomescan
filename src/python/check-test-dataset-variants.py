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
import ast
import pandas as pd
from cyvcf2 import VCF


def process_vcf(all_variants, final_variant_dict):
    AB = AP = 0
    TP = TN = FP = FN = 0
    for variant in all_variants:
        key = (variant.CHROM, variant.POS, variant.REF, tuple(variant.ALT))
        actual_class = variant.INFO.get("Class", "")
        if actual_class == "Benign":
            AB += 1
        elif actual_class == "Pathogenic":
            AP += 1
        if key in final_variant_dict:
            predicted_class = final_variant_dict[key]
        else:
            predicted_class = "Benign"
        if actual_class == "Pathogenic" and predicted_class == "Pathogenic":
            TP += 1
        elif actual_class == "Benign" and predicted_class == "Benign":
            TN += 1
        elif actual_class == "Benign" and predicted_class == "Pathogenic":
            FP += 1
        elif actual_class == "Pathogenic" and predicted_class == "Benign":
            FN += 1
    print(f"True Positives (TP): {TP}")
    print(f"True Negatives (TN): {TN}")
    print(f"False Positives (FP): {FP}")
    print(f"False Negatives (FN): {FN}")
    print(f"Actual Benign (AB): {AB}")
    print(f"Actual Pathogenic (AP): {AP}")


def process_tsv(final_variants):
    variant_dict = {}
    for index, row in final_variants.iterrows():
        key = (
            row["CHROM"],
            row["POS"],
            row["REF"],
            tuple(ast.literal_eval(row["ALT"])),
        )
        variant_dict[key] = "Pathogenic"
    return variant_dict


def load_files(all_variants, final_Variants):
    all_object = VCF(all_variants)
    final_object = pd.read_csv(final_Variants, delimiter="\t")
    return all_object, final_object


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
        "-a",
        "--all",
        action="store",
        dest="all_variants",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the vcf file with all variants from the test\
              dataset.",
    )
    parser.add_argument(
        "-f",
        "--final",
        action="store",
        dest="final_variant_set",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the tsv file with ranked variants from the test\
              dataset.",
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
    objects = load_files(
        user_arguments.all_variants, user_arguments.final_variant_set
    )
    final_variant_dict = process_tsv(objects[1])
    process_vcf(objects[0], final_variant_dict)


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
