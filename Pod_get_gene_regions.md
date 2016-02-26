_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
get\_gene\_regions.pl

A script to collect specific, often un-annotated regions from genes.

## SYNOPSIS ##
get\_gene\_regions.pl `[`--options...`]` --db <text> --out <filename>

get\_gene\_regions.pl `[`--options...`]` --in <filename> --out <filename>

```
  Options:
  --db <text>
  --in <filename>
  --out <filename> 
  --feature <type | type:source>
  --transcript [all|mRNA|ncRNA|snRNA|snoRNA|tRNA|rRNA|miRNA|lincRNA|misc_RNA]
  --region [tss|tts|exon|altExon|commonExon|firstExon|lastExon|
            intron|firstIntron|lastIntron|splice]
  --start=<integer>
  --stop=<integer>
  --unique
  --slop <integer>
  --mix
  --bed
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--db <text>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  from which gene or feature annotation may be derived. A database is  required for generating new data files with features. For more information  about using annotation databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.  Also see `--in` as an alternative.

> 
--in <filename>


> Alternative to a database, a GFF3 annotation file may be provided.  For best results, the database or file should include hierarchical  parent-child annotation in the form of gene -> mRNA -> `[`exon or CDS`]`.  The GFF3 file may be gzipped.

> 
--out <filename>


> Specify the output filename.

> 
--feature <type | type:source>


> Specify the parental gene feature type (primary\_tag) or type:source when using a database. If not specified, a list of available types will be presented interactively to the user for selection. This is not relevant for GFF3 source files (all gene or transcript features are considered). This is  helpful when gene annotation from multiple sources are present in the same  database, e.g. refSeq and ensembl sources. More than one feature may be  included, either as a comma-delimited list or multiple options.

> 
--transcript `[`all|mRNA|ncRNA|snRNA|snoRNA|tRNA|rRNA|miRNA|lincRNA|misc\_RNA`]`


> Specify the transcript type (usually a gene subfeature) from which to   collect the regions. Multiple types may be specified as a comma-delimited  list, or 'all' may be specified. If not specified, an interactive list  will be presented from which the user may select.

> 
--region <region>


> Specify the type of region to retrieve. If not specified on the command  line, the list is presented interactively to the user for selection. Ten  possibilities are possible.

> 
```
     tss         The first base of transcription
     tts         The last base of transcription
     exon        The exons of each transcript
     firstExon   The first exon of each transcript
     lastExon    The last exon of each transcript
     altExon     All alternate exons from multiple transcripts for each gene
     commonExon  All common exons between multiple transcripts for each gene
     intron      Each intron (usually not defined in the GFF3)
     firstIntron The first intron of each transcript
     lastIntron  The last intron of each transcript
     splice      The first and last base of each intron
```
--start=<integer>


--stop=<integer>


> Optionally specify adjustment values to adjust the reported start and  end coordinates of the collected regions. A negative value is shifted  upstream (5' direction), and a positive value is shifted downstream. Adjustments are made relative to the feature's strand, such that  a start adjustment will always modify the feature's 5'end, either  the feature startpoint or endpoint, depending on its orientation.

> 
--unique


> For gene features only, take only the unique regions. Useful when  multiple alternative transcripts are defined for a single gene.

> 
--slop <integer>


> When identifying unique regions, specify the number of bp to  add and subtract to the start position (the slop or fudge factor)  of the regions when considering duplicates. Any other region  within this window will be considered a duplicate. Useful, for  example, when start sites of transcription are not precisely mapped,  but not useful with defined introns and exons. This does not take  into consideration transcripts from other genes, only the current  gene. The default is 0 (no sloppiness).

> 
--mix


> Allow two or more different transcript types from genes to be used. Some genes may generate more than one transcript type, for example  mRNA and certain non-coding RNAs. By default, only one type of RNA  transcript type is accepted. This is usually mRNA, if requested.

> 
--bed


> Automatically convert the output file to a BED file.

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
This program will collect specific regions from annotated genes and/or  transcripts. Often these regions are not explicitly defined in the  source GFF3 annotation, necessitating a script to pull them out. These  regions include the start and stop sites of transcription, introns,  the splice sites (both 5' and 3'), exons, the first (5') or last (3')  exons, or all alternate or common exons of genes with multiple  transcripts. Importantly, unique regions may only be reported,  especially important when a single gene may have multiple alternative  transcripts. A slop factor is included for imprecise annotation.

The program will report the chromosome, start and stop coordinates,  strand, name, and parent and transcript names for each region  identified. The reported start and stop sites may be adjusted with  modifiers. A standard biotoolbox data formatted text file is generated.  This may be converted into a standard BED or GFF file using the  appropriate biotoolbox scripts. The file may also be used directly in  data collection.

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
