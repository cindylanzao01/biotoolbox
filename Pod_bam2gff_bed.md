_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
bam2gff\_bed.pl

A script to convert bam paired\_reads to a gff or bed file.

## SYNOPSIS ##
bam2gff\_bed.pl `[`--options...`]` <filename>

```
  Options:
  --in <filename>
  --bed | --gff | --bigbed | --bb
  --pe
  --type <text>
  --source <text>
  --randstr
  --out <filename> 
  --bbapp </path/to/bedToBigBed>
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the file name of a .bam alignment file. The file should be indexed.  If not, the program will attempt to automatically index it.

> 
--bed


--gff


--bigbed


--bb


> Specify the output file format. Either a BED file (6-columns) or GFF v.3  file will be written. You can also specify a bigBed format (bigbed or bb),  where a BED text file will first be generated and then automatically  converted to a compressed, binary BigBed file. The default behavior is to  write a BED file.

> 
--pe


> Indicate that the BAM data is paired end, and that the generated feature  should represent the insert fragment.

> 
--type <text>


> For GFF output files, specify the GFF type. The default is to use the  input file base name, appended with either '`_`reads' or '`_`paired\_reads'.

> 
--source <text>


> For GFF output files, specify the source tag. The default is 'Illumina'.

> 
--randstr


> For paired-end Bam files, specify that the strand of the alignment be  randomly assigned to either the forward or reverse strand.

> 
--out


> Specify the output file name. The default for GFF output files is to use  the GFF type; for BED output files the input file base name is used. A  '.bed' extension is added if necessary.

> 
--bbapp </path/to/bedToBigBed>


> Specify the path to the Jim Kent's bedToBigBed conversion utility. The  default is to first check the biotoolbox.cfg configuration file for  the application path. Failing that, it will search the default  environment path for the utility. If found, it will automatically  execute the utility to convert the bed file.

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
This program will convert alignments in a BAM formatted file into either a BED or GFF formatted feature file. For BED output, a 6-column BED file is generated. For GFF output, a v.3 GFF file is generated. In both cases, the alignment name, strand, and a score value is recorded.

Both single- and paired-end alignments may be converted. For paired-end  alignments, the genomic coordinates of the entire insert fragment is recorded.

The mapping quality score is recorded as the GFF or BED score. For paired-end  alignments, only the left score is recorded for efficiency.

The strand information is retained from the original alignment, except for  proper paired-end alignments. For paired-end alignments, the TopHat-specific  attribute XS is searched, and, if found, is used for the strand. Otherwise,  all features default to the forward strand. An option is available to  randomly assign a strand to paired-end features.

For BED files, coordinates are adjusted to interbase format, according to  the specification.

An option exists to further convert the BED file to an indexed, binary BigBed  format. Jim Kent's bedToBigBed conversion utility must be available.

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
