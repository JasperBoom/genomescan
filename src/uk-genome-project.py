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
import json
import requests
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn import metrics
import matplotlib.pyplot as plt
import pandas as pd


def create_roc(variants):
    """
    The create_roc function:
        This function creates a roc plot based on a logistic regression model.
        https://www.statology.org/plot-roc-curve-python/
    """
    predictor_x = variants[
        [
            "FATHMM_MKL_NC",
            "CADD_PHRED",
            "CADD_RAW",
            "CAPICE_SCORE",
            "FATHMM_MKL_C",
        ]
    ]
    response_y = variants["ClinVar_CLNSIG"]

    x_train, x_test, y_train, y_test = train_test_split(
        predictor_x, response_y, test_size=0.3, random_state=0
    )

    log_regression = LogisticRegression().fit(x_train, y_train)

    y_pred_proba = log_regression.predict_proba(x_test)[::, 1]
    fpr, tpr, _ = metrics.roc_curve(
        y_test, y_pred_proba, pos_label="Pathogenic"
    )

    plt.plot(fpr, tpr)
    plt.ylabel("True Positive Rate")
    plt.xlabel("False Positive Rate")
    plt.show()


def count_clinical_relevance(variants):
    """
    The count_clinical_relevance function:
        This function prints a count of the number of benign and number of
        pathogenic variants found in the data, this is purely based on what
        is known in the clinvar database.
    """
    print(
        "The number of benign variants is: "
        + str(sum(variants["ClinVar_CLNSIG"] == "Benign"))
    )
    print(
        "The number of pathogenic variants is: "
        + str(sum(variants["ClinVar_CLNSIG"] == "Pathogenic"))
    )


def extract_annotation(file):
    """
    The extract_annotation function:
        This function selects the columns of interest containing just the
        annotation added by vep, also dropping all rows containing NaN values.
    """
    column_names = [
        "Uploaded_variation",
        "CADD_PHRED",
        "CADD_RAW",
        "CAPICE_SCORE",
        "FATHMM_MKL_C",
        "FATHMM_MKL_NC",
        "ClinVar_CLNSIG",
    ]
    annotation = file[column_names].dropna()
    return annotation


def replace_clinvar_column(file):
    """
    The replace_clinvar_column file:
        This function reads in the truth set created using clinvar and
        benchmark.py. The uk personal genome variant set is converted to purely
        benign variants. These two tables are then merged and written to file.
    """
    truth_set = extract_annotation(
        read_tabular(
            "/home/j.boom/develop/genomescan/data/benchmark-vcf/2024-02-05/benchmark.annotated.tab",
            57,
        )
    )
    personal_genome = extract_annotation(file)
    personal_genome.loc[
        personal_genome["ClinVar_CLNSIG"] != "Benign", "ClinVar_CLNSIG"
    ] = "Benign"
    pd.concat([personal_genome, truth_set], axis=0).to_csv(
        "/mnt/titan/users/j.boom/vcf/personalgenomesuk/FR07961005.pass.recode.annotated.edit.tab",
        sep="\t",
        index=False,
        header=True,
    )


def read_tabular(path, skip):
    """
    The read_tabular function:
        This function reads in a tabular file, skips the number of rows
        indicated by "skip" and converts dash values tot NaN.
    """
    file = pd.read_table(
        path,
        sep="\t",
        skiprows=skip,
        na_values="-",
        keep_default_na=True,
        low_memory=False,
    )
    return file


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = ""
    epilog = "This python script has two dependency: pandas, scikit-learn & matplotlib"
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-t",
        "--tab",
        action="store",
        dest="tab_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input tabular file containing variants and annotation.",
    )
    parser.add_argument(
        "--r",
        "--replace",
        action="store",
        dest="replace_column",
        type=bool,
        default=False,
        help="Replace the ClinVar column with just benign values.",
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
    if user_arguments.replace_column == True:
        variant_file = read_tabular(user_arguments.tab_file, 57)
        replace_clinvar_column(variant_file)
    elif user_arguments.replace_column == False:
        variant_file = read_tabular(user_arguments.tab_file, 0)
        variants_filtered = extract_annotation(variant_file)
        count_clinical_relevance(variants_filtered)
        create_roc(variants_filtered)


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
