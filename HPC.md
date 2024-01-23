# /mnt/titan/users/j.boom
This file contains a description of the folders on the titan users mount.  
The descriptions concern what files are in the folders or what operations were
performed to generate the files.

## bed
This folder contains bed files for both hg38 and hg19 (named hg37) used by
genomescan when performing variant calling or other analysis steps. The bed
file describes the agilent capture kits.

The 50bp flank files extend the regions by 50 basepairs.  
S31285117 is used for agilent sureselect human all exon v7 on hg19 (named hg37).

## clinvar
This folder contains the downloads from the ClinVar database.  
These were the full vcf file, both grch37 and grch38 and the xml version.  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/

Furthermore, a number of txt files that are created by some comparison
commands in the script run-meningioma-variant.sh.

**clinvar_website_search** contains text files downloaded using the clinvar
search bar, using the human phenotype ontology term for meningioma, the term
"meningioma" itself and "meningiomas". The files with manual are gene names
from these downloads extracted by hand instead of using awk, since I wasn't able
to get awk to perform the right actions.

## errors & logs
Simply the error and log output from sbatch commands for all things I submit.
Are deleted regularly when doing tests.

## snakemake-tutorial
This folder has the data files for the snakemake tutorial: 
https://snakemake.readthedocs.io/en/stable/tutorial/basics.html

## tmp
Just a folder to direct temporary files to, for example when running java
commands.

## tool-testing
This folder contains a collection of subfolders mostly targeted at different
simulation tools. The **data** folder contains reference files from ensembl.
The **simulated_data** contains output files from tests with neat. The rest are
either install locations of tools or contain files required for running the
tool.

## vcf
This folder contains sample sets from diagnostic runs of dragen by
genomescan (**105421-099** & **105861**), then the **giab** folder contains
a benchmark vcf file annotated using vep. And **personalgenomesuk** contains
vcf data from the personal genome project in the uk, which I am using to see
what kind of noise I can introduce to my threshold test variants.