    def create_tsv(self):
        """
        The create_tsv function:
            This function creates an empty dataframe with columns corresponding
            to the different info fields that exomiser adds to the vcf file.
            Then a vcf file is processed so that the known class and the
            exomiser infoare extracted and written to the empty dataframe. If
            the vcf only contains variants that passed all filters, we consider
            them pathogenic. If the vcf contains all variants, a check is
            performed against the pass only vcf, which are pathogenic, the
            other variants are considered benign. This dataframe is returned.

            This function fills an empty dataframe with columns corresponding
            to the different exomiser annotations added to the vcf info field.
            Then a vcf file is processed to fill the dataframe with the
            class information and exomiser annotation. If the vcf contains only
            variants that passed the filters, they are considered pathogenic.
            If all variants are in the vcf, a check is performed against the
            list of pathogenic variants, matches are again classified
            pathogenic, the others are benign.
        """
        self.dataframes = {
            mode: pandas.DataFrame(columns=self.column_names)
            for mode in ["PASS_ONLY", "FULL"]
        }
        for vcf in self.vcf_collection:
            mode = vcf.split("/")[-3]
            with gzip.open(vcf, "r") as file:
                for line in file:
                    correct_format_line = str(line, "latin-1")
                    if correct_format_line.startswith("#"):
                        continue
                    info = correct_format_line.split("\t")[7].split(";")
                    known_class = next(
                        (
                            item.strip("Class=")
                            for item in info
                            if item.startswith("Class=")
                        ),
                        "",
                    )
                    exomiser_info = next(
                        (
                            item.strip("Exomiser=")
                            .split(",")[0]
                            .strip("{}")
                            .split("|")
                            for item in info
                            if item.startswith("Exomiser=")
                        ),
                        [""] * 18,
                    )
                    exomiser_info.extend([""] * (18 - len(exomiser_info)))
                    info_dictionary = dict(
                        zip(self.column_names, exomiser_info)
                    )
                    info_dictionary["KNOWN_CLASS"] = known_class
                    if mode == "PASS_ONLY":
                        info_dictionary["PREDICTED_CLASS"] = "Pathogenic"
                    elif mode == "FULL":
                        check_class = any(
                            self.dataframes["PASS_ONLY"]["ID"].isin(
                                [info_dictionary["ID"]]
                            )
                        )
                        info_dictionary["PREDICTED_CLASS"] = (
                            "Pathogenic" if check_class else "Benign"
                        )
                    self.dataframes[mode] = pandas.concat(
                        [
                            self.dataframes[mode],
                            pandas.DataFrame([info_dictionary]),
                        ]
                    )
        self.write_tsv()