#!/usr/bin/env python3

# GenomeScan internship repository.
# Copyright (C) 2023 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Contact information: info@jboom.org.

"""
Imports:
"""
import matplotlib
import matplotlib.pyplot as plt
from pysam import VariantFile

def main():
    """
    The main function:
    """
    matplotlib.use("Agg")
    
    quals = [record.qual for record in VariantFile(snakemake.input[0])]
    plt.hist(quals)
    plt.savefig(snakemake.output[0])

if __name__ == "__main__":
    main()

"""
Additional information:
"""