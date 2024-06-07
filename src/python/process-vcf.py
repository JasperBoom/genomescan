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
from cyvcf2 import VCF


class VEP:
    """
    The VEP class:
        This function creates a number of class attributes:
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
        "SOURCE",
        "CADD_PHRED",
        "CADD_RAW",
        "CAPICE_SCORE",
        "FATHMM_MKL_C",
        "FATHMM_MKL_NC",
        "ClinVar",
        "ClinVar_CLNSIG",
    ]
    score_names = [
        "CADD_PHRED",
        "CADD_RAW",
        "CAPICE_SCORE",
        "FATHMM_MKL_C",
        "FATHMM_MKL_NC",
    ]

    def __init__(self, vcf_file, output_name, vep_thresholds):
        """
        The initializer function:
            This function creates an instance attribute:
        """
        self.vcf = vcf_file
        self.output = output_name
        self.thresholds = vep_thresholds

    @property
    def vcf(self):
        """
        The vcf property function:
            This function converts vcf to a property which score_classification in a
            corrected list that is returned.
        """
        return self._vcf

    @vcf.setter
    def vcf(self, value):
        """
        The vcf setter function:
            This function reads in a vcf file using the cyvcf2 module.
        """
        self._vcf = VCF(value)

    def filter_vep(self):
        """
        The filter_vep function:
        """
        with open(self.output, "w") as file_out:
            file_out.write(self.vcf.raw_header)
            for variant in self.vcf:
                csq_info = variant.INFO.get("CSQ", "N/A")
                class_info = variant.INFO.get("Class", "N/A")
                if csq_info != "N/A" and class_info != "N/A":
                    annotation = csq_info.split(",")[0].split("|")
                    annotation_dict = dict(zip(self.vep_annotation, annotation))
                    score_classification = []
                    for key, threshold in zip(
                        self.score_names, self.thresholds
                    ):
                        value = annotation_dict.get(key, None)
                        if value is not None and value != "":
                            value = float(value)
                            if value > threshold:
                                score_classification.append("Pathogenic")
                            else:
                                score_classification.append("Benign")
                if score_classification:
                    pathogenic_count = score_classification.count("Pathogenic")
                    benign_count = score_classification.count("Benign")
                    if pathogenic_count > benign_count:
                        predicted_class = "Pathogenic"
                    elif benign_count > pathogenic_count:
                        predicted_class = "Benign"
                    else:
                        predicted_class = "Unknown"
                else:
                    predicted_class = "Unknown"
                print(score_classification)
                print(predicted_class)

    def check_missing_scores(self):
        """
        The check_missing_scores function:
        """
        # SETUP VARIANT COUNTERS
        total_variants = 0
        count_with_five_values = 0
        count_with_three_values = 0
        count_without_any_value = 0
        count_with_other_number_of_values = 0
        for variant in self.vcf:
            csq_info = variant.INFO.get("CSQ", "N/A")
            class_info = variant.INFO.get("Class", "N/A")
            if csq_info != "N/A" and class_info != "N/A":
                annotation = csq_info.split(",")[0].split("|")
                annotation_dict = dict(zip(self.vep_annotation, annotation))
                # COUNT THE NUMBER OF SCORES PRESENT OUT OF 5
                values_present = [
                    annotation_dict[field]
                    for field in self.score_names
                    if annotation_dict[field]
                ]
                num_values_present = len(values_present)
                if class_info == "Benign" or class_info == "Pathogenic":
                    # COUNT TOTAL NUMBER OF VARIANTS
                    total_variants += 1
                    # KEEP TRACK OF NUMBER OF FILLED ANNOTATIONS
                    if num_values_present == 5:
                        count_with_five_values += 1
                    elif num_values_present == 3:
                        count_with_three_values += 1
                    elif num_values_present == 0:
                        count_without_any_value += 1
                    elif num_values_present == 1 or num_values_present == 4:
                        count_with_other_number_of_values += 1
        # PRINT THE COUNTS
        print(f"Total variants: {total_variants}")
        print(
            f"Variants with five values in specified fields: {count_with_five_values}"
        )
        print(
            f"Variants with three values in specified fields: {count_with_three_values}"
        )
        print(
            f"Variants without any value in specified fields: {count_without_any_value}"
        )
        print(
            f"Variants with either one or four values in specified fields: {count_with_other_number_of_values}"
        )


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
        "-i",
        "--vcf",
        action="store",
        dest="vcf_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the full path to the input vcf file.",
    )
    parser.add_argument(
        "-e",
        "--ensembl",
        action="store",
        dest="vep_thresholds",
        type=list,
        default=[17.18, 1.654, 0.0059, 0.123, 0.2137],
        help="a list of floats to use as thresholds for vep annotation. The\
              order of annotation scores is: CADD phred, CADD raw, CAPICE,\
              FATHMM MKL coding, FATHMM MKL, noncoding.",
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
    output_file = user_arguments.vcf_file[:-3] + "vep_filtered.vcf"
    vep = VEP(
        user_arguments.vcf_file, output_file, user_arguments.vep_thresholds
    )
    # vep.check_missing_scores()
    vep.filter_vep()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
