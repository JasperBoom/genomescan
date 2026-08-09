# GENOMESCAN-INTERNSHIP CHANGELOG
## [Unreleased]
### Development build
#### Added
- Add files, scripts and workflow for the snakemake tutorial.
- Add scripts for testing a bunch of simulation tools.
  - pgsim
  - genebreaker
- Add test scripts for exomizer.
- Add test scripts for neat (3.4 & 4.0) and phen2gene.
- Add scripts for python and snakemake code formatting.
- Add scripts for converting mysql dump to sqlite.
- Add a python script for generating benchmarking vcf files. These include
  both pathogenic variants (based on ids) and benign variants (based on
  allele frequency).
- Add scripts that download reference files, run picard for indexing, setup
  an interactive slurm job, format both python and snake files to known
  standards and add the python script from fathmm with a test to convert it
  to using sqlite3.
- Add a python script that runs exomiser with different settings in order
  to determine the optimal threshold.
- Add a README for the python scripts.
- Added an object oriented programming tutorial for python, followed the steps.
- A Makefile with some helpfull commands.

#### Changed
- Restructure folders and files for the snakemake tutorial.
- Modify neat script and add a script for vep annotation.
- Move main data files to new location on hpc and adjust file paths.
  - New location: /mnt/titan/users/j.boom
- Checked formatting for all files, also include test vcf files.
- Split the old Quarto document into two, the first looking into the ClinVar
  and GIAB test dataset. The second looking into the combination of the
  previously mentioned dataset and two individuals from the UK Personal Genome
  project.
- Remove time limit from all bash scripts.
- Update the R analysis with fully annotated plots.
- Remove scripts that were either unfinished and not needed or scripts that
  were replaced by others.
- R analysis scripts now consist of 3 files for testing different
  giab/clinvar test sets, a few scripts looking at the uk personal genome
  project and clinvar combo and scripts testing the thresholds.
- Removed the test data folder from the repo because the data was starting to
  become too big.
- Organise the r-scripts to include only useful code, also look into adding
  extra vep annotation as possible filter.
- Convert exomiser script to multiple OOP scripts, including a script to
  visualise the ROC plot.
- Finish scripts for Exomiser thresholding.
- Update paths to files on HPC.
- Finish python script that determines feature weights for final ranking.
- Major rework of the repository structure and files.
- Update all documentation to reflect the new structure and files and 
  the content of the internship.

#### Notes

```text
Copyright (C) 2025 Jasper Boom. All rights reserved.

Proprietary and confidential. Unauthorized use, copying, modification,
distribution, reverse engineering, disclosure, or creation of derivative
works is strictly prohibited without prior written permission from
Jasper Boom.
```