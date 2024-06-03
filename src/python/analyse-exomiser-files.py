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
import glob
import multiprocessing
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


class Data:
    """
    The Collect class:
        This class reads in a tsv file using pd and calculates true
        positive, true negative, false positive nad false negative metrics.
        It also contains a function to generate a confusion matrix plot and
        retrieve the minimal priority score that was used by exomiser.

        This function creates a number of class attributes:
            file_path = an empty string that is filled with the full path to
                        the input tsv file.
    """

    file_path = ""

    def __init__(self, tsv_file):
        """
        The initializer function:
            This function creates an instance attribute:
                tsv_file = a tsv file with exomiser annotation and class info
                           originating from a vcf file.
        """
        self.tsv_file = tsv_file

    @property
    def tsv_file(self):
        """
        The vcf_collection property function:
            This function converts tsv_file to a property which results
            in a pd dataframe.
        """
        return self._tsv_file

    @tsv_file.setter
    def tsv_file(self, value):
        """
        The tsv_file setter function:
            This function reads in a tsv file and converts it into a pd
            dataframe.
        """
        self.file_path = value
        self._tsv_file = pd.read_csv(value, sep="\t")

    def calculate_metrics(self):
        """
        The calculate_metrics function:
            This function calculates the true positive, true negative, false
            positive and false negative metrics based on the predicted and
            known class information in the dataframe. This is returned in a
            list.
        """
        TP = (
            (self.tsv_file["PREDICTED_CLASS"] == "Pathogenic")
            & (self.tsv_file["KNOWN_CLASS"] == "Pathogenic")
        ).sum()
        TN = (
            (self.tsv_file["PREDICTED_CLASS"] == "Benign")
            & (self.tsv_file["KNOWN_CLASS"] == "Benign")
        ).sum()
        FP = (
            (self.tsv_file["PREDICTED_CLASS"] == "Pathogenic")
            & (self.tsv_file["KNOWN_CLASS"] == "Benign")
        ).sum()
        FN = (
            (self.tsv_file["PREDICTED_CLASS"] == "Benign")
            & (self.tsv_file["KNOWN_CLASS"] == "Pathogenic")
        ).sum()
        return [TN, FN, FP, TP]

    def get_minimal_priority_score(self):
        """
        The get_minimal_priority_score function:
            This function used the file path of the input tsv file and isolates
            the minimal priority score in the file name. This is returned.
        """
        return self.file_path.split("/")[-1].strip(".tsv").split("_")[-1]


class ReceiverOperatorCurve:
    """
    The ReceiverOperatorCurve class:
        This class

        This function creates a number of class attributes:
            tpr_dict = an empty dictionary that will store the true positive
                       rates with the minimal priority score as key.
            fpr_dict = an empty dictionary that will store the false positive
                       rates with the minimal priority score as key.
            tpr_values = a flattened list version of tpr_dict.
            fpr_values = a flattened list version of fpr_dict.
            thresholds = a list of thresholds.
            optimal_threshold = the threshold with the optimal tpr and fpr.
    """

    tpr_dict = {}
    fpr_dict = {}
    tpr_values = []
    fpr_values = []
    thresholds = []
    optimal_threshold = 0
    optimal_threshold_index = 0

    def __init__(self, confusion_matrix_dictionary, results_folder):
        """
        The initializer function:
            This function creates an instance attribute:
                confusion_matrix_dictionary = a dictionary containing minimal
                                              priority scores as keys and
                                              confusion matrix metrics as
                                              values.
                results_folder = the folder with the Exomiser output files.
        """
        self.confusion_matrix_dictionary = confusion_matrix_dictionary
        self.results_folder = results_folder

    def calculate_tpr_fpr(self):
        """
        The calculate_tpr_fpr function:
            This function calculates the true positive rate and false positive
            rate for all thresholds in the input dictionary. These rates are
            stored in dictionaries.
        """
        for threshold, values in self.confusion_matrix_dictionary.items():
            tn, fn, fp, tp = values
            self.tpr_dict[threshold] = 0.0 if tp + fn == 0 else tp / (tp + fn)
            self.fpr_dict[threshold] = 0.0 if fp + tn == 0 else fp / (fp + tn)

    def calculate_optimal_threshold(self):
        """
        The optimal_threshold function:
            This function calculates the optmal threshold on which to do
            classification. This thresholds is retrieved from the set of
            minimal priority scores that were tested.
        """
        youden_j = np.array(self.tpr_values) - np.array(self.fpr_values)
        self.optimal_threshold = self.thresholds[np.argmax(youden_j)]
        self.optimal_threshold_index = self.thresholds.index(
            self.thresholds[np.argmax(youden_j)]
        )
        print("The optimal threshold is: " + str(self.optimal_threshold))

    def plot_roc_curve(self):
        """
        The plot_roc_curve function:
            This function creates a ROC plot with the TPR and FPR values for
            all tested minimal priority scores. Additionally, it adds a point
            with text for the minimal priority score that performs best.
        """
        self.thresholds = sorted(
            [
                str(f"{float(threshold):.2f}")
                for threshold in self.tpr_dict.keys()
            ]
        )
        for threshold in self.thresholds:
            self.tpr_values.append(self.tpr_dict[str(threshold)])
            self.fpr_values.append(self.fpr_dict[str(threshold)])
        self.tpr_values.insert(0, 1.0)
        self.fpr_values.insert(0, 1.0)
        self.calculate_optimal_threshold()
        plt.plot(
            self.fpr_values, self.tpr_values, label="ROC Curve", color="#83b96d"
        )
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        plt.scatter(
            self.fpr_values[self.optimal_threshold_index],
            self.tpr_values[self.optimal_threshold_index],
            color="#00a6cf",
            label="Optimal Threshold",
            zorder=5,
        )
        plt.text(
            self.fpr_values[self.optimal_threshold_index] + 0.1,
            self.tpr_values[self.optimal_threshold_index] - 0.05,
            f"{self.optimal_threshold}",
            fontsize=8,
            ha="right",
        )
        plt.legend()
        plt.savefig(self.results_folder + "/roc-exomiser-thresholding.png")
        plt.clf()


def process_data(file):
    """
    The process_data function:
        This function creates a Data object using the input tsv file and
        returns the minimal priority score used to create the input tsv file
        and the tn, fn, fp and tp metrics.
    """
    dataframe = Data(file)
    return dataframe.get_minimal_priority_score(), dataframe.calculate_metrics()


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "."
    epilog = "This python script has three dependencies: matplotlib,\
              numpy & pandas."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-r",
        "--results",
        action="store",
        dest="results_folder",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the main folder with the exomiser tsv results.",
    )
    parser.add_argument(
        "-c",
        "--cores",
        action="store",
        dest="cores",
        type=int,
        default=1,
        help="the number of cpu cores to assign to multiprocessing",
    )
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s [1.0]]"
    )
    argvs = parser.parse_args()
    return argvs


def main():
    """
    The main function:
        This function calls all processing functions in correct order. It also
        creates a multiprocessing pool to handle multiple cores.
    """
    user_arguments = parse_argvs()
    pool = multiprocessing.Pool(processes=user_arguments.cores)
    results = pool.starmap(
        process_data,
        [
            (filename,)
            for filename in glob.glob(
                os.path.join(user_arguments.results_folder, "*.tsv")
            )
        ],
    )
    pool.close()
    pool.join()
    confusion_matrix_dictionary = {}
    for matrix in results:
        key, value = matrix
        confusion_matrix_dictionary[key] = value
    roc_plot = ReceiverOperatorCurve(
        confusion_matrix_dictionary, user_arguments.results_folder
    )
    roc_plot.calculate_tpr_fpr()
    roc_plot.plot_roc_curve()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
