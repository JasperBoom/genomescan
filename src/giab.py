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


def write_output(
    all_output,
    pathogenic_output,
    benign_output,
    pathogenic_variants,
    benign_variants,
    header,
):
    """
    The write_output function:
        This function gets the output locations for three files. All variants
        including a correct vcf header are written to all_output. The other
        two outputs speak for themselves.
    """
    with open(all_output, "a") as all, open(
        pathogenic_output, "a"
    ) as pathogenic, open(benign_output, "a") as benign:
        with open(header, "r") as header:
            for line in header:
                all.write(line)
                pathogenic.write(line)
                benign.write(line)
        for variant_p in pathogenic_variants:
            all.write(variant_p)
            pathogenic.write(variant_p)
        for variant_b in benign_variants:
            all.write(variant_b)
            benign.write(variant_b)


def collect_benign_variants(giab, gene_symbols, info_field):
    """
    The collect_benign_variants function:
        This function uses the giab vcf file to collect variants located the
        same genes as the pathogenic variants are found. These variants need
        to have an allele frequency of atleast 0.8. They are stored in a list
        which is returned. The info starting from column 6 is replaced a by
        default place holder which mirrors standard DRAGEN output.
    """
    variants = []
    with open(giab, "r") as file:
        for line in file:
            if line.startswith("##INFO=<ID=CSQ"):
                columns = line.strip('">\n').split(" ")[-1].split("|")
                max_af = columns.index("MAX_AF")
                symbol = columns.index("SYMBOL")
            if line.startswith("#"):
                pass
            else:
                info = line.split("CSQ=")[1].split("|")
                if info[symbol] in gene_symbols:
                    if info[max_af] != "":
                        if float(info[max_af]) > 0.8:
                            if line not in variants:
                                variants.append(
                                    "\t".join(line.split("\t")[:5])
                                    + "\t"
                                    + info_field
                                )
    return variants


def collect_pathogenic_variants(ids, clinvar, info_field):
    """
    The collect_pathogenic_variants function:
        This function uses the variation ids to collect vcf entries from the
        clinvar vcf. These variants are stored in a list and returned. The
        info starting from column 6 is replaced a by default place holder which
        mirrors standard DRAGEN output.
    """
    variants = []
    with open(clinvar, "r") as file:
        for line in file:
            if line.startswith("#"):
                pass
            else:
                if line.strip("\n").split("\t")[2] in ids:
                    if line not in variants:
                        variants.append(
                            "\t".join(line.split("\t")[:5]) + "\t" + info_field
                        )
    return variants


def collect_pathogenic_ids(ids):
    """
    The collect_pathogenic_ids function:
        This function uses the files containing clinvar variation ids. The ids
        and gene symbols are stored in seperate lists, these are returned.
    """
    id_list = []
    gene_symbol_list = []
    for file in ids.split(","):
        with open(file, "r") as txt:
            for line in txt:
                if line.strip("\n").startswith("#"):
                    gene_symbol = line.strip("\n").split(" ")[1]
                    if gene_symbol not in gene_symbol_list:
                        gene_symbol_list.append(gene_symbol)
                    else:
                        print(gene_symbol + " has already been collected.")
                else:
                    id_list.append(line.strip("\n"))
    return gene_symbol_list, id_list


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "A python script for generating test vcf files. This uses\
                   clinvar variation IDs of known pathogenic variants and a\
                   vep annotated giab vcf file, and the clinvar vcf download."
    epilog = "This python script has no dependencies"
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-g",
        "--giab",
        action="store",
        dest="giab_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The input giab vcf file.",
    )
    parser.add_argument(
        "-i",
        "--ids",
        action="store",
        dest="id_files",
        type=str,
        default=argparse.SUPPRESS,
        help="Files containing pathogenic associated variation IDs\
              split on comma's, requires full path.",
    )
    parser.add_argument(
        "-c",
        "--clinvar",
        action="store",
        dest="clinvar_file",
        type=str,
        default=argparse.SUPPRESS,
        help="Files containing pathogenic associated variation IDs\
              split on comma's, requires full path.",
    )
    parser.add_argument(
        "-d",
        "--header",
        action="store",
        dest="header_file",
        type=str,
        default=argparse.SUPPRESS,
        help="File containing the default header of a vcf to use when creating\
              a benchmark vcf file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The name and location for the output VCF file.",
    )
    parser.add_argument(
        "-p",
        "--pathogenic",
        action="store",
        dest="pathogenic_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The name and location for the output VCF file containing\
              pathogenic variants.",
    )
    parser.add_argument(
        "-b",
        "--benign",
        action="store",
        dest="benign_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The name and location for the output VCF file containing\
              benign variants from giab.",
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
    default_info_field = "24.24\tPASS\tAC=2;AF=1.000;AN=2;DP=250;FS=0.000;MQ=100;MQRankSum=0.5;QD=6;ReadPosRankSum=0.5;SOR=0.6;FractionInformativeReads=0.9\tGT:AD:AF:DP:F1R2:F2R1:GQ:PL:GP\t1/1:1,219:0.994:220:0,110:0,110:99:295,316,0:0.05,0.09,0.86\n"
    user_arguments = parse_argvs()
    symbols, ids = collect_pathogenic_ids(user_arguments.id_files)
    pathogenic_variants = collect_pathogenic_variants(
        ids, user_arguments.clinvar_file, default_info_field
    )
    benign_variants = collect_benign_variants(
        user_arguments.giab_file, symbols, default_info_field
    )
    write_output(
        user_arguments.output_location,
        user_arguments.pathogenic_location,
        user_arguments.benign_location,
        pathogenic_variants,
        benign_variants,
        user_arguments.header_file,
    )


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
