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
import seaborn as sns


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

    def visualize_confusion_matrix(self, confusion_matrix):
        """
        The visualize_confusion_matrix function:
            This function creates a heatmap using the metrics from the
            calculate_metrics function. Showing the confusion matrix for
            benign and pathogenic variants in predicted and actual
            classification.
        """
        sns.heatmap(
            np.array(confusion_matrix).reshape((2, 2)),
            annot=True,
            fmt="d",
            xticklabels=["Benign", "Pathogenic"],
            yticklabels=["Benign", "Pathogenic"],
        )
        plt.xlabel("Predicted")
        plt.ylabel("Actual")
        plt.title("Confusion Matrix")
        plt.show()

    def get_minimal_priority_score(self):
        """
        The get_minimal_priority_score function:
            This function used the file path of the input tsv file and isolates
            the minimal priority score in the file name. This is returned.
        """
        return self.file_path.split("/")[-1].split("_")[2]


class ReceiverOperatorCurve:
    """
    The ReceiverOperatorCurve class:
        This class

        This function creates a number of class attributes:
            tpr = an empty dictionary that will store the true positive rates.
            fpr = an empty dictionary that will store the false positive rates.
    """

    tpr = {}
    fpr = {}
    optimal_threshold = ""

    def __init__(self, confusion_matrix_dictionary):
        """
        The initializer function:
            This function creates an instance attribute:
                confusion_matrix_dictionary = a dictionary containing minimal
                                              priority scores as keys and
                                              confusion matrix metrics as
                                              values.
        """
        self.confusion_matrix_dictionary = confusion_matrix_dictionary

    def calculate_tpr_fpr(self):
        """
        The calculate_tpr_fpr function:
            This function calculates the true positive rate and false positive
            rate for all thresholds in the input dictionary. These rates are
            stored in dictionaries.
        """
        for threshold, values in self.confusion_matrix_dictionary.items():
            tn, fn, fp, tp = values
            self.tpr[threshold] = tp / (tp + fn)
            self.fpr[threshold] = fp / (fp + tn)

    def calculate_optimal_threshold(self):
        """
        The optimal_threshold function:
            This function calculates the optmal threshold on which to do
            classification. This thresholds is retrieved from the set of
            minimal priority scores that were tested.
        """
        self.optimal_threshold = min(
            self.tpr.keys(), key=lambda i: abs(1 - self.tpr[i] - self.fpr[i])
        )

    def plot_roc_curve(self):
        """
        The plot_roc_curve function:
            This function creates a ROC plot with the TPR and FPR values for
            all tested minimal priority scores. Additionally, it adds a point
            with text for the minimal priority score that performs best.
        """
        self.calculate_optimal_threshold()
        plt.plot(
            list(self.fpr.values()), list(self.tpr.values()), label="ROC Curve"
        )
        plt.xlabel("False Positive Rate")
        plt.ylabel("True Positive Rate")
        plt.title("Receiver Operating Characteristic (ROC) Curve")
        plt.scatter(
            self.fpr[self.optimal_threshold],
            self.tpr[self.optimal_threshold],
            color="red",
            label="Optimal Threshold",
        )
        plt.text(
            self.fpr[self.optimal_threshold],
            self.tpr[self.optimal_threshold],
            f"Threshold: {self.optimal_threshold}",
            fontsize=8,
            ha="right",
        )
        plt.legend()
        plt.show()


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
    epilog = "This python script has no dependencies."
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
        This function calls all processing functions in correct order.
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
    roc_plot = ReceiverOperatorCurve(confusion_matrix_dictionary)
    roc_plot.calculate_tpr_fpr()
    roc_plot.plot_roc_curve()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
