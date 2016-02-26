_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
split\_bam\_by\_strand.pl

A script to split reads in a bam file into two separate bam files based on strand.

## SYNOPSIS ##
split\_bam\_by\_strand.pl <file.bam>

## DESCRIPTION ##
This program will read a bam file, identify aligned reads, and write the reads  to one of two output bam files based on the strand to which the alignment  matches. The output files are named the input base file name appended with  either '.f' or '.r'. Unmatched files are discarded. The output files are  then re-indexed for you. Header information, if present, is also retained.

This program is useful, for example, for stranded RNA-Seq, where you want to  examine each strand separately.

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