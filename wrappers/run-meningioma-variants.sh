#!/usr/bin/env bash
# Copyright (C) 2025 Jasper Boom. All rights reserved.
#
# Proprietary and confidential. Unauthorized use, copying, modification,
# distribution, reverse engineering, disclosure, or creation of derivative
# works is strictly prohibited without prior written permission from
# Jasper Boom.

#SBATCH --job-name="meningioma-variants"
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --partition=all

investigate_clinvar_variants() {
    # The investigate_clinvar_variants function:
    #     The comparison and investigation in this function focusses on three
    #     different downloads.
    #     The first via the website using the term "meingioma".
    #     The second via the website using the term "meningiomas".
    #     And the last using the hpo term "HP:0002858".
    #     Another distinction is how I collected the gene names from the
    #     download. I first tried using awk, but I was missing genes that
    #     way, so I simply copy pasted the gene collumn to a file "manual".
    clinvar_stats="/mnt/titan/users/j.boom/manual-clinvar/stats.txt"
    clinvar_meningioma_website="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/clinvar_result_meningioma.txt"
    clinvar_meningioma_website_manual_gene_list="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/manual_gene_names_meningioma.txt"
    clinvar_meningiomas_website="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/clinvar_result_meningiomas.txt"
    clinvar_meningiomas_website_manual_gene_list="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/manual_gene_names_meningiomas.txt"
    clinvar_hpo_term_website="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/clinvar_result_hp_term.txt"
    clinvar_hpo_term_website_manual_gene_list="/mnt/titan/users/j.boom/manual-clinvar/clinvar_website_search/manual_gene_names_hp_term.txt"
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

    # -------------------------------------------------------------------------
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
    # 1897C>G was replaced with ret
    # 30063345_30067790del] was replaced with nf2
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

    # -------------------------------------------------------------------------
    # https://www.ncbi.nlm.nih.gov/clinvar/?term=%22HP+0002858%22%5BTrait+identifier%5D
    # As suggested by Gerben, lets try using the HPO term.
    # HP:0002858 ("HP 0002858"[Trait identifier])
    # HP:0100010 ("HP 0100010"[Trait identifier])
    # HP:0500089 ("HP 0500089"[Trait identifier])
    # HP:0033714 ("HP 0033714"[Trait identifier])
    # HP:0100009 ("HP 0100009"[Trait identifier])
    # ORPHA:2495 ("ORPHA:2495"[Trait identifier])
    # Only the general hpo term had any results, but few in number, 7.
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
    #     with the list I created using the clinvar website. The results
    #     are written to a file called gene_comparison.txt.
    gene_list_alicia="/mnt/titan/users/j.boom/manual-clinvar/gene_list_alicia.txt"
    gene_list_script="/mnt/titan/users/j.boom/manual-clinvar/gene_list_script_meningioma_variants.txt"
    results="/mnt/titan/users/j.boom/manual-clinvar/gene_comparison.txt"
    rm "${results}"

    # Sort and deduplicate the gene list from Alicia.
    cat ${gene_list_alicia} \
        | sort \
        | uniq \
            --ignore-case \
        > "/mnt/titan/users/j.boom/manual-clinvar/gene_list_alicia_SORTED.txt"

    # Sort and deduplicate the gene list from clinvar.
    cat ${gene_list_script} \
        | sort \
        | uniq \
            --ignore-case \
        > "/mnt/titan/users/j.boom/manual-clinvar/gene_list_script_meningioma_variants_SORTED.txt"
    echo "Genes in both lists:" \
        >> "${results}"

    # Compare the gene lists and output the overlapping ones.
    comm \
        -12 \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
    echo "----------------------------------------------------------------" \
        >> "${results}"
    echo "Genes in list Alicia:" \
        >> "${results}"

    # Compare the gene lists and output the unique ones in the Alicia list.
    comm \
        -23 \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
    echo "----------------------------------------------------------------" \
        >> "${results}"
    echo "Genes in list ClinVar:" \
        >> "${results}"

    # Compare the gene lists and output the unique ones in the clinvar list.
    comm \
        -13 \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_alicia_SORTED.txt" \
        "/mnt/titan/users/j.boom/manual-clinvar/gene_list_script_meningioma_variants_SORTED.txt" \
        >> "${results}"
}

investigate_xml_file() {
    # The investigate_xml_file function:
    #     Checks the entries in the clinvar xml file for mentions of
    #     meningioma.
    xml="/mnt/titan/users/j.boom/manual-clinvar/ClinVarFullRelease_00-latest.xml"
    cat "${xml}" \
        | egrep --ignore-case "meningioma" \
        | wc -l
}

main() {
    # The main function:
    #     This function calls all processing functions in correct order.
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
            echo "This script runs a search in clinvar downloads in order"
            echo "to find all variants reported to have some connection"
            echo "to meningioma. It creates some files and does some counting"
            echo "in order to compare the results between different search"
            echo "terms and results that were previously produced."
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