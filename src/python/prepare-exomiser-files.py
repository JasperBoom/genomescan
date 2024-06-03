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
import numpy
import os
import subprocess
import sys
import yaml


class Variants:
    """
    The Variants class:
        This class reads in the input vcf file as defined by the user and
        updates each variant line in the file by adding a class identifier to
        the info field. The updated lines are written to a new file.
    """

    def __init__(self, vcf_file):
        """
        The initializer function:
            This function creates an instance attribute:
                vcf_file = a string of the full path to the vcf file that is
                           processed by exomiser.
        """
        self.vcf_file = vcf_file

    @property
    def vcf_file(self):
        """
        The vcf_file property function:
            This function converts vcf_file to a property which reads in the
            original file, adds a class field and writes the altered lines to
            a new file. The new file is returned.
        """
        return self._vcf_file

    @vcf_file.setter
    def vcf_file(self, value):
        """
        The vcf_file setter function:
            This function updates the input sample vcf file with a new name and
            adds a class identifier to the INFO field, the class is either
            pathogenic or benign. Pathogenic for the clinvar variants and
            benign for the pgpuk variants.
        """
        self._vcf_file = value[:-3] + "fixed.vcf"
        with open(value, "r") as file:
            with open(self._vcf_file, "w") as vcf:
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


class Settings:
    """
    The Settings class:
        This class reads in the exomiser yaml options file and converts it to
        a python dictionary. The standard output options, and some analysis
        related options are updated in the dictionary. This dictionary is
        returned.
    """

    def __init__(self, yaml_file, vcf_file, hpo_term_ids, exomiser_output_name):
        """
        The initializer function:
            This function creates a number of instance attributes:
                yaml_file: a string of the full path to a yaml file with
                           exomiser options.
                vcf_file: a string of the full path to the vcf file that is
                          processed by exomiser.
                hpo_term_ids: a list of hpo terms to include in the exomiser
                              options.
                exomiser_output_name: the basename to use for the exomiser
                                      result files.
        """
        self.yaml_file = yaml_file
        self.vcf_file = vcf_file
        self.hpo_term_ids = hpo_term_ids
        self.exomiser_output_name = exomiser_output_name

    @property
    def yaml_file(self):
        """
        The yaml_file property function:
            This function converts yaml_file to a property which results in a
            python object that is returned.
        """
        return self._yaml_file

    @yaml_file.setter
    def yaml_file(self, value):
        """
        The yaml_file setter function:
            This function reads in the yaml file provided by the user and
            converts it to a python object.
        """
        with open(value, "r") as file:
            self._yaml_file = yaml.safe_load(file)

    def fill_output_options(self):
        """
        The fill_output_options function:
            This function creates a basename for the output files if no name is
            provided. Then the entries for the vcf sample, hpo ids and output
            filename are filled. The updated options are returned.
        """
        if self.exomiser_output_name != None:
            pass
        elif self.exomiser_output_name == None:
            self.exomiser_output_name = datetime.datetime.now().strftime(
                "%Y-%m-%d_%H:%M:%S"
            )
        self.yaml_file["analysis"]["vcf"] = self.vcf_file
        self.yaml_file["analysis"]["hpoIds"] = self.hpo_term_ids.split(",")
        self.yaml_file["outputOptions"][
            "outputFileName"
        ] = self.exomiser_output_name
        return self.yaml_file


class Exomiser:
    """
    The Exomiser class:
        This class is responsible for running exomiser on a range of minimal
        priority scores. This is done by updating the yaml options file and
        submitting singularity based exomiser jobs to a slurm system. Exomiser
        is run in both FULL and PASS_ONLY mode for the same minimal priority
        score in order to determine the pathogenic and benign variants.

        This function creates a number of class attributes:
            minimal_priority_score: a list of floats to use as minimal priority
                                    score in exomiser.
            exomiser_result_files: a list of folder paths for each
                                         minimal priority score for both the
                                         full and pass only modes, including
                                         the file names.
            exomiser_log_files: a list of full file paths to the log files for
                                each minimal priority score in each exomiser
                                mode.
            yaml_file: a string with the full path to the yaml options file,
                       this changes with each new minimal priority score.
            exomiser_command: a string with both singularity and exomiser
                              arguments to execute on the computer cluster.
            log_file_exomiser_slurm: a string with the full path to the file
                                     used by slurm to write logs to.
    """

    minimal_priority_score = []
    exomiser_result_files = []
    exomiser_log_files = []
    yaml_file = ""
    exomiser_command = ""
    log_file_exomiser_slurm = ""

    def __init__(
        self,
        yaml_dictionary,
        exomiser_output_path,
        exomiser_output_name,
        docker_container,
        temp_folder,
        exomiser_jar,
        vcf_file,
        config_file,
        log_folder,
    ):
        """
        The initializer function:
            This function creates a number of instance attributes:
                yaml_dictionary: dictionary version of the exomiser yaml
                                 options file.
                exomiser_output_path: a string with the full path to the output
                                      folder for the exomiser results.
                exomiser_output_name: a string with the basename to use for all
                                      files produced by and for exomiser.
                docker_container: the name for the docker container to use as
                                  a base for running exomiser.
                temp_folder: a string with the full path to the folder to use
                             for temporary files.
                exomiser_jar: a string with the full path to the jar file from
                              exomiser.
                vcf_file: a string with the full path to the vcf file to use as
                          input to exomiser.
                config_file: a string with the full path to the exomiser config
                             file.
                log_folder: a string with the full path to the folder to use as
                            storage for the log files.
        """
        self.yaml_dictionary = yaml_dictionary
        self.exomiser_output_path = exomiser_output_path
        self.exomiser_output_name = exomiser_output_name
        self.docker_container = docker_container
        self.temp_folder = temp_folder
        self.exomiser_jar = exomiser_jar
        self.vcf_file = vcf_file
        self.config_file = config_file
        self.log_folder = log_folder

    def minimal_priority_range(self):
        """
        The minimal_priority_range function:
            This function creates a range of floats that will be tested as
            minimal priority scores in the exomiser settings.
        """
        for i in numpy.arange(0.01, 1.0, 0.01):
            self.minimal_priority_score.append(float("%.2f" % i))
        self.minimal_priority_score[0] = 0.01
        self.minimal_priority_score.append(1.0)

    def yaml_to_file(self):
        """
        The yaml_to_file function:
            This function writes the contents of a dictionary/yaml object to a
            file and makes sure this uses the same basename as the output from
            exomiser.
        """
        self.yaml_file = (
            self.yaml_dictionary["outputOptions"]["outputDirectory"]
            + "/"
            + self.exomiser_output_name
            + ".yml"
        )
        with open(self.yaml_file, "w") as file:
            yaml.dump(self.yaml_dictionary, file)

    def singularity(self):
        """
        The singularity function:
            This function creates the singularity and exomiser command that
            can run exomiser from the command line.
        """
        command = [
            "singularity",
            "exec",
            "--containall",
            "--bind",
            "/mnt,/home",
            "docker://" + self.docker_container,
            "java",
            "-Xms60g",
            "-Xmx80g",
            "-Djava.io.tmpdir=" + self.temp_folder,
            "-jar",
            self.exomiser_jar,
            "--analysis",
            self.yaml_file,
            "--assembly",
            "GRCh37",
            "--vcf",
            self.vcf_file,
            "--spring.config.location=" + self.config_file,
        ]
        self.exomiser_command = (" ").join(command)

    def sbatch(self, score, mode):
        """
        The sbatch function:
            This function creates and executes a sbatch command on a slurm
            system. All requirements are filled, like a job name, log/error
            locations and resource requirements. The wrap argument is used to
            execute a cli tool, for which slurm will automatically create a
            simple bash script.
        """
        slurm_name = "exomiser_" + self.exomiser_output_name + "_" + str(score)
        log_directory = self.log_folder + "/" + mode
        self.log_file_exomiser_slurm = log_directory + "/" + slurm_name + ".log"
        if not os.path.exists(log_directory):
            os.makedirs(log_directory)
        process = subprocess.Popen(
            [
                "sbatch",
                "--job-name=" + slurm_name,
                "--error=" + log_directory + "/" + slurm_name + ".error",
                "--output=" + self.log_file_exomiser_slurm,
                "--cpus-per-task=3",
                "--mem=80G",
                "--export=ALL",
                "--partition=all",
                "--wrap=" + self.exomiser_command,
            ]
        )
        output, errors = process.communicate()
        if not os.path.exists(self.log_file_exomiser_slurm):
            with open(self.log_file_exomiser_slurm, "w"):
                pass

    def run_exomiser(self):
        """
        The run_exomiser function:
            This function calls a number of functions in order to start sbatch
            scripts on slurm that run exomiser for a range of minimal priority
            scores. These scores are also used to make the output from
            exomiser unique and identifiable. Exomiser is run either in FULL
            or PASS ONLY mode.
        """
        self.minimal_priority_range()
        for mode in ["PASS_ONLY", "FULL"]:
            self.yaml_dictionary["analysis"]["analysisMode"] = mode
            for score in self.minimal_priority_score:
                self.yaml_dictionary["analysis"]["steps"][3][
                    "priorityScoreFilter"
                ]["minPriorityScore"] = score
                self.yaml_dictionary["outputOptions"]["outputDirectory"] = (
                    self.exomiser_output_path
                    + "/"
                    + self.yaml_dictionary["analysis"]["analysisMode"]
                    + "/"
                    + str(score)
                )
                if not os.path.exists(
                    self.yaml_dictionary["outputOptions"]["outputDirectory"]
                ):
                    os.makedirs(
                        self.yaml_dictionary["outputOptions"]["outputDirectory"]
                    )
                self.yaml_to_file()
                self.singularity()
                self.sbatch(score, mode)
                self.exomiser_log_files.append(self.log_file_exomiser_slurm)
                self.exomiser_result_files.append(
                    str(
                        self.yaml_dictionary["outputOptions"]["outputDirectory"]
                        + "/"
                        + self.yaml_dictionary["outputOptions"][
                            "outputFileName"
                        ]
                    )
                )


def parse_argvs():
    """
    The parse_argvs function:
        This function handles all positional arguments that the script accepts,
        including version and help pages.
    """
    description = "This script executes exomiser on a trainingset. It changes\
                   the minimal priority score for each run and organises the\
                   output in a folder structure."
    epilog = "This python script has two dependencies: numpy & pyyaml"
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
        help="the location and name of the exomiser yaml options file",
    )
    parser.add_argument(
        "-e",
        "--vcf",
        action="store",
        dest="vcf_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the location and name of the sample vcf file",
    )
    parser.add_argument(
        "-o",
        "--output",
        action="store",
        dest="output_location",
        type=str,
        default="/home",
        help="the location and folder name for the output of exomiser",
    )
    parser.add_argument(
        "-n",
        "--name",
        action="store",
        dest="output_name",
        type=str,
        default=None,
        help="the base name to use for the output of exomiser, leave empty\
              for an automatic name to be generated",
    )
    parser.add_argument(
        "-l",
        "--log",
        action="store",
        dest="log_file",
        type=str,
        default=argparse.SUPPRESS,
        help="the location and name of the folder for the log file",
    )
    parser.add_argument(
        "-p",
        "--hpo",
        action="store",
        dest="hpo_terms",
        type=str,
        default="HP:0002858",
        help="a list of hpo terms separated by comma's",
    )
    parser.add_argument(
        "-t",
        "--temp",
        action="store",
        dest="temp_folder",
        type=str,
        default="/tmp",
        help="a location and folder for java to store temporary files",
    )
    parser.add_argument(
        "-c",
        "--config",
        action="store",
        dest="config_location",
        type=str,
        default="./application.properties",
        help="a location and file name for the exomiser config file",
    )
    parser.add_argument(
        "-d",
        "--docker",
        action="store",
        dest="docker_container",
        type=str,
        default="amazoncorretto:21.0.2-alpine3.19",
        help="the container to use for running exomiser with java",
    )
    parser.add_argument(
        "-j",
        "--jar",
        action="store",
        dest="exomiser_jar",
        type=str,
        default="./exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar",
        help="the location and name of the exomiser jar file",
    )
    parser.add_argument(
        "-u",
        "--update",
        action="store_true",
        dest="update_vcf",
        help="instead of running exomiser, just update the input vcf with\
              correct class information.",
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
    vcf = Variants(user_arguments.vcf_file)
    if user_arguments.update_vcf:
        sys.exit(0)
    else:
        yaml = Settings(
            user_arguments.yaml_file,
            vcf.vcf_file,
            user_arguments.hpo_terms,
            user_arguments.output_name,
        )
        exomiser = Exomiser(
            yaml.fill_output_options(),
            user_arguments.output_location,
            yaml.exomiser_output_name,
            user_arguments.docker_container,
            user_arguments.temp_folder,
            user_arguments.exomiser_jar,
            vcf.vcf_file,
           user_arguments.config_location,
            user_arguments.log_file,
        )
        exomiser.run_exomiser()

if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
