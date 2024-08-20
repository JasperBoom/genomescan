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
import re
import pandas as pd
from cyvcf2 import VCF


class RANK:
    """
    The RANK class:
        This class takes care of

        This function creates a number of class attributes:
            vep_annotation = a list of strings with the names of each section
                             of annotation that VEP could add to a variant.
            exomiser_annotation = a list of strings with the names of each
                                  annotation field that exomiser adds to a
                                  variant.
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

    def __init__(self, vcf_file, output_name, phen2gene_file):
        """
        The initializer function:
            This function creates a number of instance attributes:
                vcf = the input vcf file that needs to be ranked.
                output = a string to use as the output name of the ranked
                         variants.
                phen2gene_file = the phen2gene ranked gene file.
        """
        self.vcf = vcf_file
        self.output = output_name
        self.phen2gene = phen2gene_file

    @property
    def vcf(self):
        """
        The vcf property function:
            This function converts vcf to a property which results
            in a cyvcf2 object that is returned.
        """
        return self._vcf

    @vcf.setter
    def vcf(self, value):
        """
        The vcf setter function:
            This function reads in a vcf file using the cyvcf2 module.
        """
        self._vcf = VCF(value)

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

    def normalise_scores(self, scores):
        """
        The normalise_scores function:
            This function takes a dictionary with the relevant annotation
            scores and normalises these to a range between 0 and 1. The
            normalised values are returned in a new dictionary.
        """
        normalised_scores = {}
        for key, value in scores.items():
            if value == 0.0:
                normalised_scores[key] = value
            else:
                if key == "CADD_PHRED":
                    normalised_scores["CADD_PHRED"] = (
                        float(value) + 1.0 + 1.0
                    ) / 65.0
                elif key == "CADD_RAW":
                    normalised_scores["CADD_RAW"] = self.custom_normalisation(
                        float(value), [-5.0, 1.654], [1.654, 15.0]
                    )
                elif key == "FATHMM_MKL_C":
                    normalised_scores["FATHMM_MKL_C"] = (
                        self.custom_normalisation(
                            float(value), [-99.0, 0.123], [0.123, 5.0]
                        )
                    )
                elif key == "FATHMM_MKL_NC":
                    normalised_scores["FATHMM_MKL_NC"] = (
                        self.custom_normalisation(
                            float(value), [-99.0, 0.2137], [0.2137, 5.0]
                        )
                    )
                elif key == "PHEN2GENE_RANK":
                    normalised_scores["PHEN2GENE_RANK"] = 1.0 - (
                        float(value) / 10843.0
                    )
                elif (
                    key == "CAPICE_SCORE"
                    or key == "EXOMISER_GENE_COMBINED_SCORE"
                ):
                    normalised_scores[key] = float(value)
        return normalised_scores

    def rank_variants(self, normalised_scores):
        """
        The rank_variant function:

        """
        variant_rank = 0
        weights = {
            "CADD_PHRED": 0.175,
            "CADD_RAW": 0.267,
            "CAPICE_SCORE": 0.135,
            "FATHMM_MKL_C": 0.011,
            "FATHMM_MKL_NC": 0.040,
            "EXOMISER_GENE_COMBINED_SCORE": 0.358,
            "PHEN2GENE_RANK": 0.014,
        }
        for key, value in normalised_scores.items():
            variant_rank += value * weights[key]
        return variant_rank

    def extract_info(self):
        """
        The extract_info function:
            This function
        """
        phen2gene_df = pd.read_csv(self.phen2gene, delimiter="\t")
        phen2gene_df.set_index("Gene", inplace=True)
        with open(self.output + ".tsv", "w") as file_out:
            file_out.write(
                f"CHROM\tPOS\tREF\tALT\t"
                f"CADD_PHRED\tCADD_RAW\tCAPICE_SCORE\t"
                f"FATHMM_MKL_C\tFATHMM_MKL_NC\t"
                f"EXOMISER_GENE_COMBINED_SCORE\t"
                f"PHEN2GENE_RANK\tVARIANT_SCORE\n"
            )
            for variant in self.vcf:
                chrom = variant.CHROM
                pos = variant.POS
                ref = variant.REF
                alt = variant.ALT
                csq_info = variant.INFO.get("CSQ", "")
                csq_annotation = csq_info.split(",")[0].split("|")
                csq_annotation_dict = dict(
                    zip(self.vep_annotation, csq_annotation)
                )
                exomiser_annotation = self.parse_exomiser_info(
                    variant.INFO.get("Exomiser", "")
                )
                exomiser_annotation_dict = dict(
                    zip(self.exomiser_annotation, exomiser_annotation)
                )
                if (
                    exomiser_annotation_dict["GENE_SYMBOL"]
                    in phen2gene_df.index
                ):
                    phen2gene_rank = phen2gene_df.loc[
                        exomiser_annotation_dict["GENE_SYMBOL"], "Rank"
                    ]
                else:
                    phen2gene_rank = 10843
                scores = {
                    "CADD_PHRED": (
                        csq_annotation_dict["CADD_PHRED"]
                        if csq_annotation_dict["CADD_PHRED"]
                        else 0.0
                    ),
                    "CADD_RAW": (
                        csq_annotation_dict["CADD_RAW"]
                        if csq_annotation_dict["CADD_RAW"]
                        else 0.0
                    ),
                    "CAPICE_SCORE": (
                        csq_annotation_dict["CAPICE_SCORE"]
                        if csq_annotation_dict["CAPICE_SCORE"]
                        else 0.0
                    ),
                    "FATHMM_MKL_C": (
                        csq_annotation_dict["FATHMM_MKL_C"]
                        if csq_annotation_dict["FATHMM_MKL_C"]
                        else 0.0
                    ),
                    "FATHMM_MKL_NC": (
                        csq_annotation_dict["FATHMM_MKL_NC"]
                        if csq_annotation_dict["FATHMM_MKL_NC"]
                        else 0.0
                    ),
                    "EXOMISER_GENE_COMBINED_SCORE": (
                        exomiser_annotation_dict["EXOMISER_GENE_COMBINED_SCORE"]
                        if exomiser_annotation_dict[
                            "EXOMISER_GENE_COMBINED_SCORE"
                        ]
                        else 0.0
                    ),
                    "PHEN2GENE_RANK": phen2gene_rank,
                }
                normalised_scores = self.normalise_scores(scores)
                variant_rank = self.rank_variants(normalised_scores)
                file_out.write(
                    f"{chrom}\t{pos}\t{ref}\t{alt}\t"
                    f"{normalised_scores["CADD_PHRED"]}\t"
                    f"{normalised_scores["CADD_RAW"]}\t"
                    f"{normalised_scores["CAPICE_SCORE"]}\t"
                    f"{normalised_scores["FATHMM_MKL_C"]}\t"
                    f"{normalised_scores["FATHMM_MKL_NC"]}\t"
                    f"{normalised_scores["EXOMISER_GENE_COMBINED_SCORE"]}\t"
                    f"{normalised_scores["PHEN2GENE_RANK"]}\t"
                    f"{variant_rank}\n"
                )

    def sort_tsv(self):
        """
        The sort_tsv function:
            This function reads in the tsv file and sorts on the variant score
            column, overwriting the input tsv.
        """
        df = pd.read_csv(self.output + ".tsv", sep="\t")
        df_sorted = df.sort_values(by="VARIANT_SCORE", ascending=False)
        df_sorted.to_csv(self.output + ".tsv", sep="\t", index=False)


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script normalizes the input scores and ranks the\
                   variants."
    epilog = "This python script has two dependencies: cyvcf2 and pandas."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
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
        "-f",
        "--filtered-vcf",
        action="store",
        dest="filtered_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the vep and exomiser filtered vcf file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the output file.",
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
    ranking = RANK(
        user_arguments.filtered_file,
        user_arguments.output_file,
        user_arguments.phen2gene_file,
    )
    ranking.extract_info()
    ranking.sort_tsv()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
