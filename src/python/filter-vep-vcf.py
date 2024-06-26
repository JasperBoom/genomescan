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
        This class takes care of filtering a vcf file based on VEP annotation.
        The variants that pass all filters are written to a new file.

        This function creates a number of class attributes:
            vep_annotation = a list of strings with the names of each bit of
                             annotation that VEP could add to a variant.
            score_names = a list of strings with the names of the annotation
                          scores that are used for the filtering.
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
                vcf = the input vcf file that needs to be filtered.
                output = a string to use as the output name of the filtered vcf
                         file.
                thresholds = a list of floats to use as thresholds for the
                             annotation scores.
        """
        self.vcf = vcf_file
        self.output = output_name
        self.thresholds = vep_thresholds

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

    def filter_vep(self):
        """
        The filter_vep function:
            This function filters a vcf file. It opens a new file, then loops
            through all variants in the input vcf file. It collects the
            annotation scores of interest, applies the input thresholds, and
            checks the final class (if all 5 scores are present). Any variants
            called pathogenic or with too few annotation scores are written to
            the new file.
        """
        with open(self.output, "w") as file_out:
            file_out.write(self.vcf.raw_header)
            for variant in self.vcf:
                csq_info = variant.INFO.get("CSQ", "N/A")
                if csq_info != "N/A":
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
                if score_classification and len(score_classification) == 5:
                    pathogenic_count = score_classification.count("Pathogenic")
                    benign_count = score_classification.count("Benign")
                    if pathogenic_count > benign_count:
                        file_out.write(str(variant))
                    elif benign_count > pathogenic_count:
                        pass
                else:
                    file_out.write(str(variant))

    def create_confusion_matrix(self):
        """
        The create_confusion_matrix function:
            This function is used to calculate the metrics for a confusion
            matrix, using the new first filtering method (where variants
            missing annotation scores are kept for Exomiser instead of
            removed).
        """
        total_variants = 0
        unknown_variants = 0
        true_positives = 0
        true_negatives = 0
        false_positives = 0
        false_negatives = 0
        for variant in self.vcf:
            total_variants += 1
            csq_info = variant.INFO.get("CSQ", "N/A")
            class_info = variant.INFO.get("Class", "N/A")
            if csq_info != "N/A":
                annotation = csq_info.split(",")[0].split("|")
                annotation_dict = dict(zip(self.vep_annotation, annotation))
                score_classification = []
                for key, threshold in zip(self.score_names, self.thresholds):
                    value = annotation_dict.get(key, None)
                    if value is not None and value != "":
                        value = float(value)
                        if value > threshold:
                            score_classification.append("Pathogenic")
                        else:
                            score_classification.append("Benign")
            if score_classification and len(score_classification) == 5:
                pathogenic_count = score_classification.count("Pathogenic")
                benign_count = score_classification.count("Benign")
                if pathogenic_count > benign_count:
                    predicted_class = "Pathogenic"
                elif benign_count > pathogenic_count:
                    predicted_class = "Benign"
                if (
                    class_info == "Pathogenic"
                    and predicted_class == "Pathogenic"
                ):
                    true_positives += 1
                elif class_info == "Benign" and predicted_class == "Benign":
                    true_negatives += 1
                elif class_info == "Benign" and predicted_class == "Pathogenic":
                    false_positives += 1
                elif class_info == "Pathogenic" and predicted_class == "Benign":
                    false_negatives += 1
            else:
                unknown_variants += 1
        print("The total number of variants = " + str(total_variants))
        print("The number of unknown variants = " + str(unknown_variants))
        print("True positives " + str(true_positives))
        print("True negatvies " + str(true_negatives))
        print("False positives " + str(false_positives))
        print("False negatives " + str(false_negatives))


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This python script is used to filter a VEP annotated vcf\
                   file based on input thresholds, the variants that pass the\
                   filter are written to a new file."
    epilog = "This python script has one dependency: cyvcf2."
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
    output_file = user_arguments.vcf_file[:-3] + "vep.filtered.vcf"
    vep = VEP(
        user_arguments.vcf_file, output_file, user_arguments.vep_thresholds
    )
    vep.filter_vep()
    # Used during training and testing.
    # vep.create_confusion_matrix()


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
