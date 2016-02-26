_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
merge\_datasets.pl

A program to merge two or more data files by appending columns.

## SYNOPSIS ##
merge\_datasets.pl `[`--options...`]` <file1> <file2> ...

```
  Options:
  --lookup
  --auto
  --manual
  --index <number,letter,range>
  --lookupname | --lun <text>
  --coordinate
  --out <filename> 
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--lookup


> Force the program to merge data by using lookup values in each file.  Enable this option if the data rows are not sorted identically. This will be done automatically if the number of data rows are not  equal between the files.

> 
--auto


> Execute in automatic mode, where all columns from the first data file  are retained, and only uniquely named or Score columns from subsequent  data files are merged. If lookup is enabled, then an appropriate  lookup column will be chosen.

> 
--manual


> Execute in full manual mode, where columns for lookup and merge are  chosen interactively from lists.

> 
--index <number,letter,range>


> For advanced users, provide the list of indices to merge from both  datasets. The format is the same as in the interactive mode. Column  indices from the first file are represented by numbers, the second  file by letters. Values are comma-delimited, and ranges may be  provided as "start-stop". To indicate indices from subsequent files,  provide separate --index options for each subsequent file. The default  is to run the program interactively.

> 
--lookupname <text>


--lun <text>


> Provide an alternate column name to identify the columns automatically  in the input files containing the lookup values when performing the  lookup. Each file should have the same lookup column name. Default  values include 'Name', 'ID', 'Transcript', or 'Gene'.

> 
--coordinate


> Force using genomic coordinates when performing a lookup. This effectively  merges the chromosome:start-stop coordinates into a single string for  lookup matching. The Coordinates column is temporary. This is automatically  enabled when working with BED or GFF files that may or may not have unique  names but will have unique coordinates. This may be disabled, for example  to force using a BED feature name as the lookup value, by specifying  --nocoordinate.

> 
--out <filename>


> Specify the output filename. By default it uses the first file name. Required in automatic mode.

> 
--gz


> Specify whether (or not) the output file should be compressed with gzip.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will merge two or more tab-delimited data files into one file.  Datasets or columns from each file are merged together into an output file.  Columns are appended to the end (after the rightmost column).

The columns may be specified using one of three methods. By default,  the program is run in an interactive mode allowing the columns to be  chosen from a presented list for each input file provided. Second, the  columns may be specified manually on the command line using one or  more --index options. Third, the program may be executed in full  automatic mode, where uniquely named datasets from subsequent files  are automatically appended to the first file. Score columns from  specific formatted files (BED, BedGraph, GFF) are also automatically  taken.

The program blindly assumes that rows (features) are equivalent and in the  same order for all of the datasets. However, if there are an  unequal number of data rows, or the user forces by using the --lookup option,  then dataset values are looked up first using specified lookup values before  merging (compare with Excel VLOOKUP function). In this case, the dataset  lookup indices from each file are identified automatically. Potential  lookup columns include 'Name', 'ID', 'Transcript', 'Gene', or any user  provided name (using the --lookupname option). Files with genomic coordinates,  including GFF and BED, may use a temporary coordinate string derived from the  features coordinates. If a lookup column can not be identified automatically,  then they are chosen interactively.

When a lookup is performed, the first index in the order determines which  file is dominant, meaning that all rows from that file are included, and only  the rows that match by the lookup value are included from the second file. Null  values are recorded when no match is found in the second file.

After merging in interactive mode only, an opportunity for interactively  renaming the dataset names is presented.

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
