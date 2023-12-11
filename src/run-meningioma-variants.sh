#!/usr/bin/env bash

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

#SBATCH --job-name="meningioma-variants"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/meningioma-variants.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/meningioma-variants.error"
#SBATCH --time=1:15:0
#SBATCH --partition=high,low

investigate_clinvar_variants() {
    # The investigate_clinvar_variants function:
    #     The comparison and investigation is this function focusses on three
    #     different downloads.
    #     The first via the website using the term "meingioma".
    #     The second via the website using the term "meningiomas".
    #     And the last using the HPO term "HP:0002858".
    #     Another distinction is how I collected the gene names from the
    #     download. I first tried using awk, but I was missing genes that
    #     way, so I simply copy pasted the gene collumn to a file "manual".
    clinvar_stats="/mnt/titan/users/j.boom/clinvar/stats.txt"
    clinvar_meningioma_website="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/clinvar_result_meningioma.txt"
    clinvar_meningioma_website_manual_gene_list="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/manual_gene_names_meningioma.txt"
    clinvar_meningiomas_website="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/clinvar_result_meningiomas.txt"
    clinvar_meningiomas_website_manual_gene_list="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/manual_gene_names_meningiomas.txt"
    clinvar_hpo_term_website="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/clinvar_result_hp_term.txt"
    clinvar_hpo_term_website_manual_gene_list="/mnt/titan/users/j.boom/clinvar/clinvar_website_search/manual_gene_names_hp_term.txt"
    rm ${clinvar_stats}

    # Searching for "meningioma" alone resulted in 2346 variants.
    # https://www.ncbi.nlm.nih.gov/clinvar/?term=meningioma
    echo "Website search for "meningioma":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website} \
        | wc -l \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # Narrowing the search down to "hereditary" results in 1212 variants.
    echo "Narrow the search down to "hereditary":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website} \
        | grep --ignore-case "hereditary" \
        | wc -l \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # Now get all gene names for "hereditary meningioma" hits, also include
    # a count.
    echo "Get the unique gene names for "hereditary meningioma":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website} \
        | grep --ignore-case "hereditary" \
        | awk -F '\t' '{print $2}' \
        | sort \
        | uniq \
            --ignore-case \
        | wc -l \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website} \
        | grep --ignore-case "hereditary" \
        | awk -F '\t' '{print $2}' \
        | sort \
        | uniq \
            --ignore-case \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # Seems like some gene names are missing, try extracting the names manually.
    # Don't focus on "hereditary" this time.
    echo "Get the unique gene names for "meningioma" from a manual list:" \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        | wc -l \
        >> ${clinvar_stats}
    cat ${clinvar_meningioma_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # --------------------------------------------------------------------------
    # Searching for meningiomas resulted in 3288 variants.
    # https://www.ncbi.nlm.nih.gov/clinvar/?term=meningiomas
    echo "----------------------------------------------------------------" \
        >> ${clinvar_stats}
    echo "Website search for "meningiomas":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website} \
        | wc -l \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # Narrowing the search down to "hereditary" results in 1301 variants.
    echo "Narrow the search down to "hereditary":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website} \
        | grep --ignore-case "hereditary" \
        | wc -l \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}

    # Now get all gene names for "hereditary meningiomas" hits, also include
    # a count.
    echo "Get the unique gene names for "hereditary meningiomas":" \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website} \
        | grep --ignore-case "hereditary" \
        | awk -F '\t' '{print $2}' \
        | sort \
        | uniq \
            --ignore-case \
        | wc -l \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website} \
        | grep --ignore-case "hereditary" \
        | awk -F '\t' '{print $2}' \
        | sort \
        | uniq \
            --ignore-case \
        >> ${clinvar_stats}
    echo "" \
        >> ${clinvar_stats}
    
    # Seems like some gene names are missing, try extracting the names manually.
    # Two hits were manually corrected (a shift in the columns caused the wrong
    # entry to be selected)
    # 1897C>G was replaced with RET
    # 30063345_30067790del] was replaced with NF2
    # Don't focus on "hereditary" this time.
    echo "Get the unique gene names for "meningiomas" from a manual list:" \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        | wc -l \
        >> ${clinvar_stats}
    cat ${clinvar_meningiomas_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        >> ${clinvar_stats}

    # --------------------------------------------------------------------------
    # https://www.ncbi.nlm.nih.gov/clinvar/?term=%22HP+0002858%22%5BTrait+identifier%5D
    # As suggested by Gerben, lets try using the HPO term.
    # HP:0002858 ("HP 0002858"[Trait identifier])
    # HP:0100010 ("HP 0100010"[Trait identifier])
    # HP:0500089 ("HP 0500089"[Trait identifier])
    # HP:0033714 ("HP 0033714"[Trait identifier])
    # HP:0100009 ("HP 0100009"[Trait identifier])
    # ORPHA:2495 ("ORPHA:2495"[Trait identifier])
    # Only the general HP term had any results, but few in number, 7.
    echo "----------------------------------------------------------------" \
        >> ${clinvar_stats}
    echo "Get the unique gene names for "meningiomas" from a manual list:" \
        >> ${clinvar_stats}
    cat ${clinvar_hpo_term_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        | wc -l \
        >> ${clinvar_stats}
    cat ${clinvar_hpo_term_website_manual_gene_list} \
        | sort \
        | uniq \
            --ignore-case \
        >> ${clinvar_stats}
}

compare_gene_lists() {
    # The compare_gene_lists function:
    #     This function compares the gene names from the list Alicia created
    #     with the list I created using the ClinVar website. The results
    #     are written to a file called gene_comparison.txt.
    gene_list_alicia="/mnt/titan/users/j.boom/clinvar/gene_list_alicia.txt"
    gene_list_script="/mnt/titan/users/j.boom/clinvar/gene_list_script_meningioma_variants.txt"
    results="/mnt/titan/users/j.boom/clinvar/gene_comparison.txt"
    rm "${results}"
    # Sort and deduplicate the gene list from Alicia.
    cat ${gene_list_alicia} \
        | sort \
        | uniq \
            --ignore-case \
        > "/mnt/titan/users/j.boom/clinvar/gene_list_alicia_SORTED.txt"
    # Sort and deduplicate the gene list from ClinVar.
    cat ${gene_list_script} \
        | sort \
        | uniq \
            --ignore-case \
        > "/mnt/titan/users/j.boom/clinvar/gene_list_script_meningioma_variants_SORTED.txt"
    echo "Genes in both lists:" \
        >> "${results}"
    # Compare the gene lists and output the overlapping ones.
    comm \
        -12 \
        "/mnt/titan/users/j.boom/clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
    echo "----------------------------------------------------------------" \
        >> "${results}"
    echo "Genes in list Alicia:" \
        >> "${results}"
    # Compare the gene lists and output the unique ones in the Alicia list.
    comm \
        -23 \
        "/mnt/titan/users/j.boom/clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
    echo "----------------------------------------------------------------" \
        >> "${results}"
    echo "Genes in list ClinVar:" \
        >> "${results}"
    # Compare the gene lists and output the unique ones in the ClinVar list.
    comm \
        -13 \
        "/mnt/titan/users/j.boom/clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
}

investigate_xml_file() {
    xml="/mnt/titan/users/j.boom/clinvar/ClinVarFullRelease_00-latest.xml"
    cat "${xml}" \
        | egrep --ignore-case "meningioma" \
        | wc -l
}

main() {
    # The main function:
    #     Either call the first function that looks into the different
    #     download from ClinVar, or the second function that compares gene
    #     names between what Alicia found and I found.

    #investigate_clinvar_variants
    #compare_gene_lists
    investigate_xml_file
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-meningioma-variants.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-meningioma-variants.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs a search in the ClinVar database in order"
            echo "to find all variants reported to have some connection"
            echo "to meningioma."
            echo ""

            exit
            ;;
        \?)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
        :)
            echo ""
            echo "You've entered an invalid option: -${OPTARG}."
            echo "Please use the -h option for correct formatting information."
            echo ""

            exit
            ;;
    esac
done

main

# Additional information:
# =======================
# The ClinVar database vcf file: https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/
# The ClinVar database xml file: https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/
# The clinvar directory files/folders:
#     ClinVarFullRelease_00-latest.xml (the XML version of the full ClinVar
#                                       database).
#     clinvar.vcf (the VCF version of the full ClinVar database).
#     gene_comparison.txt (the output of this script comparing the gene list
#                          from alicia to the one from ClinVar).
#     gene_list_alicia.txt (genes found by Alicia that are associated to
#                           meningiomas, there is also a sorted version in this
#                           folder).
#     gene_list_script_meningioma-variants.txt (genes found by me using the
#                                               ClinVar website, also a sorted
#                                               version present).
#     stats.txt (the output from the first function in this script, simply
#                counting the number of genes found through variations on
#                downloading variants for meningioma).
#     ./clinvar_website_search (intermediate files used in the first function,
#                               see the description there for more information).
