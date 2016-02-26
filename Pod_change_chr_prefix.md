_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
change\_chr\_prefix.pl

A script will add/remove chromosome name prefixes.

## SYNOPSIS ##
change\_chr\_prefix.pl `[`--add | --strip`]` `[`--options...`]` <filename>

```
  Options:
  --in <filename>
  --out <filename> 
  --add
  --strip
  --roman
  --arabic
  --prefix <text>
  --contig
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input file. Supported file types include Bam, Sam, Bed,  GFF, Fasta, or other tab-delimited text files. Text-based files may be  compressed with gzip.

> 
--out <filename>


> Specify the output filename. By default it uses the input base name,  appended with either `_`chr or nochr.

> 
--add


--strip


> Specify the renaming action. One or the other must be specified. The add  action will prefix simple chromosome names (one to four characters) with  the prefix, while the strip action will remove the offending prefix.

> 
--roman


> Convert arabic numerals (1, 2 ... 30) to Roman numerals (I, II ... XXX).  Up to 30 is renamed, all others are ignored.

> 
--arabic


> Convert Roman numerals (I, II, ... XXX) to Arabic numerals (1, 2 ... 30). Only upper case are recognized. Higher numbers are ignored.

> 
--prefix <text>


> Specify the chromosome prefix. The default value is 'chr'.

> 
--contig


> Indicate whether contig and scaffold names should be included  in the renaming process. These are recognized by the text 'contig',  'scaffold', or 'NA' in the name. The default value is false.

> 
--gz


> Specify whether (or not) the output text file should be compressed with gzip.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will re-name chromosome names in a data file. Supported data  formats include Bam and Sam alignment files, GFF and BED feature files,  Fasta sequence files, wig and bedgraph files, and any other tab-delimited  text files.

Re-naming consists of either adding or stripping a prefix from the chromosome  name. Some genome repositories prefix their chromosome names with text,  most commonly 'chr', while other repositories prefer bare numbers, or  Roman numerals. UCSC and Ensembl are two good examples. Mixing  and matching annotation from different authorities requires matching  chromosome names.

Be careful with the conversions, and check carefully. Mitochondrial  chromosomes or other funny named chromosomes may need to be changed manually.

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
