_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
locate\_SNPs.pl

A script to locate the position of SNPs and identify codon changes.

## SYNOPSIS ##
```
 locate_SNPs.pl --db <database> <snp_file1> ...
```
```
  Options:
  --in <snp_file>
  --db <database>
  --features type1,type2,...
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <snp\_file>


> Specify the name(s) of the input SNP file(s). SNP files should be in the  Variation Call Format (VCF) format. They may be gzipped. Multiple files  may be specified; they will be processed sequentially. Provide multiple  --in arguments, a comma delimited list, or a free list at the end of  the command.

> 
--db <database>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  from which gene or feature annotation may be derived. For more  information about using annotation databases, see  <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.

> 
--features type1,type2,...


> Provide a comma-delimited list (no spaces) of the GFF3 feature types  of the features to intersect with the SNPs. Complex gene structures  (gene->mRNA->CDS) can be parsed to look for amino-acid changes. The  default feature is "gene".

> 
--version


> Print the version number.

> 
--help


> This help text.

> 
## DESCRIPTION ##
This program will locate SNPs and other sequence variants and identify  the feature that overlaps the variant. In most cases, the features are  genes, in which case the corresponding coding sequence (CDS), if  present, is evaluated for a change in coding potential due to the  sequence variation. Codon changes, silent changes, and frame shifts  may be reported.

The input SNP files must be in the Variant Call Format (VCF) 4.0 or  4.1 format, a tab-delimited text file with metadata.  See <http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41>  for more information about the format. The files may be gzipped.

Numerous SNP callers are capable of generating the VCF format from  sequence (usually Bam) files. The Samtools program is one such program,  using the "mpileup" function in conjunction with it's "bcftools" tool.  See the Samtools site at <http://samtools.sourceforge.net> for more  information.

The output file is a simple tab-delimited text file with headers,  suitable for opening in spread-sheet program. Each row represents a SNP.  The following columns are include.

```
  Variation_Type (substitution, insertion, deletion)
  Overlapping_Feature (feature type, name, alias)
  Subfeature (exon, CDS, etc)
  Codon_Change (Reference AA -> mutant AA)
  Chromosome
  Position (start position, 1-base, forward strand)
  Reference_Seq
  Variant_Seq
  Number_Supporting_Reads (if reported)
  Total_Number_Reads (if reported)
  Percent_Supporting_Reads (if reported)
  Genotype (if reported)
  Feature_description (if present in the database)
```
If more than one variant sequence is reported at a position, then each  is evaluated for effects on the coding potential. If more than one  feature is found overlapping the SNP, then both features are reported.

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
