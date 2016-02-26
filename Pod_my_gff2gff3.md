_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
my\_gff2gff3.pl

A script to convert my data GFF v.2 files to GFF3

## SYNOPSIS ##
my\_gff2gff3.pl `[`--options ...`]` <file1.gff> <file2.gff> ...

```
  --type <text>
  --source <text>
  --mt <text>
  --help
```
```
```
## OPTIONS ##
The command line flags and descriptions:

--type <text>


> Provide a text string to bue used in the method/class/type column. Since we are generating a v.3 GFF file, the type  value should map to a valid Sequence Ontology Term. Common  data terms include 'microarray\_oligo', 'tag', or 'STS'. See http://www.sequenceontology.org for more information.  Default is to use the original.

> 
--source <text>


> Optionally provide a new text string to replace the 'source'  field. Default is to use the original.

> 
--mt <text>


> I used to rename the mitochrondrial chromosome in cerevisiae to  'chr17' to help facilitate analysis. This was not very  professional. A new name may be provided for renaming all 'chr17'  features (back) to the new (original) name.

> 
--help


> Display the POD documentation

> 
## DESCRIPTION ##
This program will convert a simple data version 2 GFF formatted file into a GFF3  file. Typical GFF data files that I had generated are in GFF v.2 format.  Additionally, I used the 'type' or 'method' column (the third column) as  a means of identifying and grouping values into a single data set. These  were further often identified by the source tag of 'data'. Finally, the  group field (ninth column) was simply in the format 'Experiment $type'.

With bioperl, GBrowse, and other programs moving towards format v.3  (GFF3), these practices are no longer acceptable. This program attempts  to convert my GFF v.2 data files into valid GFF3 files. First, the type  column must be a valid Sequence Ontology term. For microarray data, this  can be 'microarray\_oligo'. For ChIP-seq data, the best terms may either be  'tag' or 'STS' (for Sequence Tag Site). Next, the group field should  contain both Name and ID tags. The old 'type' field will become the new  Name tag and will be used for grouping. The ID tag must be made unique  (accomplished by appending a unique number to the Name). Finally, the  source field could be better utilized with more unique information.

The program will accept and process one or more gff input files. It will  write a new file, renaming the extension to '.gff3' for each input file.

NOTE that this program will not deal with parent-child relationships. It  is strictly designed to work with very simple one-line features, such as  representing microarray data.

```
```
```
```
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

```
```
```
```
```
```
```
```
```
```
```
```