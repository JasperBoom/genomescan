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
from bs4 import BeautifulSoup

def read_xml(input_file):
    with open(input_file, "r") as file:
        data = file.read()
        bs_data = BeautifulSoup(data, "xml")
        for line in bs_data:
            print(line)    

def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script for reading in an xml file."
    epilog = "This pythong script requires two dependencies, namely\
              beautifulsoup4 & lxml."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-i",
        "--input",
        action="store",
        dest="input_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input xml file.",
    )
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s [1.0]]"
    )
    argvs = parser.parse_args()
    return argvs

def main():
    """
    The main function:
        A
    """
    user_arguments = parse_argvs()
    read_xml(user_arguments.input_file)

if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
# 