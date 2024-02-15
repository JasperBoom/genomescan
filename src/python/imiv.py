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
import random
import shutil
import subprocess as sp
import os


def sort_vcf(vcf_file):
    """
    The sort_vcf function:
        This function uses the bcftools software to sort the adjustded vcf file.
        Does not yet work due to issues using sbatch on slurm.
    """
    output_file_name = vcf_file[:-3] + "sorted.vcf"
    bcftools = sp.Popen(
        [
            "bcftools",
            "sort",
            "--output-type",
            "v",
            "--output",
            output_file_name,
            vcf_file,
        ],
        stdout=sp.PIPE,
        stderr=sp.PIPE,
    )
    bcftools_output, bcftools_error = bcftools.communicate()
    bgzip = sp.Popen(
        [
            "bgzip",
            output_file_name,
        ],
        stdout=sp.PIPE,
        stderr=sp.PIPE,
    )
    bgzip_output, bgzip_error = bgzip.communicate()
    tabix = sp.Popen(
        [
            "tabix",
            "--preset",
            "vcf",
            str(output_file_name) + ".gz",
        ],
        stdout=sp.PIPE,
        stderr=sp.PIPE,
    )
    tabix_output, tabix_error = tabix.communicate()


def add_variant(vcf_file, gender, meningioma, output_location):
    """
    The add_variant function:
        This function creates a new file name for the input vcf file including
        sample name, gender and gene associated with meningioma. The input
        vcf file is copied to  a new location, renamed and the variant of
        interest is appended to the file.
    """
    file_name = (
        os.path.split(vcf_file)[1].split(".")[0]
        + "."
        + gender
        + "."
        + meningioma[1]
        + ".vcf"
    )
    shutil.copy(vcf_file, output_location)
    os.rename(
        output_location + os.path.split(vcf_file)[1],
        output_location + file_name,
    )
    with open(output_location + file_name, "a") as file:
        file.write(meningioma[0] + "\n")
    return output_location + file_name


def select_variant(meningioma_file):
    """
    The select_variant function:
        This function creates a list of all variants in the meningioma vcf and
        selects a random one. It also extracts the gene name associated with
        the variant to be included in the output filename and remove this
        novel GENE field from the variant entry.
    """
    variants = []
    with open(meningioma_file, "r") as file:
        for line in file:
            if line.strip("\n").startswith("#"):
                pass
            else:
                variants.append(line.strip("\n"))
    variant = str(variants[random.randint(1, len(variants)) - 1])
    gene = variant.split("GENE=")[1].split(" ")[0]
    return variant.split(";GENE=")[0], gene


def gender_identification(vcf_file, stats_file):
    """
    The gender_identification function:
        This function extracts the gender information from the stats file so
        it can be added to the file name later.
    """
    return pd.read_table(stats_file, index_col="sample_name").loc[
        os.path.split(vcf_file)[1].split(".")[0]
    ]["inferred_gender"]


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script that processes GenomeScan vcf files that\
                   were created using the DRAGEN pipeline on the GenomeScan HPC\
                   [Insert Mutation In Vcf]"
    epilog = "This python script has one dependency: pandas"
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
        help="The DRAGEN vcf file.",
    )
    parser.add_argument(
        "-s",
        "--stats",
        action="store",
        dest="stats_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The GenomeScan stats tabular file.",
    )
    parser.add_argument(
        "-m",
        "--meningioma",
        action="store",
        dest="meningioma_file",
        type=str,
        default=argparse.SUPPRESS,
        help="VCF file containing meningioma associated variants.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="Location of the altered VCF output directory including\
              a trailing forward slash.",
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
    gender = gender_identification(
        user_arguments.vcf_file, user_arguments.stats_file
    )
    meningioma = select_variant(user_arguments.meningioma_file)
    output_file = add_variant(
        user_arguments.vcf_file,
        gender,
        meningioma,
        user_arguments.output_location,
    )
    # REQUIRES FIX!
    # sort_vcf(output_file)


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
