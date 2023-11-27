#!/usr/bin/env python3

# -----------------------------------------------------------------------------
# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# his program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.
# -----------------------------------------------------------------------------

# Imports:
import matplotlib
import matplotlib.pyplot as plt
from pysam import VariantFile

def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script created for the snakemake tutorial,\
                   which generates an image."
    epilog = "This pythong script requires one dependency, namely matplotlib."
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
        Creates a histogram for the snakemake tutorial.
    """
    matplotlib.use("Agg")
    
    quals = [record.qual for record in VariantFile(snakemake.input[0])]
    plt.hist(quals)
    plt.savefig(snakemake.output[0])

if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
# 