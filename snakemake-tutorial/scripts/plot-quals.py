#!/usr/bin/env python3
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

# Imports.
import argparse
import matplotlib
import matplotlib.pyplot as plt
from pysam import VariantFile


def create_plot():
    """
    This function creates the histogram.
    """
    matplotlib.use("Agg")
    quals = [record.qual for record in VariantFile(snakemake.input[0])]
    plt.hist(quals)
    plt.savefig(snakemake.output[0])


def parse_argvs():
    """
    This function handles all positional arguments that the script accepts,
    including version and help pages.
    """
    description = "A python script created for the snakemake tutorial,\
                   which generates an image."
    epilog = "This python script has two dependencies: matplotlib & pysam."
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
    This function calls all processing functions in correct order.
    """
    create_plot()


if __name__ == "__main__":
    main()
