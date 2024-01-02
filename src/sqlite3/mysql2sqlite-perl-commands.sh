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

#SBATCH --job-name="mysql2sqlite-perl-commands"
#SBATCH --mem=30G
#SBATCH --cpus-per-task=10
#SBATCH --export=ALL
#SBATCH --output="/mnt/titan/users/j.boom/logs/R-%x-%j.log"
#SBATCH --error="/mnt/titan/users/j.boom/errors/R-%x-%j.error"
#SBATCH --time=200:15:0
#SBATCH --partition=all

main() {
    # The main function:
    #     This functions runs a number of bash and perl commands in order to
    #     prepare a mysql database dump for conversion to sqlite.
    cat $1 |
    grep -v 'LOCK' |
    grep -v ' KEY ' |
    grep -v ' UNIQUE KEY ' |
    grep -v ' PRIMARY KEY ' |
    perl -pe 's/ ENGINE[ ]*=[ ]*[A-Za-z_][A-Za-z_0-9]*(.*DEFAULT)?/ /gi' |
    perl -pe 's/ CHARSET[ ]*=[ ]*[A-Za-z_][A-Za-z_0-9]*/ /gi' |
    perl -pe 's/ [ ]*AUTO_INCREMENT=[0-9]* / /gi' |
    perl -pe 's/ unsigned / /g' |
    perl -pe 's/ auto_increment/ primary key autoincrement/gi' |
    perl -pe 's/ smallint[(][0-9]*[)] / integer /gi' |
    perl -pe 's/ tinyint[(][0-9]*[)] / integer /gi' |
    perl -pe 's/ int[(][0-9]*[)] / integer /gi' |
    perl -pe 's/ character set [^ ]* / /gi' |
    perl -pe 's/ enum[(][^)]*[)] / varchar(255) /gi' |
    perl -pe 's/ on update [^,]*//gi' |
    perl -e 'local $/;$_=<>;s/,\n\)/\n\)/gs;print "begin;\n";print;print "commit;\n"' |
    perl -pe '
    if (/^(INSERT.+?)\(/) {
       $a=$1;
       s/\\'\''/'\'\''/g;
       s/\\n/\n/g;
       s/\),\(/\);\n$a\(/g;
    }
    '
}

# The getopts function.
# https://kodekloud.com/blog/bash-getopts/
OPT_STRING="vh"
while getopts ${OPT_STRING} option;
do
    case ${option} in
        v)
            echo ""
            echo "run-mysql2sqlite-perl-commands.sh [1.0]"
            echo ""

            exit
            ;;
        h)
            echo ""
            echo "Usage: run-mysql2sqlite-perl-commands.sh [-v] [-h]"
            echo ""
            echo "Optional arguments:"
            echo " -v          Show the software's version number and exit."
            echo " -h          Show this help page and exit."
            echo ""
            echo "This script runs some bash and perl commands to prepare a"
            echo "mysql database dump file for conversion to sqlite."
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
# A kludge for converting the MYSQL dump provided
# by http://www.baseball-databank.org/ into a SQLITE3 compatible dump.
#
# EXAMPLE USAGE: ./mysql2sqlite.sh BDB-sql-2008-03-28.sql | sqlite3 baseball.db