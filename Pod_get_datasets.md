_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
get\_datasets.pl

A program to collect data for a list of features

## SYNOPSIS ##
get\_datasets.pl `[`--options...`]` `[`<filename>`]`

```
  Options for existing files:
  --in <filename>
```
```
  Options for new files:
  --db <name | filename>
  --feature <type | type:source | alias>, ...
  --win <integer>                                           (500)
  --step <integer>                                          (win)
```
```
  Options for data collection:
  --ddb <name | filename>
  --data <none | file | type>, ...
  --method [mean|median|stddev|min|max|range|sum|rpm|rpkm]  (mean)
  --value [score|count|pcount|length]                       (score)
  --strand [all|sense|antisense]                            (all)
  --force_strand
  --exons
  --log
```
```
  Adjustments to features:
  --extend <integer>
  --start=<integer>
  --stop=<integer>
  --fstart=<decimal>
  --fstop=<decimal>
  --pos [5|m|3]                                             (5)
  --limit <integer>
```
```
  General options:
  --out <filename>
  --gz
  --cpu <integer>                                           (2)
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify an input file containing either a list of database features or  genomic coordinates for which to collect data. The file should be a  tab-delimited text file, one row per feature, with columns representing  feature identifiers, attributes, coordinates, and/or data values. The  first row should be column headers. Bed files are acceptable, as are  text files generated by other **BioToolBox** scripts. Files may be  gzipped compressed.

> 
--out <filename>


> Specify the output file name. Required for new feature tables; optional for  current files. If this is argument is not specified then the input file is  overwritten.

> 
--db <name | filename>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  from which gene or feature annotation may be derived. A database is  required for generating new data files with features. This option may  skipped when using coordinate information from an input file (e.g. BED  file), or when using an existing input file with the database indicated  in the metadata. For more information about using annotation databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.

> 
--feature <type | type:source | alias>,...


--feature genome


> Specify the type of feature from which to collect values. This is required  only for new feature tables. Three types of values may be passed: the  feature type, feature type and source expressed as 'type:source', or an  alias to one or more feature types. Aliases are specified in the  `biotoolbox.cfg` file and provide a shortcut to a list of one or more  database features. More than one feature may be included as a  comma-delimited list (no spaces).

> 
> To collect genomic intervals (or regions) simply specify 'genome' as  the feature type.

> 
--win <integer>


> When generating a new genome interval list (feature type 'genome'),  optionally specify the window size. The default size is defined in the  configuration file, biotoolbox.cfg.

> 
--step <integer>


> Optionally indicate the step size when generating a new list of intervals  across the genome. The default is equal to the window size.

> 
--ddb <name | filename>


> If the data to be collected is from a second database that is separate  from the annotation database, provide the name of the data database here.  Typically, a second `Bio::DB::SeqFeature::Store` or BigWigSet database  is provided here.

> 
--data <type1,type2,type3&type4,...>


--data <file1,...>


--data none


> Provide the name of the dataset to collect the values. Use this argument  repeatedly for each dataset to be collected. Two or more datasets may be merged into one by delimiting with an ampersand "&" (no spaces!). If no  dataset is specified on the command line, then the program will  interactively present a list of datasets from the database to select.

> 
> The dataset may be a feature type in a BioPerl Bio::DB::SeqFeature::Store  or Bio::DB::BigWigSet database. Provide either the feature type or  type:source. The feature may point to another data file whose path is  stored in the feature's attribute tag (for example a binary  Bio::Graphics::Wiggle .wib file, a bigWig file, or Bam file), or the  features' scores may be used in data collection.

> 
> Alternatively, the dataset may be a database file, including bigWig (.bw),  bigBed (.bb), useq (.useq), or Bam alignment (.bam) files. The files may  be local or remote (specified with a http: or ftp: prefix).

> 
> To force the program to simply write out the list of collected features  without collecting data, provide the dataset name of "none".

> 
--method `[`mean|median|stddev|min|max|range|sum|rpm|rpkm`]`


> Specify the method for combining all of the dataset values within the  genomic region of the feature. Accepted values include:

> 
> `*` mean (default)

> 
> `*` median

> 
> `*` sum

> 
> `*` stddev  Standard deviation of the population (within the region)

> 
> `*` min

> 
> `*` max

> 
> `*` range   Returns difference of max and min

> 
> `*` rpm     Reads Per Million mapped, Bam/BigBed only

> 
> `*` rpkm    Reads Per Kilobase per Million Mapped, Bam/BigBed only

> 
> When collecting data using rpkm, the normalized sum of the reads is  divided by the length of the feature requested (the Kilobase part in rpkm).  Note that for mRNA or gene features, this will be the sum of the exon  lengths, not the gene or transcript.
--value `[`score|count|pcount|length`]`


> Optionally specify the type of data value to collect from the dataset or  data file. Four values are accepted: score, count, pcount, or length.  The default value type is score. Note that some data sources only support certain  types of data values. The types are detailed below.

> 
> `*` score

> 
> > The default value. Supported by wig, bigWig, USeq, bigBed (if the features  include the score column), GFF features, and Bam (returns non-transformed  base pair coverage).

> 
> > 

> `*` count

> 
> > Counts the number of features that overlap the search region. For long  features (> 1 bp), these may include features that overlap or span beyond  the search region. Supported by all databases.

> 
> > 

> `*` pcount (precise count)

> 
> > Counts only those features that are contained within the search region,  not overlapping. Supported by Bam, bigBed, USeq, and GFF features.

> 
> > 

> `*` length

> 
> > Returns the length of long features. Supported by Bam, bigBed, USeq, and  GFF features.

> 
> > 
--strand `[`all | sense | antisense`]`



> Specify whether stranded data should be collected for each of the  datasets. Either sense or antisense (relative to the feature) data  may be collected. Note that strand is not supported with some  data files, including bigWig files (unless specified through a GFF3 feature  attribute or Bio::DB::BigWigSet database) and Bam files (score coverage is not but count is). The default value is 'all', indicating all data  will be collected.

> 
--force\_strand


> For features that are not inherently stranded (strand value of 0) or that you want to impose a different strand, set this option when collecting stranded data. This will reassign the specified strand for each feature regardless of its original orientation. This requires the presence of a "strand" column in the input data file. This option only works with input file lists of database features, not defined genomic regions (e.g. BED files). Default is false.

> 
--exons


> Optionally indicate that data should be collected only over the exon  subfeatures of a gene or transcript, rather than the entire gene.  Subfeatures with a primary\_tag of exon are preferentially taken. If exons  are not defined, then CDS and UTR subfeatures are used, or the entire  gene or transcript if no appropriate subfeatures are found. Note that  the options extend, start, stop, fstart, and fstop are ignored.  Default is false.

> 
--log


> Indicate the dataset is (not) in log2 space. The log2 status of the dataset is  critical for accurately mathematically combining the dataset values in the  feature's genomic region. It may be determined automatically if the dataset  name includes the phrase "log2".

> 
--extend <integer>


> Optionally specify the bp extension that will be added to both sides of the  feature's region.

> 
--start=<integer>


--stop=<integer>


> Optionally specify adjustment values to adjust the region to collect values  relative to the feature position defined by the --pos option (default is  the 5' position). A negative value is shifted upstream (5' direction),  and a positive value is shifted downstream. Adjustments are always made  relative to the feature's strand. Both options must be applied; one is  not allowed.

> 
--fstart=<number>


--fstop=<number>


> Optionally specify the fractional start and stop position of the region to  collect values as a function of the feature's length and relative to the  specified feature position defined by the --pos option (default is 5'). The  fraction should be presented as a decimal number, e.g. 0.25. Prefix a  negative sign to specify an upstream position. Both options must be  applied; one is not allowed.

> 
--pos `[`5|m|3`]`


> Indicate the relative position of the feature with which the  data is collected when combined with the "start" and "stop" or "fstart"  and "fstop" options. Three values are accepted: "5" indicates the  5' prime end is used, "3" indicates the 3' end is used, and "m"  indicates the middle of the feature is used. The default is to  use the 5' end, or the start position of unstranded features.

> 
--limit <integer>


> Optionally specify the minimum size limit for subfractionating a feature's  region. Used in combination with fstart and fstop to prevent taking a  subregion from a region too small to support it. The default is 1000 bp.

> 
--gz


> Indicate whether the output file should (not) be compressed by gzip.  If compressed, the extension '.gz' is appended to the filename. If a compressed  file is opened, the compression status is preserved unless specified otherwise.

> 
--cpu <integer>


> Specify the number of CPU cores to execute in parallel. This requires  the installation of Parallel::ForkManager. With support enabled, the  default is 2. Disable multi-threaded execution by setting to 1.

> 
--version


> Print the version number.

> 
--help


> Display the POD documentation for this program.

> 
## DESCRIPTION ##
This program will collect dataset values from a variety of sources, including  features in a BioPerl Bio::DB::SeqFeature::Store database, binary wig files  (.wib) loaded in a database using Bio::Graphics::Wiggle, bigWig files,  bigBed files, Bam alignment files, or a Bio::DB::BigWigSet database.

The values are collected for a list of known database features (genes,  transcripts, etc.) or genomic regions (defined by chromosome, start, and  stop). The list may be provided as an input file or generated as a new  list from a database. Output data files may be reloaded for additional  data collection.

At each feature or interval, multiple data points within the genomic segment  are combined statistically and reported as a single value for the feature.  The method for combining datapoints may be specified; the default method is  the mean of all datapoints.

The coordinates of the features may be adjusted in numerous ways, including  specifying a specific relative start and stop, a fractional start and stop,  an extension to both start and stop, and specifying the relative position  (5' or 3' or midpoint).

Stranded data may be collected, if the dataset supports stranded information.  Also, two or more datasets may be combined and treated as one. Note that  collecting stranded data may significantly slow down data collection.

The output file is a standard tim data formatted file, a tab delimited  file format with each row a genomic feature and each column a dataset.  Metadata regarding the datasets are stored in comment lines at the beginning  of the file. The file may be gzipped.

## EXAMPLES ##
These are some examples of some common scenarios for collecting data.

Simple mean scores


> You want to collect the mean score from a bigWig file for each feature  in a BED file of intervals.

> 
```
  get_datasets.pl --data scores.bw --in input.bed
```
Collect normalized counts


> You want to collect normalized read counts from a Bam file of alignments  for each feature in a BED file.

> 
```
  get_datasets.pl --data alignments.bam --method rpm --in input.bed
```
Collect stranded RNASeq data


> You have stranded RNASeq data, and you would like to determine the  expression level for all genes in an annotation database.

> 
```
  get_datasets.pl --db annotation --feature gene --data rnaseq.bam \
  --strand sense --exons --method rpkm --out expression.txt
```
Restrict to specific region


> You have ChIPSeq enrichment scores in a bigWig file and you now want  to score just the transcription start site of known transcripts in an  annotation database. Here you will restrict to 500 bp flanking the TSS.

> 
```
  get_datasets.pl --db annotation --feature mRNA --start=-500 \
  --stop=500 --pos 5 --data scores.bw --out tss_scores.txt
```
Count intervals


> You have identified all possible transcription factor binding sites in  the genome and put them in a bigBed file. Now you want to count how  many exist in each upstream region of each gene.

> 
```
  get_datasets.pl --db annotation --feature gene --start=-5000 \
  --stop=0 --data tfbs.bb --method sum --value count --out tfbs_sums.txt
```
Many datasets at once


> You can place multiple bigWig files in a single directory and treat it  as a data database, known as a BigWigSet. Each file becomes a database  feature, and you can interactively choose one or more from which to  collect. Each dataset is appended to the input file as new column.

> 
```
  get_datasets.pl --ddb /path/to/bigwigset --in input.txt
```
Stranded BigWig data


> You can generate stranded RNASeq coverage from a Bam file using the  BioToolBox script bam2wig.pl, which yields rnaseq\_f.bw and rnaseq\_r.bw  files. These are automatically interpreted as stranded datasets in a  BigWigSet context.

> 
```
  get_datasets.pl --ddb /path/to/rnaseq/bigwigset --strand sense \
  --in input.txt
```
Binned coverage across the genome


> You are interested in sequencing depth across the genome to look for  depleted regions. You count reads in 1 kb intervals across the genome.

> 
```
  get_datasets.pl --db genome.fasta --feature genome --win 1000 \
  --data alignments.bam --value count --method sum --out coverage.txt
```
Middle of feature


> You are interested in the maximum score in the central 50% of each  feature.

> 
```
  get_datasets.pl --fstart=0.25 --fstop=0.75 --data scores.bw --in \
  input.txt
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