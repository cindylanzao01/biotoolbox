_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
split\_by\_tags.pl

## SYNOPSIS ##
split\_by\_tags.pl <sequence.fastq> <tag1> <tag2> ...

## DESCRIPTION ##
This program will split a single fastq file into multiple fastq files based on  a barcode tag at the 5' end of the sequence. Usually the barcode is two  nucleotides, plus a T for linker ligation, for example GGT or AAT. After  identifying the tag in the sequence, it is stripped from the sequeence. A  separate file is then written for each tag, with the output file name being the  basename appended with the tag sequence. Input files may be gzipped, and  output files will preserve compression status. Input files should have a  recognizable extension, e.g. .txt, .fa, .fq, .fastq.

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