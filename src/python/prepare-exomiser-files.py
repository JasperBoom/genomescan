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

def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script executes Exomiser on a trainingset. It changes\
                   the minimal priority range for each run and collects those\
                   results. "
    epilog = "This python script has no dependencies."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-y",
        "--yaml",
        action="store",
        dest="yaml_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the exomiser yaml options file.",
    )
    parser.add_argument(
        "-e",
        "--vcf",
        action="store",
        dest="vcf_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the sample vcf file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and folder name for the output of exomiser.",
    )
    parser.add_argument(
        "-n",
        "--name",
        action="store",
        dest="output_name",
        type=str,
        default=argparse.SUPPRESS,
        help="The base name to use for the output of exomiser, leave empty\
              for an automatic name to be generated.",
    )
    parser.add_argument(
        "-l",
        "--log",
        action="store",
        dest="log_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the folder for the log file.",
    )
    parser.add_argument(
        "-p",
        "--hpo",
        action="store",
        dest="hpo_terms",
        type=str,
        default=argparse.SUPPRESS,
        help="A list of hpo terms separated by comma's.",
    )
    parser.add_argument(
        "-t",
        "--temp",
        action="store",
        dest="temp_folder",
        type=str,
        default=argparse.SUPPRESS,
        help="A location and folder for java to store temporary files.",
    )
    parser.add_argument(
        "-c",
        "--config",
        action="store",
        dest="config_location",
        type=str,
        default=argparse.SUPPRESS,
        help="A location and file name for the exomiser config file.",
    )
    parser.add_argument(
        "-d",
        "--docker",
        action="store",
        dest="docker_container",
        type=str,
        default=argparse.SUPPRESS,
        help="The container to use for running exomiser with java.",
    )
    parser.add_argument(
        "-j",
        "--jar",
        action="store",
        dest="exomiser_jar",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the exomiser jar file.",
    )
    parser.add_argument(
        "-r",
        "--cores",
        action="store",
        dest="cores",
        type=int,
        default=1,
        help="The number of cpu cores to assign to multiprocessing.",
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


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#