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


def write_output(input_file, input_list, output_file):
    """
    The write_output function:
        This function creates a new file, writes the lines from an input file
        to the new file and writes the items from a list to the new file.
    """
    with open(output_file, "a") as output:
        with open(input_file, "r") as file:
            for line in file:
                output.write(line)
        for item in input_list:
            output.write(item)


def get_variants(pathogenic_variants, pathogenic_ids):
    """
    The get_variants function:
        This function uses a list of variant ids extracted from the tabular
        vep file processed in the extract_ids function to collect vcf lines
        from the clinvar vcf that match these ids. These lines are returned
        in a list.
    """
    variant_list = []
    with open(pathogenic_variants, "r") as file:
        for line in file:
            if line.startswith("#"):
                pass
            else:
                if line.strip("\n").split("\t")[2] in pathogenic_ids:
                    variant_list.append(line)
                    print(line)
    return variant_list


def extract_ids(tab_file):
    """
    The extract_ids function:
        This function extracts the variant ids associated with pathogenic
        variants and returns those in a list.
    """
    pathogenic_ids = []
    with open(tab_file, "r") as file:
        for line in file:
            print(line)
            classification = line.strip("\n").split("\t")[-1]
            variant_id = line.strip("\n").split("\t")[0]
            if classification == "Pathogenic":
                pathogenic_ids.append(variant_id)
    return pathogenic_ids


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script that combines an individuals vcf file with\
                   pathogenic variants extracted from clinvar."
    epilog = "This python script has no dependencies."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-b",
        "--benign",
        action="store",
        dest="benign_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input vcf file that contains the benign variants.",
    )
    parser.add_argument(
        "-p",
        "--pathogenic",
        action="store",
        dest="pathogenic_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input vcf file that contains the pathogenic variants.",
    )
    parser.add_argument(
        "-t",
        "--tabular",
        action="store",
        dest="tabular_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The tabular file containing the benign variants and subset(s)\
              of pathogenic variants, used to extract variant IDs.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The output file location of the combined vcf.",
    )
    parser.add_argument(
        "-a",
        "--header",
        action="store",
        dest="header_file",
        type=str,
        default=argparse.SUPPRESS,
        help="A file containing a header to use for creating a new vcf file.",
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
    ids = extract_ids(user_arguments.tabular_file)
    pathogenic_vcf_lines = get_variants(user_arguments.pathogenic_file, ids)
    write_output(
        user_arguments.header_file,
        pathogenic_vcf_lines,
        user_arguments.output_file,
    )
    # write_output(
    #    user_arguments.benign_file,
    #    pathogenic_vcf_lines,
    #    user_arguments.output_file,
    # )


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
