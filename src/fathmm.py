#!/usr/bin/env python -u

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
import re
import math
import argparse
import ConfigParser
import sqlite3

def map_position(domain, substitution):
    if int(substitution[1:-1]) < int(domain['seq_begin']) or \
       int(substitution[1:-1]) > int(domain['seq_end']):
           return None
    x = int(domain['seq_begin']) - 1 
    y = int(domain['hmm_begin']) - 1 
    for residue in list(domain['align']):
        if residue.isupper() or residue.islower():
            x += 1
        if residue.isupper() or residue == "-":
            y += 1
        if x == int(substitution[1:-1]):
            if residue.isupper():
                return str(y)
            return None
    return None

def fetch_phenotype_prediction(Facade, Phenotype):
    Phenotypes = ""
    if not Arg.phenotypes:
        return Phenotypes
    for x in sorted(Facade, key=lambda x:x['information'], reverse=True):
        if x['accession']:
            dbCursor.execute("SELECT * FROM PHENOTYPES WHERE accession=? AND type=? AND origin=1 ORDER BY score", (x['accession'], Phenotype))
            Phenotypes = "|".join([ x['description'] for x in dbCursor.fetchall() ])
            if Phenotypes:
                break
    return Phenotypes

def Process(Protein, Substitution, Weights=None, Cutoff=None, Phenotype=None):
    Processed = {
                 'Prediction' : "",
                 'Score':       "",       
                 'Phenotype':   "",
                 'HMM':         "",
                 'Description': "",
                 'Position':    "",
                 'W':           "",
                 'M':           "",
                 'D':           "",
                 'O':           "",
                 'Warning':     "",
                }
    dbCursor.execute("SELECT a.* FROM SEQUENCE a, PROTEIN b WHERE a.id=b.id AND b.name=?", (Protein,))
    Sequence = dbCursor.fetchone()
    if not Sequence:
        Processed['Warning'] = "No Sequence Record Found"
        return Processed
    Warning     = None
    if not Warning and not re.compile("^[ARNDCEQGHILKMFPSTWYV]\d+[ARNDCEQGHILKMFPSTWYV]$", re.IGNORECASE).match(Substitution):
        Warning = "Invalid Substitution Format"
    if not Warning and int(Substitution[1:-1]) > len(Sequence['sequence']):
        Warning = "Invalid Substitution Position"
    if not Warning and not Substitution[0] == Sequence['sequence'][int(Substitution[1:-1]) - 1]:
        Warning = "Inconsistent Wild-Type Residue (Expected '" + Sequence['sequence'][int(Substitution[1:-1]) - 1] + "')"
    if not Warning and Substitution[0] == Substitution[-1]:
        Warning = "Synonymous Mutation"
    if Warning:
        Processed['Warning'] = Warning
        return Processed
    dbCursor.execute("SELECT * FROM DOMAINS WHERE id=? AND ? BETWEEN seq_begin AND seq_end ORDER BY score", (str(Sequence['id']), Substitution[1:-1]))
    Domain = dbCursor.fetchall()
    Facade = []
    for x in Domain:
        residue = map_position(x, Substitution)
        if residue:
            dbCursor.execute("SELECT a.*, b.* FROM PROBABILITIES a, LIBRARY b WHERE a.id=b.id AND a.id=? AND a.position=?", (str(x['hmm']), residue))
            Prob = dbCursor.fetchone()
            if Prob:
                Facade.append(Prob)
    if Phenotype:
        Processed['Phenotype'] = fetch_phenotype_prediction(Facade, Phenotype)
    if not Weights or Weights == "UNWEIGHTED":
        dbCursor.execute("SELECT a.*, b.*  FROM PROBABILITIES a, LIBRARY b WHERE a.id=b.id AND a.id=? AND a.position=?", (str(Sequence['id']), Substitution[1:-1]))
        Prob = dbCursor.fetchone()
        if Prob:
            Facade.append(Prob)
        for x in sorted(Facade, key=lambda x:x['information'], reverse=True):
            try:
                Processed['HMM']         = x['id']
                Processed['Description'] = x['description']
                Processed['Position']    = x['position']
                Processed['W']           = x[Substitution[0]]
                Processed['M']           = x[Substitution[-1]]
                Processed['D']           = ""
                Processed['O']           = ""
                Processed['Score']       = "%.2f" % math.log((Processed['M'] / (1.0 - Processed['M'])) / (Processed['W'] / (1.0 - Processed['W'])), 2)
                Processed['Prediction']  = ""                
                if Cutoff:
                    if float(Processed['Score']) <= Cutoff: Processed['Prediction'] = "DAMAGING"
                    if float(Processed['Score']) >  Cutoff: Processed['Prediction'] = "TOLERATED"
                return Processed
            except Exception as e:
                pass
    else:
        for x in sorted(Facade, key=lambda x:x['information'], reverse=True):
            try:
                dbCursor.execute("SELECT * FROM WEIGHTS WHERE id=? AND type=?", (x['id'], Weights))
                w = dbCursor.fetchone()
                if w:
                    Processed['HMM']         = x['id']
                    Processed['Description'] = x['description']
                    Processed['Position']    = x['position']
                    Processed['W']           = x[Substitution[0]]
                    Processed['M']           = x[Substitution[-1]]
                    Processed['D']           = w['disease'] + 1.0
                    Processed['O']           = w['other'] + 1.0
                    Processed['Score']       = "%.2f" % math.log(((1.0 - Processed['W']) * Processed['O']) / ((1.0 - Processed['M']) * Processed['D']), 2)
                    Processed['Prediction']  = ""                
                    if Cutoff:
                        if Weights == "INHERITED":
                            if float(Processed['Score']) <= Cutoff: Processed['Prediction'] = "DAMAGING"
                            if float(Processed['Score']) >  Cutoff: Processed['Prediction'] = "TOLERATED"
                        if Weights == "CANCER":
                            if float(Processed['Score']) <= Cutoff: Processed['Prediction'] = "CANCER"
                            if float(Processed['Score']) >  Cutoff: Processed['Prediction'] = "PASSENGER/OTHER"
                    return Processed
            except Exception as e:
                pass
        dbCursor.execute("SELECT a.*, b.*  FROM PROBABILITIES a, LIBRARY b WHERE a.id=b.id AND a.id=? AND a.position=?", (str(Sequence['id']), Substitution[1:-1]))
        Facade = dbCursor.fetchone()
        if Facade:
            try:
                dbCursor.execute("SELECT * FROM WEIGHTS WHERE id=? AND type=?", (Facade['id'], Weights))
                w = dbCursor.fetchone()
                if w:
                    Processed['HMM']         = Facade['id']
                    Processed['Description'] = Facade['description']
                    Processed['Position']    = Facade['position']
                    Processed['W']           = Facade[Substitution[0]]
                    Processed['M']           = Facade[Substitution[-1]]
                    Processed['D']           = w['disease'] + 1.0
                    Processed['O']           = w['other'] + 1.0
                    Processed['Score']       = "%.2f" % math.log(((1.0 - Processed['W']) * Processed['O']) / ((1.0 - Processed['M']) * Processed['D']), 2)
                    Processed['Prediction']  = ""                
                    if Cutoff:
                        if Weights == "INHERITED":
                            if float(Processed['Score']) <= Cutoff: Processed['Prediction'] = "DAMAGING"
                            if float(Processed['Score']) >  Cutoff: Processed['Prediction'] = "TOLERATED"
                        if Weights == "CANCER":
                            if float(Processed['Score']) <= Cutoff: Processed['Prediction'] = "CANCER"
                            if float(Processed['Score']) >  Cutoff: Processed['Prediction'] = "PASSENGER/OTHER"
                    return Processed
            except Exception as e:
                raise        
    return None

if __name__ == '__main__':
    Config   = ConfigParser.ConfigParser()
    Config.read("./config.ini")

    conn = sqlite3.connect(str(Config.get("DATABASE", "DB")))
    dbCursor = conn.cursor()

    parser = argparse.ArgumentParser(
                                     description = 'Functional Analysis through Hidden Markov Models',
                                     add_help    = False
                                    )
    parser.add_argument(
                        "-h",
                        "--help",
                        action = "help",
                        help   = argparse.SUPPRESS
                       )
    
    group = \
        parser.add_argument_group("Required")
    group.add_argument(
                       'fi',
                       metavar = '<F1>', 
                       type    = argparse.FileType("r"),
                       help    = 'a file containing the mutation data to process'
                      )
    group.add_argument(
                       'fo',
                       metavar = '<F2>',
                       type    = argparse.FileType("w"),
                       help    = 'where predictions/phenotype-associations will be written'
                      )
    
    group = \
        parser.add_argument_group("Options")
    group.add_argument(
                       '-w',
                       dest    = 'weights',
                       metavar = "<S>",
                       default = "INHERITED",
                       help    = "use pathogenicity weights <S> when returning predictions"
                      )
    group.add_argument(
                       '-t',
                       dest    = 'threshold',
                       metavar = "<N>",
                       default = None,
                       type    = float,
                       help    = "use prediction threshold <N> when returning predictions"
                      )
    group.add_argument(
                       '-p',
                       dest    = 'phenotypes',
                       metavar = "<S>",
                       default = "",
                       help    = "use phenotype ontology <S> when returning domain-phenotype associations"
                      ); Arg = parser.parse_args()
    if Arg.weights:
        dbCursor.execute("SELECT DISTINCT type FROM WEIGHTS")
        if not Arg.weights.upper() in [ x[0] for x in dbCursor.fetchall() ] + [ "UNWEIGHTED" ]: 
            parser.error("argument -w: invalid option: '{0}'".format(Arg.weights))
        if Arg.threshold == None:
            if Arg.weights.upper() == "UNWEIGHTED": Arg.threshold = -3.00
            if Arg.weights.upper() == "INHERITED":  Arg.threshold = -1.50
            if Arg.weights.upper() == "CANCER":     Arg.threshold = -0.75
        if Arg.phenotypes:
            dbCursor.execute("SELECT DISTINCT type FROM PHENOTYPES")
            if not Arg.phenotypes.upper() in [ x[0] for x in dbCursor.fetchall() ]:
                parser.error("argument -p: invalid option: '{0}'".format(Arg.phenotypes))
    Arg.fo.write("\t".join([ "#", 
                             "dbSNP ID",
                             "Protein ID",
                             "Substitution",
                             "Prediction",
                             "Score",
                             "Domain-Phenotype Association",
                             "Warning",
                             "HMM ID",
                             "HMM Description",
                             "HMM Pos.",
                             "HMM Prob. W.",
                             "HMM Prob. M.",
                             "HMM Weights D.",
                             "HMM Weights O."
                             ]) + "\n")
    idx = 1
    for record in Arg.fi:
        record = record.strip()
        if record and not record.startswith("#"):
            try:
                if re.compile("^rs\d+$", re.IGNORECASE).match(record):
                    dbCursor.execute("SELECT DISTINCT * FROM VARIANTS WHERE id=?", (record,))
                    dbRecords = dbCursor.fetchall()
                    if not dbRecords:
                        Arg.fo.write(
                            "\t".join([ str(idx),
                                       record,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "No dbSNP Mapping(s)",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        ""
                                        ]) + "\n"
                                    ); idx += 1; continue
                    for x in dbRecords:
                        dbSNP        = x['id']
                        Protein      = x['protein']
                        Substitution = x['substitution']
                        Prediction = Process(Protein, Substitution, Weights=Arg.weights.upper(), Cutoff=Arg.threshold, Phenotype=Arg.phenotypes.upper())
                        if not Prediction:
                            Arg.fo.write(
                                "\t".join([ str(idx),
                                           dbSNP,
                                           Protein,
                                           Substitution,
                                           "",
                                           "",
                                           "",
                                           "No Prediction Available",
                                           "",
                                           "",
                                           "",
                                           "",
                                           "",
                                           "",
                                           ""
                                           ]) + "\n"
                                        ); idx += 1; continue
                        Arg.fo.write(
                            "\t".join([ str(idx),
                                        dbSNP,
                                        Protein,
                                        Substitution,
                                        str(Prediction['Prediction']),
                                        str(Prediction['Score']),
                                        str(Prediction['Phenotype']),
                                        str(Prediction['Warning']),
                                        str(Prediction['HMM']),
                                        str(Prediction['Description']),
                                        str(Prediction['Position']),
                                        str(Prediction['W']),
                                        str(Prediction['M']),
                                        str(Prediction['D']),
                                        str(Prediction['O']) 
                                        ]) + "\n"
                                    ); idx += 1; continue
                else:
                    dbSNP         = ""
                    Protein       = record.upper().split()[0]
                    for Substitution in [ x.strip() for x in record.upper().split()[1].split(",") ]:
                        Prediction = Process(Protein, Substitution, Weights=Arg.weights.upper(), Cutoff=Arg.threshold, Phenotype=Arg.phenotypes.upper())
                        if not Prediction:
                            Arg.fo.write(
                                "\t".join([ str(idx),
                                            dbSNP,
                                            Protein,
                                            Substitution,
                                            "",
                                            "",
                                            "",
                                            "No Prediction Available",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            ""
                                            ]) + "\n"
                            ); idx += 1; continue
                        Arg.fo.write(
                            "\t".join([ str(idx),
                                        dbSNP,
                                        Protein,
                                        Substitution,
                                        str(Prediction['Prediction']),
                                        str(Prediction['Score']),
                                        str(Prediction['Phenotype']),
                                        str(Prediction['Warning']),
                                        str(Prediction['HMM']),
                                        str(Prediction['Description']),
                                        str(Prediction['Position']),
                                        str(Prediction['W']),
                                        str(Prediction['M']),
                                        str(Prediction['D']),
                                        str(Prediction['O']) 
                                        ]) + "\n"
                                    ); idx += 1; continue
            except Exception as e:
                Arg.fo.write(
                    "\t".join([ str(idx),
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    "An Error Occured While Processing The Record: " + record,
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    ""
                                    ]) + "\n"
                                ); idx += 1
    conn.close()
