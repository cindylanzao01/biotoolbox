_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
merge\_SNPs.pl

## SYNOPSIS ##
merge\_SNPs.pl <file1> <file2> ...

## DESCRIPTION ##
This program will identify common and unique SNPs between two or more  sequenced strains. This is useful, for example, in identifying SNPs that  may be background polymorphisms common to all the strains, versus unique  SNPs that may be responsible for a mutant phenotype.

Each strain should have a separate SNP file, generated using the 'varFilter' function of the 'samtools.pl' script, part of the Samtools distribution <http://samtools.sourceforge.net>. That script will generate a list of the sequence variations that differ from the reference genome.  No verification of the source file format is performed. The files may be  gzipped.

In this script, the SNPs are sorted into groups based on their occurance in one or more strains. These groups are then written out to new separate files, with the file names being a concatenation of the representing original filenames. The file format is preserved, as each SNP line in the file is a representative example from one of the original strains.

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
```
```
```
```
```
```