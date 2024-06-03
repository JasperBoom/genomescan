# /mnt/titan/users/j.boom
This file contains a description of the folders on the titan users mount.  
The descriptions concern what files are in the folders or what operations were
performed to generate the files.

## capture-kit-bed-files
This folder contains bed files for both hg38 and hg19 used by genomescan when
performing variant calling or other analysis steps. The bed file describes the
agilent capture kits.

The 50bp flank files extend the regions by 50 basepairs on both sides.  
S31285117 is used for agilent sureselect human all exon v7 on hg19.

I stopped using these files on 2024-02-13.

## clinvar-giab-data
This folder contains subfolders with VEP tabular files based on vcf files
collected from ClinVar. the folder name indicates what kind of cancer was used
as search term in ClinVar. These files are used by the R scripts.  
It also contains a header vcf file, which is used to create new vcf files.

## data
This folder contains all files used for the R analysis and Exomiser analysis.
So, the test data from the personal genome project uk (**pgpuk**), an
annotated giab sample (**giab**), the input files for the vep plugins and
reference (**vep**) and the clinvar download (**clinvar**).  
Additionally, **tsv** and **vcf** folders that contain uk personal genome
vcf files combined with pathogenic variants and **pathogenic-variants** that
contains vcf files used for the files in the datestamped folders.

## errors & logs
Simply the error and log output from sbatch commands for all things I submit.
Are deleted regularly when doing tests.

## manual-clinvar
This folder contains the downloads from the ClinVar database.  
These are the full vcf files, both grch37 and grch38 and the xml version.  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/  
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/xml/

Furthermore, a number of txt files that are created by some comparison
commands in the script run-meningioma-variant.sh.

I stopped using these files on 2024-02-13.

**clinvar_website_search** contains text files downloaded using the clinvar
search bar, using the human phenotype ontology term for meningioma, the term
"meningioma" itself and "meningiomas". The files with manual are gene names
from these downloads extracted by hand instead of using awk, since I wasn't able
to get awk to perform the right actions.

## snakemake-tutorial
This folder has the data files for the snakemake tutorial: 
https://snakemake.readthedocs.io/en/stable/tutorial/basics.html

## tmp
Just a folder to direct temporary files to, for example when running java
based tools.

## tools
This folder contains a collection of subfolders mostly targeted at different
simulation tools. The **data** folder contains reference files from ensembl.  
The **simulated_data** contains output files from tests with neat. The rest are
either install locations of tools or contain files required for running the
tool.

```
GenomeScan internship repository.
Copyright (C) 2023 Jasper Boom

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

Contact information: info@jboom.org.
```