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
import datetime
import gzip
import multiprocessing
import numpy
import os
import pandas as pd
import re
import subprocess
import traceback
import yaml
import time


def write_tsv(vcf, dataframe, output_location):
    """
    The write_tsv function:
        This function uses the full path of the input vcf file and the default
        output location to create a unique filename. This filename is used to
        write the vcf converted dataframe to.
    """
    vcf_list = vcf.split("/")
    filename = (
        output_location
        + "/"
        + vcf_list[6]
        + "_"
        + vcf_list[7]
        + "_"
        + vcf_list[8].split(".")[0]
        + ".tsv"
    )
    dataframe.to_csv(filename, sep="\t", header=True, index=False)


def process_exomiser_vcf(vcf, column_names, mode, pass_only=None):
    """
    The process_exomiser_vcf function:
        This function creates an empty dataframe with columns corresponding to
        the different info fields that exomiser adds to the vcf file. Then
        a vcf file is processed so that the known class and the exomiser info
        are extracted and written to the empty dataframe. If the vcf only
        contains variants that passed all filters, we consider them pathogenic.
        If the vcf contains all variants, a check is performed against the
        pass only vcf, which are pathogenic, the other variants are considered
        benign. This dataframe is returned.
    """
    dataframe_exomiser = pd.DataFrame(columns=column_names)
    with gzip.open(vcf, "r") as file:
        for line in file:
            correct_format_line = str(line, "latin-1")
            if correct_format_line.startswith("#"):
                pass
            else:
                info = correct_format_line.split("\t")[7].split(";")
                known_class = [
                    item for item in info if item.startswith("Class=")
                ][0].strip("Class=")
                exomiser_info = (
                    [item for item in info if item.startswith("Exomiser=")][0]
                    .strip("Exomiser=")
                    .split(",")[0]
                    .strip("{")
                    .strip("}")
                    .split("|")
                )
                if len(exomiser_info) < 18:
                    for add in range(18 - len(exomiser_info)):
                        exomiser_info.append(" ")
                exomiser_info_dictionary = {
                    column_names[item]: exomiser_info[item]
                    for item in range(len(column_names))
                }
                if mode == "PASS_ONLY":
                    exomiser_info_dictionary["PREDICTED_CLASS"] = "Pathogenic"
                elif mode == "FULL":
                    check_class = (
                        pass_only["ID"].isin([exomiser_info_dictionary["ID"]])
                    ).any()
                    if check_class == True:
                        exomiser_info_dictionary["PREDICTED_CLASS"] = (
                            "Pathogenic"
                        )
                    elif check_class == False:
                        exomiser_info_dictionary["PREDICTED_CLASS"] = "Benign"
                exomiser_info_dictionary["KNOWN_CLASS"] = known_class
                dataframe_exomiser = pd.concat(
                    [
                        dataframe_exomiser,
                        pd.DataFrame([exomiser_info_dictionary]),
                    ]
                )
    return dataframe_exomiser


def start_analysis(file_set, output_location):
    """
    The start_analysis function:
        This function creates a list with column names based on the information
        fields that exomiser adds to a vcf file. It then processes a pair of
        files, the same sample, one with just variants that passed all filters,
        the other will all variants. The process_exomiser_vcf function is used
        to create a pandas dataframe, first with just pathogenic variants,
        and later with both benign and pathogenic variants. These dataframes
        are also written to a tsv file.
    """
    exomiser_column_names = [
        "RANK",
        "ID",
        "GENE_SYMBOL",
        "ENTREZ_GENE_ID",
        "MOI",
        "P-VALUE",
        "EXOMISER_GENE_COMBINED_SCORE",
        "EXOMISER_GENE_PHENO_SCORE",
        "EXOMISER_GENE_VARIANT_SCORE",
        "EXOMISER_VARIANT_SCORE",
        "CONTRIBUTING_VARIANT",
        "WHITELIST_VARIANT",
        "FUNCTIONAL_CLASS",
        "HGVS",
        "EXOMISER_ACMG_CLASSIFICATION",
        "EXOMISER_ACMG_EVIDENCE",
        "EXOMISER_ACMG_DISEASE_ID",
        "EXOMISER_ACMG_DISEASE_NAME",
    ]
    for vcf in file_set:
        if "PASS_ONLY" in vcf:
            dataframe_pass_only = process_exomiser_vcf(
                vcf, exomiser_column_names, "PASS_ONLY"
            )
            write_tsv(vcf, dataframe_pass_only, output_location)
            dataframe_full = process_exomiser_vcf(
                vcf.replace("PASS_ONLY", "FULL"),
                exomiser_column_names,
                "FULL",
                dataframe_pass_only,
            )
            write_tsv(
                vcf.replace("PASS_ONLY", "FULL"),
                dataframe_full,
                output_location,
            )


def monitor_logs(log_files, vcf_files, output_location):
    """
    The monitor_logs function:
        This function acts as a watcher of the log files produced by Exomiser.
        It checks the log files from a set for a specific minimal priority
        score. If a specific string is encountered in both log files, the
        start_analysis function is called.
    """
    try:
        while True:
            if all(
                "Exomising finished - Bye!" in open(log_file).read()
                for log_file in log_files
            ):
                start_analysis(vcf_files, output_location)
                break
            time.sleep(30)
    except Exception as e:
        traceback.print_exc()


def worker(queue, output_location):
    """
    The worker function:
        This function acts as a worker assigned to one core. The while loop
        allows the worker to collect a set of files from the queue and process
        these files using the monitor_logs function. Once a set of files has
        been processed a new set can be collected from the queue. The worker
        is closed once it encounters None instead of a set of files.
    """
    while True:
        files = queue.get()
        if files is None:
            break
        else:
            log_files = [file for file in files if file.endswith(".log")]
            vcf_files = [file for file in files if file.endswith(".vcf.gz")]
            if all(os.path.exists(log_file) for log_file in log_files):
                print(vcf_files)
                monitor_logs(log_files, vcf_files, output_location)
            queue.task_done()


def link_output_files(vcf_file_basenames, log_files):
    """
    The link_output_files function:
        This function collects the vcf files and log files that belong to a
        specific minimal priority score and puts these in a list. All the lists
        are stored in a top level list which is returned.
    """
    file_sets = []
    for name in vcf_file_basenames:
        if "PASS_ONLY" in name:
            score = name.split("/")[7]
            file_sets.append(
                [
                    name + ".vcf.gz",
                    (name + ".vcf.gz").replace("PASS_ONLY", "FULL"),
                ]
                + [item for item in log_files if re.search(score, item)]
            )
    return file_sets


def startup_multiprocessing(
    vcf_file_basenames, output_location, log_files, cores
):
    """
    The startup_multiprocessing function:
        This function uses link_output_files to create a nested list of files
        for each tested score setting (which are stored in a list), it starts
        a multiprocessing queue. A number of processes is started equal to the
        number of cores the user provided. The input files are added to the
        queue after which the join() command is used to nicely close the
        processes when they are done.
    """
    file_sets = link_output_files(vcf_file_basenames, log_files)
    queue = multiprocessing.JoinableQueue()
    processes = []
    for core in range(cores):
        process = multiprocessing.Process(
            target=worker, args=(queue, output_location)
        )
        process.start()
        processes.append(process)
    for files in file_sets:
        queue.put(files)
    for core in range(cores):
        queue.put(None)
    for process in processes:
        process.join()


def sbatch(command, basename, log_dir, score, mode):
    """
    The sbatch function:
        This function creates and executes a sbatch command on a slurm system.
        All requirements are filled, like a job name, log/error locations and
        resource requirements. The wrap argument is used to execute a
        cli tool, for which slurm will automatically create a simple bash
        script.
    """
    slurm_name = "exomiser_" + basename + "_" + str(score)
    log_directory = log_dir + "/" + mode
    if not os.path.exists(log_directory):
        os.makedirs(log_directory)
    process = subprocess.Popen(
        [
            "sbatch",
            "--job-name=" + slurm_name,
            "--error=" + log_directory + "/" + slurm_name + ".error",
            "--output=" + log_directory + "/" + slurm_name + ".log",
            "--cpus-per-task=3",
            "--mem=80G",
            "--export=ALL",
            "--partition=all",
            "--wrap=" + command,
        ]
    )
    output, errors = process.communicate()
    if not os.path.exists(log_directory + "/" + slurm_name + ".log"):
        with open(log_directory + "/" + slurm_name + ".log", "w"):
            pass
    return log_directory + "/" + slurm_name + ".log"


def yaml_to_file(yaml_config, folder, basename):
    """
    The yaml_to_file function:
        This function writes the contents of a dictionary/yaml object to a file
        and makes sure this uses the same basename as the output from
        exomiser. The location and name of the yaml file is returned.
    """
    with open(folder + "/" + basename + ".yml", "w") as file:
        yaml.dump(yaml_config, file)
    return folder + "/" + basename + ".yml"


def singularity(docker, temp, jar, yaml, vcf, config):
    """
    The singularity function:
        This function creates the singularity and exomiser command that
        can run exomiser from the command line, this command is returned.
    """
    command = [
        "singularity",
        "exec",
        "--containall",
        "--bind",
        "/mnt,/home",
        "docker://" + docker,
        "java",
        "-Xms60g",
        "-Xmx80g",
        "-Djava.io.tmpdir=" + temp,
        "-jar",
        jar,
        "--analysis",
        yaml,
        "--assembly",
        "GRCh37",
        "--vcf",
        vcf,
        "--spring.config.location=" + config,
    ]
    command_line = (" ").join(command)
    return command_line


def generate_minimal_priority_range():
    """
    The generate_minimal_priority_range function:
        This function creates a range of floats that will be tested as
        minimal priority scores in the exomiser settings, the list is returned.
    """
    minimal_priority_score = []
    for i in numpy.arange(0.01, 1.0, 0.01):
        minimal_priority_score.append(float("%.2f" % i))
    minimal_priority_score[0] = 0.01
    minimal_priority_score.append(1.0)
    return minimal_priority_score


def run_exomiser(
    yaml, vcf, log, temp, config, docker, jar, basename, output_location
):
    """
    The run_exomiser function:
        This function calls a number of functions in order to start sbatch
        scripts on slurm that run exomiser for a range of minimal
        priority scores. These scores are also used to make the output from
        exomiser unique and identifiable.
    """
    score_range = generate_minimal_priority_range()
    exomiser_output_directories = []
    exomiser_log_files = []
    for mode in ["PASS_ONLY", "FULL"]:
        yaml["analysis"]["analysisMode"] = mode
        for score in score_range:
            yaml["analysis"]["steps"][3]["priorityScoreFilter"][
                "minPriorityScore"
            ] = score
            yaml["outputOptions"]["outputDirectory"] = (
                output_location
                + "/"
                + yaml["analysis"]["analysisMode"]
                + "/"
                + str(score)
            )
            if not os.path.exists(yaml["outputOptions"]["outputDirectory"]):
                os.makedirs(yaml["outputOptions"]["outputDirectory"])
            yaml_file = yaml_to_file(
                yaml, yaml["outputOptions"]["outputDirectory"], basename
            )
            command = singularity(docker, temp, jar, yaml_file, vcf, config)
            log_file = sbatch(command, basename, log, score, mode)
            exomiser_log_files.append(log_file)
            exomiser_output_directories.append(
                str(
                    yaml["outputOptions"]["outputDirectory"]
                    + "/"
                    + yaml["outputOptions"]["outputFileName"]
                )
            )
    return exomiser_output_directories, exomiser_log_files


def set_output_options(exomiser_options, vcf_file, output_name, hpo_terms):
    """
    The set_output_options function:
        This function creates a basename for the output files if no name is
        provided. Then the entries for the vcf sample, hpo ids
        and output filename are filled. The updated options are returned.
    """
    if output_name != "":
        basename = output_name
    elif output_name == "":
        current_time = datetime.datetime.now()
        basename = current_time.strftime("%Y-%m-%d_%H:%M:%S")
    exomiser_options["analysis"]["vcf"] = vcf_file
    exomiser_options["analysis"]["hpoIds"] = hpo_terms.split(",")
    exomiser_options["outputOptions"]["outputFileName"] = basename
    return exomiser_options, basename


def alter_vcf(vcf_file):
    """
    The alter_vcf function:
        This function updates the input sample vcf file with a new name and
        adds a class identifier to the INFO field, the class is either
        pathogenic or benign. Pathogenic for the clinvar variants and benign
        for the pgpuk variants.
    """
    updated_vcf = vcf_file[:-3] + "fixed.vcf"
    with open(vcf_file, "r") as file:
        with open(updated_vcf, "w") as vcf:
            for line in file:
                if line.startswith("#"):
                    vcf.write(line)
                else:
                    info = line.split("\t")
                    if info[7] == ".":
                        info[7] = "Class=Benign"
                    elif info[7] != ".":
                        info[7] = info[7] + ";Class=Pathogenic"
                    vcf.write("\t".join(info))
    return updated_vcf


def read_yaml(yaml_file):
    """
    The read_yaml function:
        This function reads in the yaml file provided by the user and converts
        it to a python object which is returned.
    """
    with open(yaml_file, "r") as file:
        exomiser_options = yaml.safe_load(file)
    return exomiser_options


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script tries to determine optimal thresholds for\
                   separating variants in either benign or pathogenic using\
                   exomiser."
    epilog = "This python script has three dependencies: numpy, pandas &\
              pyyaml."
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-y",
        "--yaml",
        action="store",
        dest="yaml_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the exomiser yaml options file.",
    )
    parser.add_argument(
        "-e",
        "--vcf",
        action="store",
        dest="vcf_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the sample vcf file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and folder name for the output of exomiser.",
    )
    parser.add_argument(
        "-n",
        "--name",
        action="store",
        dest="output_name",
        type=str,
        default=argparse.SUPPRESS,
        help="The base name to use for the output of exomiser, leave empty\
              for an automatic name to be generated.",
    )
    parser.add_argument(
        "-l",
        "--log",
        action="store",
        dest="log_file",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the folder for the log file.",
    )
    parser.add_argument(
        "-p",
        "--hpo",
        action="store",
        dest="hpo_terms",
        type=str,
        default=argparse.SUPPRESS,
        help="A list of hpo terms separated by comma's.",
    )
    parser.add_argument(
        "-t",
        "--temp",
        action="store",
        dest="temp_folder",
        type=str,
        default=argparse.SUPPRESS,
        help="A location and folder for java to store temporary files.",
    )
    parser.add_argument(
        "-c",
        "--config",
        action="store",
        dest="config_location",
        type=str,
        default=argparse.SUPPRESS,
        help="A location and file name for the exomiser config file.",
    )
    parser.add_argument(
        "-d",
        "--docker",
        action="store",
        dest="docker_container",
        type=str,
        default=argparse.SUPPRESS,
        help="The container to use for running exomiser with java.",
    )
    parser.add_argument(
        "-j",
        "--jar",
        action="store",
        dest="exomiser_jar",
        type=str,
        default=argparse.SUPPRESS,
        help="The location and name of the exomiser jar file.",
    )
    parser.add_argument(
        "-r",
        "--cores",
        action="store",
        dest="cores",
        type=int,
        default=1,
        help="The number of cpu cores to assign to multiprocessing.",
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
    exomiser_options = read_yaml(user_arguments.yaml_file)
    vcf_file_name = alter_vcf(user_arguments.vcf_file)
    updated_exomiser_options = set_output_options(
        exomiser_options,
        vcf_file_name,
        user_arguments.output_name,
        user_arguments.hpo_terms,
    )
    exomiser_output_directories = run_exomiser(
        updated_exomiser_options[0],
        vcf_file_name,
        user_arguments.log_file,
        user_arguments.temp_folder,
        user_arguments.config_location,
        user_arguments.docker_container,
        user_arguments.exomiser_jar,
        updated_exomiser_options[1],
        user_arguments.output_location,
    )
    startup_multiprocessing(
        exomiser_output_directories[0],
        user_arguments.output_location,
        exomiser_output_directories[1],
        user_arguments.cores,
    )


if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
