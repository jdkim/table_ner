# table_ner

This command
- reads a table in CSV, row by row,
- runs an NER process over each row (concatenation of all the column values), and
- appends to the row an additional column to contain the result of NER
As for the NER process, it calls an REST API, e.g., that of PubDictionaries (https://pubdictionaries.org).
It also assumes the API will return the result of NER in the format of PubAnnotation (http://www.pubannotation.org/docs/annotation-format/), and translates it into a list of comma-separated values. The result of annotation also specifies the source of the named entities, i.e., the column where the names entities have been recognized.

It is an output from the BioHackathon MENA 2023.

## Installation

    gem install table_ner

## Usage

```
table_ner.rb [options] < input_table.csv > output_table.csv
    -c, --configuration path_to_file specifies the path to the configuration file you want to read from.
    -a, --annotator URL              specifies the URL of the annotator to use.
    -s, --col_sep column_separator   specifies the column separator of the input CSV file. Note that for the output CSV file, always the TAB character will be used for the column separator.
    -d, --delimiter delimiter        specifies the delimiter of multiple values.
    -v, --verbose                    tells it to output verbosely (for a debugging purpose)
    -h, --help                       displays a help screen
```

## Configuration

The default configuation is as follows:
```
annotator_url: https://pubdictionaries.org/text_annotation.json?dictionary=EBI_biome_list&longest=true
col_sep: "\t"
delimiter: ", "
```
Please modify it to create your own configuration.