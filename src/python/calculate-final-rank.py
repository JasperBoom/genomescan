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
import pandas as pd
import re
from cyvcf2 import VCF
from sklearn.ensemble import RandomForestClassifier


class TSV:
    """
    The TSV class:
        This class takes care of creating a tsv file with all scores used in
        the filtering pipeline, including class information. And then using
        that tsv to create a random forest classifier in order to determine
        feature weights.

        This function creates a number of class attributes:
            vep_annotation = a list of strings with the names of each section
                             of annotation that VEP could add to a variant.
            exomiser_annotation = a list of strings with the names of each
                                  annotation field that exomiser adds to a
                                  variant.
            dtype_options_vep = a dictionary with dtype definitions for all
                                columns in the vep tsv.
            dtype_options_exomiser = a dictionary with dtype definitions for
                                     all columns in the exomiser tsv.
            dtype_options_combined = a dictionary with dtype definitions for
                                     all columns in the combined tsv.
            dtype_options_combined_clean_normalised = a dictionary with dtype
                                                      definitions for all
                                                      columns in the combined
                                                      tsv.
    """

    vep_annotation = [
        "Allele",
        "Consequence",
        "IMPACT",
        "SYMBOL",
        "Gene",
        "Feature_type",
        "Feature",
        "BIOTYPE",
        "EXON",
        "INTRON",
        "HGVSc",
        "HGVSp",
        "cDNA_position",
        "CDS_position",
        "Protein_position",
        "Amino_acids",
        "Codons",
        "Existing_variation",
        "DISTANCE",
        "STRAND",
        "FLAGS",
        "SYMBOL_SOURCE",
        "HGNC_ID",
        "CADD_PHRED",
        "CADD_RAW",
        "CAPICE_SCORE",
        "FATHMM_MKL_C",
        "FATHMM_MKL_NC",
    ]
    exomiser_annotation = [
        "RANK",
        "ID",
        "GENE_SYMBOL",
        "ENTREZ_GENE_ID",
        "MOI",
        "P-VALUE",
        "EXOMISER_GENE_COMBINED_SCORE",
        "EXOMISER_GENE_PHENO_SCORE",
        "EXOMISER_GENE_VARIANT_SCORE",
        "EXOMISER_VARIANT_SCORE",
        "CONTRIBUTING_VARIANT",
        "WHITELIST_VARIANT",
        "FUNCTIONAL_CLASS",
        "HGVS",
        "EXOMISER_ACMG_CLASSIFICATION",
        "EXOMISER_ACMG_EVIDENCE",
        "EXOMISER_ACMG_DISEASE_ID",
        "EXOMISER_ACMG_DISEASE_NAME",
    ]
    dtype_options_vep = {
        "CHROM": "str",
        "POS": "int",
        "REF": "str",
        "ALT": "str",
        "CLASS": "str",
        "CADD_PHRED": "float",
        "CADD_RAW": "float",
        "CAPICE_SCORE": "float",
        "FATHMM_MKL_C": "float",
        "FATHMM_MKL_NC": "float",
        "EXOMISER_GENE_COMBINED_SCORE": "float",
    }
    dtype_options_exomiser = {
        "CHROM": "str",
        "POS": "int",
        "REF": "str",
        "ALT": "str",
        "CLASS": "str",
        "EXOMISER_GENE_COMBINED_SCORE": "float",
        "PHEN2GENE_RANK": "int",
    }
    dtype_options_combined = {
        "CHROM": "str",
        "POS": "int",
        "REF": "str",
        "ALT": "str",
        "CLASS": "str",
        "CADD_PHRED": "float",
        "CADD_RAW": "float",
        "CAPICE_SCORE": "float",
        "FATHMM_MKL_C": "float",
        "FATHMM_MKL_NC": "float",
        "EXOMISER_GENE_COMBINED_SCORE": "float",
        "PHEN2GENE_RANK": "int",
    }
    dtype_options_combined_clean_normalised = {
        "CHROM": "str",
        "POS": "int",
        "REF": "str",
        "ALT": "str",
        "CLASS": "str",
        "CADD_PHRED": "float",
        "CADD_RAW": "float",
        "CAPICE_SCORE": "float",
        "FATHMM_MKL_C": "float",
        "FATHMM_MKL_NC": "float",
        "EXOMISER_GENE_COMBINED_SCORE": "float",
        "PHEN2GENE_RANK": "int",
        "CADD_PHRED_NORMALISED": "float",
        "CADD_RAW_NORMALISED": "float",
        "FATHMM_MKL_C_NORMALISED": "float",
        "FATHMM_MKL_NC_NORMALISED": "float",
        "PHEN2GENE_RANK_NORMALISED": "float",
    }

    def __init__(self, vep_file, exomiser_file, output_name):
        """
        The initializer function:
            This function creates an instance attribute:
                vep = the input vep annotated vcf file.
                exomiser = the input exomiser annotated vcf file.
                output = a string to use as the output name of the tsv files.
        """
        self.vep = vep_file
        self.exomiser = exomiser_file
        self.output = output_name

    def create_vep_tsv(self):
        """
        The create_vep_tsv function:
            This function takes the vep annotated vcf file and extracts the
            annotation, writes the relevant information to a tsv file.
        """
        vep_object = VCF(self.vep)
        with open(self.output + "-vep.tsv", "w") as file_out:
            file_out.write(
                "CHROM\tPOS\tREF\tALT\tCLASS\tCADD_PHRED\tCADD_RAW\tCAPICE_SCORE\tFATHMM_MKL_C\tFATHMM_MKL_NC\n"
            )
            for variant in vep_object:
                chrom = variant.CHROM
                pos = variant.POS
                ref = variant.REF
                alt = variant.ALT[0] if variant.ALT else ""
                class_info = variant.INFO.get("Class", "")
                csq_info = variant.INFO.get("CSQ", "")
                csq_annotation = csq_info.split(",")[0].split("|")
                csq_annotation_dict = dict(
                    zip(self.vep_annotation, csq_annotation)
                )
                keys = [
                    "CADD_PHRED",
                    "CADD_RAW",
                    "CAPICE_SCORE",
                    "FATHMM_MKL_C",
                    "FATHMM_MKL_NC",
                ]
                values = [csq_annotation_dict.get(key, "") for key in keys]
                file_out.write(
                    f"{chrom}\t{pos}\t{ref}\t{alt}\t{class_info}\t"
                    + "\t".join(values)
                    + "\n"
                )

    def parse_exomiser_info(self, info_field):
        """
        The parse_exomiser_info function:
            This function selects a string in between two brackets. It selects
            the first element/group and splits on a pipe character. The list is
            returned.
        """
        match = re.match(r"\{([^{}]+)\}", info_field)
        if match:
            first_set = match.group(1)
            elements = first_set.split("|")
            return elements
        else:
            return []

    def create_exomiser_tsv(self, phen2gene):
        """
        The create_exomiser_tsv function:
            This function takes the exomiser annotated vcf file and extracts
            the annotation, writes the relevant information to a tsv file. It
            also adds the phen2gene rank for the gene associated with the
            variant. If that gene is not in the phen2gene list, the lowest rank
            is assigned.
        """
        exomiser_object = VCF(self.exomiser)
        phen2gene_df = pd.read_csv(phen2gene, delimiter="\t")
        phen2gene_df.set_index("Gene", inplace=True)
        with open(self.output + "-exomiser.tsv", "w") as file_out:
            file_out.write(
                "CHROM\tPOS\tREF\tALT\tCLASS\tEXOMISER_GENE_COMBINED_SCORE\tPHEN2GENE_RANK\n"
            )
            for variant in exomiser_object:
                chrom = variant.CHROM
                pos = variant.POS
                ref = variant.REF
                alt = variant.ALT[0] if variant.ALT else ""
                class_info = variant.INFO.get("Class", "")
                exomiser_annotation = self.parse_exomiser_info(
                    variant.INFO.get("Exomiser", "")
                )
                exomiser_annotation_dict = dict(
                    zip(self.exomiser_annotation, exomiser_annotation)
                )
                exomiser_score = exomiser_annotation_dict[
                    "EXOMISER_GENE_COMBINED_SCORE"
                ]
                if (
                    exomiser_annotation_dict["GENE_SYMBOL"]
                    in phen2gene_df.index
                ):
                    phen2gene_rank = phen2gene_df.loc[
                        exomiser_annotation_dict["GENE_SYMBOL"], "Rank"
                    ]
                else:
                    phen2gene_rank = 10843
                file_out.write(
                    f"{chrom}\t{pos}\t{ref}\t{alt}\t{class_info}\t{exomiser_score}\t{phen2gene_rank}\n"
                )

    def combine_tsv(self):
        """
        The combine_tsv function:
            This function combines the vep tsv and exomisert tsv files based
            on the values in the chromosome, position, reference and
            alternative columns. The columns are renamed and written to a new
            tsv file.
        """
        vep_df = pd.read_csv(
            self.output + "-vep.tsv",
            delimiter="\t",
            dtype=self.dtype_options_vep,
        )
        exomiser_df = pd.read_csv(
            self.output + "-exomiser.tsv",
            delimiter="\t",
            dtype=self.dtype_options_exomiser,
        )
        merged_df = pd.merge(
            vep_df,
            exomiser_df,
            on=["CHROM", "POS", "REF", "ALT"],
            suffixes=("_exomiser", "_vep"),
            how="inner",
        )
        merged_df = merged_df.drop(columns=["CLASS_vep"])
        combined_columns = [
            "CHROM",
            "POS",
            "REF",
            "ALT",
            "CLASS",
            "CADD_PHRED",
            "CADD_RAW",
            "CAPICE_SCORE",
            "FATHMM_MKL_C",
            "FATHMM_MKL_NC",
            "EXOMISER_GENE_COMBINED_SCORE",
            "PHEN2GENE_RANK",
        ]
        merged_df.columns = combined_columns
        merged_df.to_csv(self.output + "-combined.tsv", sep="\t", index=False)

    def custom_normalisation(self, x, benign_range, pathogenic_range):
        """
        The custom_normalisation function:
            This function takes a value, and two lists. These lists represent
            a range in which the value could be. Depending on the value, it is
            scaled to either a score between 0 and 0.5 or 0.5 and 1.0. This
            score is returned.
        """
        if x <= benign_range[1]:
            return (
                0.5
                * (x - benign_range[0])
                / (benign_range[1] - benign_range[0])
            )
        else:
            return 0.5 + 0.5 * (x - pathogenic_range[0]) / (
                pathogenic_range[1] - pathogenic_range[0]
            )

    def normalise_training_data(self):
        """
        The normalise_training_data function:
            This function takes the combined score tsv, scales the values
            through knowledge-based scaling, min-max scaling and max scaling.
            These scaled scores are written to a file.
        """
        # Load the input table.
        combined_df = pd.read_csv(
            self.output + "-combined.tsv",
            delimiter="\t",
            dtype=self.dtype_options_combined,
        )
        # Define the total set of features.
        features = [
            "CADD_PHRED",
            "CADD_RAW",
            "CAPICE_SCORE",
            "FATHMM_MKL_C",
            "FATHMM_MKL_NC",
            "EXOMISER_GENE_COMBINED_SCORE",
            "PHEN2GENE_RANK",
        ]
        # Define the thresholds for the negative value features.
        feature_threholds = {
            "CADD_RAW": 1.654,
            "FATHMM_MKL_C": 0.123,
            "FATHMM_MKL_NC": 0.2137,
        }
        # Remove rows with missing values.
        combined_df_clean = combined_df.dropna(subset=features)
        combined_df_clean = combined_df_clean.dropna(subset=["CLASS"])
        # Normalise the CADD PHRED values to a range between 0 and 1 using
        # min max scaling.
        combined_df_clean["CADD_PHRED_NORMALISED"] = (
            combined_df_clean["CADD_PHRED"]
            + (abs(min(combined_df_clean["CADD_PHRED"])) + 1)
        ) / max(combined_df_clean["CADD_PHRED"])
        print(
            "CADD_PHRED min: "
            + str((abs(min(combined_df_clean["CADD_PHRED"])) + 1))
        )
        print("CADD_PHRED max: " + str(max(combined_df_clean["CADD_PHRED"])))
        # Normalise features with negative values based on benign and
        # pathogenic ranges, through the use of knowledge based normaliation.
        for feature in ["CADD_RAW", "FATHMM_MKL_C", "FATHMM_MKL_NC"]:
            benign_range = [
                min(combined_df_clean[feature]),
                feature_threholds[feature],
            ]
            pathogenic_range = [
                feature_threholds[feature],
                max(combined_df_clean[feature]),
            ]
            combined_df_clean[feature + "_NORMALISED"] = combined_df_clean[
                feature
            ].apply(
                lambda x: self.custom_normalisation(
                    x, benign_range, pathogenic_range
                )
            )
            print("Benign range: " + str(feature) + ": " + str(benign_range))
            print(
                "Pathogenic range: "
                + str(feature)
                + ": "
                + str(pathogenic_range)
            )
        # Normalise the PHEN2GENE ranking to be within a 0 to 1 range.
        combined_df_clean["PHEN2GENE_RANK_NORMALISED"] = 1 - (
            combined_df_clean["PHEN2GENE_RANK"]
            / max(combined_df_clean["PHEN2GENE_RANK"])
        )
        print("PHEN2GENE max: " + str(max(combined_df_clean["PHEN2GENE_RANK"])))
        combined_df_clean.to_csv(
            self.output + "-combined-clean-normalised.tsv",
            sep="\t",
            index=False,
        )

    def random_forest_classifier(self):
        """
        The random_forest_classifier function:
            This function uses the scaled scores to create a random forest
            classifier and extract feature importance.
        """
        # Load the input table.
        df = pd.read_csv(
            self.output + "-combined-clean-normalised.tsv",
            delimiter="\t",
            dtype=self.dtype_options_combined_clean_normalised,
        )
        # Define the total set of normalised features.
        normalised_features = [
            "CADD_PHRED_NORMALISED",
            "CADD_RAW_NORMALISED",
            "CAPICE_SCORE",
            "FATHMM_MKL_C_NORMALISED",
            "FATHMM_MKL_NC_NORMALISED",
            "EXOMISER_GENE_COMBINED_SCORE",
            "PHEN2GENE_RANK_NORMALISED",
        ]
        # Create a random forest classifier.
        X = df[normalised_features]
        y = df["CLASS"].map({"Benign": 0, "Pathogenic": 1})
        rf = RandomForestClassifier()
        rf.fit(X, y)
        feature_importances = rf.feature_importances_
        # Pair feature names with their importance.
        feature_importance_dict = dict(
            zip(normalised_features, feature_importances)
        )
        # Print feature importances with their names.
        print("Feature Importances:")
        for feature, importance in feature_importance_dict.items():
            print(f"{feature}: {importance}")


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script uses an exomiser and vep annotated vcf file to\
                   build a random forest classifier in order to determine\
                   feature weights."
    epilog = "This python script has three dependencies: cyvcf2, sklearn and\
              pandas."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-x",
        "--vep-training",
        action="store",
        dest="vep_training",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the vep annotated training data.",
    )
    parser.add_argument(
        "-y",
        "--exomiser-training",
        action="store",
        dest="exomiser_training",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the exomiser annotated training data.",
    )
    parser.add_argument(
        "-z",
        "--output_training",
        action="store",
        dest="output_path_training",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the output files excluding a tsv extension.",
    )
    parser.add_argument(
        "-p",
        "--phen2gene",
        action="store",
        dest="phen2gene_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the phen2gene file.",
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
    create_tsv = TSV(
        user_arguments.vep_training,
        user_arguments.exomiser_training,
        user_arguments.output_path_training,
    )
    create_tsv.create_vep_tsv()
    create_tsv.create_exomiser_tsv(user_arguments.phen2gene_file)
    create_tsv.combine_tsv()
    create_tsv.normalise_training_data()
    create_tsv.random_forest_classifier()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
