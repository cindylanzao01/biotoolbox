_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
pull\_features.pl

A script to pull out a specific list of data rows from a data file.

## SYNOPSIS ##
pull\_features.pl --data <filename> --list <filename> --out <filename>

```
  Options:
  --data <filename>
  --list <filename>
  --out <filename>
  --dindex <integer>
  --lindex <integer>
  --order [list | data]
  --sum
  --starti <integer>
  --stopi <integer>
  --log
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--data


> Specify a tab-delimited text file as the data source file. One of  the columns in the input file should contain the identifiers to be  used in the lookup. The file may be gzipped.

> 
--list


> Specify the name of a text file containing the list of feature  names or identifiers to pull. The file may be a single column or  tab-delimited multi-column file with column headers. A .kgg file  from a Cluster k-means analysis may be used.

> 
--out


> Specify the output file name.

> 
--dindex <integer>


--lindex <integer>


> Specify the index numbers of the columns in the data and list  files, respectively, containing the identifiers to match features.  If not specified, then the program will attempt to identify   appropriate matching columns with the same header name. If none  are specified, the user must select interactively from a list of  available column names.

> 
--order `[`list | data`]`


> Optionally specify the order of features in the output file. Two  options are available. Specify 'list' to match the order of features  in the list file. Or specify 'data' to match the order of features  in the data file. The default is list.

> 
--sum


> Indicate that the pulled data should be averaged across all  features at each position, suitable for graphing. A separate text  file with '`_`summed' appended to the filename will be written.

> 
--starti <integer>


> When re-summarizing the pulled data, indicate the start column  index that begins the range of datasets to summarize. Defaults  to the leftmost column without a standard feature description name.

> 
--stopi <integer>


> When re-summarizing the pulled data, indicate the stop column index the ends the range of datasets to summarize. Defaults to the last or rightmost column.

> 
--log


> The data is in log2 space. Only necessary when re-summarizing the pulled data.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
Given a list of requested unique feature identifiers, this program will  pull out those features (rows) from a datafile and write a new file. This  program compares in function to a popular spreadsheet VLOOKUP command.  The list is provided as a separate text file, either as a single column  file or a multi-column tab-delimited from which one column is selected.  All rows from the source data file that match an identifier in the list  will be written to the new file. The order of the features in the output  file may match either the list file or the data file.

The program will also accept a Cluster gene file (with .kgg extension)  as a list file. In this case, all of the genes for each cluster are  written into separate files, with the output file name appended with the  cluster number.

The program will optionally regenerate a summed data file, in which values  in the specified data columns are averaged and written out as rows in a  separate data file. Compare this function to the summary option in the  biotoolbox scripts [get\_relative\_data.pl](Pod_get_relative_data_pl.md) or [average\_gene.pl](Pod_average_gene_pl.md).

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Howard Hughes Medical Institute
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
