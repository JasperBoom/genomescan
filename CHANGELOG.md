# Changelog
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

## Develop
+ Add files, scripts and workflow for the snakemake tutorial.
+ Restructure folders and files for the snakemake tutorial.
+ Add scripts for testing a bunch of simulation tools.
    + pgsim.
    + genebreaker.
+ Add test scripts for exomizer.
+ Add test scripts for neat (3.4 & 4.0) and phen2gene.
+ Add scripts for python and snakemake code formatting.
+ Modify neat script and add a script for vep annotation.
+ Move main data files to new location on hpc and adjust file paths.
    + New location: /mnt/titan/users/j.boom
+ Add scripts for converting mysql dump to sqlite.
+ Add a python script for generating benchmarking vcf files. These include
  both pathogenic variants (based on ids) and benign variants (based on
  allele frequency).
+ Add scripts that download reference files, run picard for indexing, setup
  an interactive slurm job, format both python and snake files to known
  standards and add the python script from fathmm with a test to convert it
  to using sqlite3.
+ Checked formatting for all files, also include test vcf files.
+ Split the old Quarto document into two, the first looking into the ClinVar
  and GIAB test dataset. The second looking into the combination of the
  previously mentioned dataset and two individuals from the UK Personal Genome
  project.
+ Remove time limit from all bash scripts.
+ Update the R analysis with fully annotated plots.
+ Remove scripts that were either unfinished and not needed or scripts that
  were replaced by others.
+ R analysis scritps now consist out of 3 files for testing different
  giab/clinvar test sets, a few scripts looking at the uk personal genome
  project and clinvar combo and scripts testing the thresholds.
+ Removed the test data folder from the repo because the data was starting to
  become to big.