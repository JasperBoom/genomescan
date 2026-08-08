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
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


class MonteCarlo:
    def __init__(self, tsv_file):
        """
        The initializer function:
            This function creates an instance attribute:
                tsv = the input tsv file with ranking information of the
                      final set of variants.
        """
        self.tsv = tsv_file

    @property
    def tsv(self):
        """
        The tsv property function:
            This function converts tsv to a property which results
            in a pandas object that is returned.
        """
        return self._tsv

    @tsv.setter
    def tsv(self, value):
        """
        The tsv setter function:
            This function reads in a tsv file using the pandas module.
        """
        self._tsv = pd.read_csv(value, sep="\t")

    def run_simulation(self, initial_iterations=1000, target_precision=0.01):
        """
        The run_simulation function:
            This function runs a Monte-Carlo simulation on the input tsv file.
            This simulation takes 99 benign variants and 1 pathogenic variants
            and checks what percentage of times the pathogenic variants is in
            the top 10 and top 1 of the variant list. This simulation is
            repeated in increments of 1000 to determine convergence of
            performance. A plot is created to visualise the convergence.
        """
        benign_rows = self.tsv[self.tsv["CLASS"] == "Benign"]
        pathogenic_rows = self.tsv[self.tsv["CLASS"] == "Pathogenic"]
        top_15_count = 0
        top_10_count = 0
        number_1_count = 0
        top_15_percentages = []
        top_10_percentages = []
        current_precision = float("inf")
        total_iterations = 0
        while current_precision > target_precision:
            for _ in range(initial_iterations):
                sampled_benign = benign_rows.sample(n=99, replace=False)
                sampled_pathogenic = pathogenic_rows.sample(n=1, replace=False)
                combined_sample = pd.concat(
                    [sampled_benign, sampled_pathogenic]
                )
                combined_sample = combined_sample.sort_values(
                    by="VARIANT_RANK", ascending=False
                )
                top_15 = combined_sample.head(15)
                top_10 = combined_sample.head(10)
                top_1 = combined_sample.head(1)
                if sampled_pathogenic.index[0] in top_15.index:
                    top_15_count += 1
                if sampled_pathogenic.index[0] in top_10.index:
                    top_10_count += 1
                if sampled_pathogenic.index[0] == top_1.index[0]:
                    number_1_count += 1

            total_iterations += initial_iterations
            top_15_percentage = (top_15_count / total_iterations) * 100
            top_10_percentage = (top_10_count / total_iterations) * 100
            number_1_percentage = (number_1_count / total_iterations) * 100
            top_15_percentages.append(top_15_percentage)
            top_10_percentages.append(top_10_percentage)

            if len(top_10_percentages) > 1:
                current_precision = np.std(top_10_percentages) / np.sqrt(
                    len(top_10_percentages)
                )
                print(
                    f"Iteration {total_iterations}: Top 15% = {top_15_percentage:.2f}%, Top 10% = {top_10_percentage:.2f}%, Top 1% = {number_1_percentage:.2f}%, Precision = {current_precision:.6f}"
                )

        print(f"Converged with {total_iterations} iterations.")
        print(f"Pathogenic row in top 15: {top_15_percentage:.2f}%")
        print(f"Pathogenic row in top 10: {top_10_percentage:.2f}%")
        print(f"Pathogenic row is number 1: {number_1_percentage:.2f}%")

        plt.figure(figsize=(10, 6))
        plt.plot(
            range(len(top_10_percentages)),
            top_10_percentages,
            marker="o",
            linestyle="-",
            color="#EC9E62",
            label="Top 10",
        )
        plt.xlabel("Number of iterations (in thousands)")
        plt.ylabel(
            "Percentage of simulations with pathogenic variant in top ranks"
        )
        plt.legend()
        plt.grid(True)
        plt.savefig(
            "/mnt/flashblade01/scratch/j.boom/data/FR07961006.ranking.monte.carlo.simulation.convergence.png",
            dpi=600,
        )


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script runs a Monte-Carlo simulation on the\
                   meningioma test dataset in order to calculate the\
                   performance of the ranking."
    epilog = "This python script has one dependency: pandas."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-t",
        "--tsv",
        action="store",
        dest="tsv_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the tsv file with ranked variants.",
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
    monte_carlo = MonteCarlo(user_arguments.tsv_file)
    simulation = monte_carlo.run_simulation()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
