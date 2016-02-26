_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
split\_bam\_by\_isize.pl

A script to selectively write out paired-end alignments of a given insertion size.

## SYNOPSIS ##
split\_bam\_by\_isize.pl `[`--options`]` <file.bam>

```
  Options:
  --in <file.bam>
  --min <integer>       (100)
  --max <integer>       (200)
  --size <min-max>
  --out <filename>
  --at
  --quick
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <file.bam>


> Specify the file name of a binary Bam file of paired-end alignments  as described for Samtools. Use samtools to convert text Sam files  to binary Bam files. The file should be sorted and indexed; this  program should be able to do it for you automatically if it is not  (assuming the bam directory is writeable).

> 
--min <integer>


> Optionally specify the minimum size of fragment to include in the output Bam file. Not required if the --size option is used. The default value  is 100 bp.

> 
--max <integer>


> Optionally specify the maximum size of fragment to include in the output Bam file. Not required if the --size option is used. The default value  is 200 bp.

> 
--size <min-max>


> When multiple size ranges are desired, they may be specified using the  size option. Define the minimum and maximum size as a range separated by  a dash (no spaces). Use this option repeatedly for multiple size ranges.  Size ranges may overlap. The size option takes precedence over the --min  and --max options.

> 
--out <filename>


> Optionally specify the base name of the output file. The default is to use  base input name. The output file names are appended with '.$min`_`$max'.

> 
--at


> Boolean option to indicate that only alignments whose query sequence  begins with an `[`AT`]` nucleotide should be included in the output Bam file(s).  Micrococcal nuclease (MNase) cuts (almost?) exclusively at `[`AT`]``[`AT`]`  dinucleotides; this option ensures that the fragment is more likely derived  from a MNase cut.

> 
> By default, both mates must pass the AT test prior to writing.

> 
--quick


> Boolean option to quickly split the Bam file without checking both mates.  By default, both mates in a pair must exist and be checked prior to writing,  which increases processing time and memory requirements. Each mate in the  pair must have the same ID tag to be considered paired.

> 
> When both the --quick and --at option (above) are enabled, each read mate is  checked independently, potentially leading to the possibility of only one  mate in a pair being written to the output file.

> 
--version


> Print the version number.

> 
--help


> Display the POD documentation

> 
## DESCRIPTION ##
This program will read a BAM file containing paired-read alignments and write a new BAM file containing only those successfully aligned paired  reads whose insert size fall within the set minimum and maximum  lengths inclusively (defaults of 100 and 200 bp, respectively).

Multiple size ranges may be specified, and pairs within each range are  written to separate files.

Additionally, fragments may be checked for the presence of an A/T nucleotide  at the 5' end of the sequence, as is usually produced by digestion with  Micrococcal Nuclease. This does NOT ensure that the original cut site was  AA, TT, or AT, as we only have one half of the site in the read sequence,  only that it increases the liklihood of being an A/T dinucleotide  (absolute checking would require looking up the original sequence).

The input and output files are BAM files as described by the Samtools  project (http://samtools.sourceforge.net).

The input file should be sorted and indexed prior to sizing. The output  file(s) will be automatically re-sorted and re-indexed for you.

A number of statistics about the read pairs are also written to standard  output for your information, including the number of proper alignments  in each requested size range, the number of alignments that fail the AT  check (if requested), and the number of improper paired alignments,  including those whose mates align to the same strand or different  chromosomes, or pairs with a non-aligned mate. Given the vagaries of  different alignment possibilities and enumerations, not all possible  combinations may be accounted.

If no pairs are written to the output file(s), try enabling the --quick  option. It may be that only one of the two mates are actually present  in the Bam file, or that they do not have matching ID numbers.

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
