_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
gff3\_to\_ucsc\_table.pl

A script to convert a GFF3 file to a UCSC style refFlat table

## SYNOPSIS ##
gff3\_to\_ucsc\_table.pl `[`--options...`]` <filename>

```
  Options:
  --in <filename>
  --out <filename> 
  --alias
  --gz
  --verbose
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input GFF3 file. The file may be compressed with gzip.

> 
--out <filename>


> Specify the output filename. By default it uses the input file base  name appended with '.refFlat'.

> 
--alias


> Specify that any additional aliases, including the primary\_ID, should  be appended to the gene name. They are concatenated using the pipe "|" symbol.

> 
--gz


> Specify whether (or not) the output file should be compressed with gzip.  The default is to mimic the status of the input file

> 
--verbose


> Specify that extra information be printed as the GFF3 file is parsed.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will convert a GFF3 annotation file to a UCSC-style  gene table, using the refFlat format. This includes transcription  and translation start and stops, as well as exon start and stops,  but does not include coding exon frames. See the documentation at  <http://genome.ucsc.edu/goldenPath/gbdDescriptionsOld.html#RefFlat>  for more information.

The program assumes the input GFF3 file includes standard  parent->child relationships using primary IDs and primary tags,  including gene, mRNA, exon, CDS, and UTRs. Non-standard genes,  including non-coding RNAs, will also be processed too. Chromosomes,  contigs, and embedded sequence are ignored. Non-pertinent features are  safely ignored but reported. Most pragmas are ignored, except for close  feature pragmas (###), which will aid in processing very large files.  Multiple parentage and shared features, for example exons common to  multiple alternative transcripts, are properly handled. See the  documentation for the GFF3 file format at  <http://www.sequenceontology.org/resources/gff3.html> for more  information.

Previous versions of this script attempted to export in the UCSC  genePredExt table format, often with inaccurate results. Users  who need this format should investigate the `gff3ToGenePred`  program available at <http://hgdownload.cse.ucsc.edu/admin/exe/>.

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
