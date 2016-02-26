_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
intersect\_SNPs.pl

A script to identify unique and common SNPs from multiple sequence runs.

## SYNOPSIS ##
intersect\_SNPs.pl <file1.vcf> <file2.vcf> ...

```
  Options:
  --in <filename>
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input SNP files. The files should be in the .vcf  format, and may be gzipped. Each SNP file is assumed to contain  one sample or strain only.

> 
--gz


> Specify whether (or not) the output files should be compressed  with gzip.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This simple program will identify unique and common Single Nucleotide  Polymorphisms (SNPs) between two or more sequenced strains. This is  useful, for example, in isolating unique SNPs that may be responsible  for a mutant phenotype from background polymorphisms common to the  strains.

Each strain should have a separate SNP file in the Variant Call Format  (VCF) 4.0 or 4.1 format, a tab-delimited text file with metadata.  See <http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41>  for more information about the format. The files may be gzipped.

Numerous SNP callers are capable of generating the VCF format from  sequence (usually Bam) files. The Samtools program is one such program,  using the "mpileup" function in conjunction with it's "bcftools" tool.  See the Samtools site at <http://samtools.sourceforge.net> for more  information.

Note that this program currently loads all SNPs into memory, thus for  large genomes extensive memory requirements may be required.

SNPs are identified as unique vs common based on the reported coordinate  and the alternate sequence. Overlapping SNPs will likely be treated  separately. The unique SNPs are written to a new file with the file's  base name appended with "`_`unique". The VCF format and headers are  maintained.

The common SNPs are written to a separate VCF file, with the file name  comprised of input file base names appended with "`_`common". Genotype  data, if present, is stripped from the common SNP, and only one  representative is recorded.

Note that certain sequence variants may be reported as unique when  in fact identical alternate sequences are also present in other strains.  Usually in these cases, One of the strains has an additional variant  sequence not present in the other.

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
