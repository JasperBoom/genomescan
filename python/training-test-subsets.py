#!/usr/bin/env python3
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

# Imports:
import argparse
import os
import random


def create_combined_file(
    header_lines,
    pathogenic_subset,
    benign_variants,
    output_location,
    output_name,
):
    """
    The create_combined_file function:
        This function writes the variants to a new file. First a check is done
        on the output location, to make sure the new file does not yet exist.
        Then a new file is created, the headers from the pathogenic vcf file
        are appended, then the actual variants and finally the benign variants.
    """
    try:
        os.remove(output_location + output_name)
    except OSError:
        pass
    with open(output_location + output_name, "a") as file:
        for header in header_lines:
            file.write(header)
        for patho in pathogenic_subset:
            file.write(patho)
        with open(benign_variants, "r") as benign:
            for line in benign:
                if line.startswith("#"):
                    pass
                else:
                    file.write(line)


def create_subsets(clinvar_file):
    """
    The create_subsets function:
        This function reads in the clinvar vcf file containing pathogenic
        variants, the header lines are skipped based on the # symbol, the other
        lines are saved in a list. This list is shuffled randomly. After which
        the list is split in two and returned.
    """
    variant_lines = []
    with open(clinvar_file, "r") as file:
        for line in file:
            if line.startswith("#"):
                pass
            else:
                variant_lines.append(line)
    random.shuffle(variant_lines)
    return (
        variant_lines[: len(variant_lines) // 2],
        variant_lines[len(variant_lines) // 2 :],
    )


def extract_header(clinvar_file):
    """
    The extract_header function:
        This function reads in the clinvar vcf file containing pathogenic
        variants, to then only save the lines part of the vcf header to a list.
        This list is returned.
    """
    header_lines = []
    with open(clinvar_file, "r") as file:
        for line in file:
            if line.startswith("#"):
                header_lines.append(line)
            else:
                pass
    return header_lines


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script for creating vcf subsets and combines\
                   the uk personal genome project individuals with clinvar\
                   pathogenic variants."
    epilog = "This python script has no dependencies."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The location for the main output vcf files, just the folder\
              name.",
    )
    parser.add_argument(
        "-c",
        "--clinvar",
        action="store",
        dest="pathogenic_variants",
        type=str,
        default=argparse.SUPPRESS,
        help="The file including path of the clinvar pathogenic variants.",
    )
    parser.add_argument(
        "-t",
        "--testset",
        action="store",
        dest="testset_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The file including path of the dataset to use as test set.",
    )
    parser.add_argument(
        "-x",
        "--trainingset",
        action="store",
        dest="trainingset_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The file including path of the dataset to use as training set.",
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
    vcf_header = extract_header(user_arguments.pathogenic_variants)
    pathogenic_subsets = create_subsets(user_arguments.pathogenic_variants)
    create_combined_file(
        vcf_header,
        pathogenic_subsets[0],
        user_arguments.trainingset_file,
        user_arguments.output_location,
        (
            user_arguments.trainingset_file.split("/")[-1].split(".")[0]
            + "."
            + user_arguments.pathogenic_variants.split("/")[-1]
        ),
    )
    create_combined_file(
        vcf_header,
        pathogenic_subsets[1],
        user_arguments.testset_file,
        user_arguments.output_location,
        (
            user_arguments.testset_file.split("/")[-1].split(".")[0]
            + "."
            + user_arguments.pathogenic_variants.split("/")[-1]
        ),
    )


if __name__ == "__main__":
    main()
