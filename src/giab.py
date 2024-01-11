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
import re


def merge(pathogenic, benign):
    with open(pathogenic, "a") as file:
        for item in benign:
            file.write(item)


def select_variants(giab):
    genes = ["NF2", "SMARCE1", "PTEN", "BAP1"]
    variants = []
    with open(giab, "r") as file:
        for line in file:
            if line.startswith("##INFO=<ID=CSQ"):
                columns = line.strip('">\n').split(" ")[-1].split("|")
                max_af = columns.index("MAX_AF")
                symbol = columns.index("SYMBOL")
            if line.startswith("#"):
                pass
            else:
                info = line.split("CSQ=")[1].split("|")
                if info[symbol] in genes:
                    if info[max_af] != "":
                        if float(info[max_af]) > 0.8:
                            variants.append(line)
    return variants


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = ""
    epilog = ""
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-i",
        "--input",
        action="store",
        dest="vcf_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input giab vcf file.",
    )
    parser.add_argument(
        "-m",
        "--meningioma",
        action="store",
        dest="meningioma_file",
        type=str,
        default=argparse.SUPPRESS,
        help="File (vcf) containing meningioma associated variants.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The name and location for the output VCF file.",
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
    variants = select_variants(user_arguments.vcf_file)
    merge(user_arguments.meningioma_file, variants)


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
