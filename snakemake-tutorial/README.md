# GENOMESCAN snakemake-tutorial
This folder contains a compact Snakemake training workflow that demonstrates
the structure of a reproducible bioinformatics pipeline. It includes a main
workflow file, modular rule definitions, supporting scripts, and
configuration-driven inputs and paths. The tutorial is designed to show how
rules are chained, how sample-wise jobs are expanded from configuration, and
how final outputs are collected through a default target rule.

The workflow is organised around snakefile.smk, with additional mapping rules
in read-mapping.smk, plotting logic in plot-quals.py, and runtime settings in
config.yaml. The images folder contains visual material such as the rule graph.

Before running the tutorial, review and adapt the absolute paths in the
configuration file to match your local environment or HPC workspace. This
ensures that input data, script locations, and output directories resolve
correctly for your system.

```text
Copyright (C) 2025 Jasper Boom. All rights reserved.

Proprietary and confidential. Unauthorized use, copying, modification,
distribution, reverse engineering, disclosure, or creation of derivative
works is strictly prohibited without prior written permission from
Jasper Boom.
```