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
        https://www.statology.org/plot-roc-curve-python/
    """
    # url = "https://raw.githubusercontent.com/Statology/Python-Guides/main/default.csv"
    # data = pd.read_csv(url)
    # X = data[['student', 'balance', 'income']]
    # y = data['default']
    # print(y)
    # print(type(y))

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
        annotation added by vep.
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
    benign = [
        "Likely_benign",
        "Uncertain_significance",
        "Benign/Likely_benign",
        "Benign/Likely_benign|association",
        "Benign|association",
        "Benign|risk_factor",
        "Benign|drug_response",
        "Likely_benign|other",
        "Benign|confers_sensitivity",
    ]
    pathogenic = [
        "Conflicting_interpretations_of_pathogenicity|other",
        "Conflicting_interpretations_of_pathogenicity",
        "risk_factor",
        "Likely_pathogenic",
        "Likely_risk_allele",
        "Pathogenic|risk_factor",
        "Likely_pathogenic|protective",
        "Conflicting_interpretations_of_pathogenicity|risk_factor",
    ]
    meaningless = [
        "association",
        "Uncertain_risk_allele",
        "not_provided",
        "drug_response",
        "protective",
        "Uncertain_significance|risk_factor",
        "other",
        "Affects|association|other",
        "Uncertain_risk_allele|protective",
        "Uncertain_significance|association",
        "Affects",
        "other|risk_factor",
        "association_not_found",
        "confers_sensitivity",
        "protective|risk_factor",
    ]
    for item in meaningless:
        annotation = annotation.drop(
            annotation[annotation["ClinVar_CLNSIG"] == item].index
        )
    for item in pathogenic:
        annotation.loc[
            annotation["ClinVar_CLNSIG"] == str(item), "ClinVar_CLNSIG"
        ] = "Pathogenic"
    for item in benign:
        annotation.loc[
            annotation["ClinVar_CLNSIG"] == str(item), "ClinVar_CLNSIG"
        ] = "Benign"
        return annotation


def read_tabular(path):
    """
    The read_tabular function:
        This function reads in a tabular file, skips the first 67 rows
        and converts dash values tot NaN.
    """
    file = pd.read_table(
        path,
        sep="\t",
        skiprows=67,
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
    variant_file = read_tabular(user_arguments.tab_file)
    variants_filtered = extract_annotation(variant_file)
    count_clinical_relevance(variants_filtered)
    create_roc(variants_filtered)


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
