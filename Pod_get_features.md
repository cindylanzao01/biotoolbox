_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
get\_features.pl

A script to collect features from a BioPerl SeqFeature::Store database.

## SYNOPSIS ##
get\_features.pl --db <text> `[`--options...`]`

```
  Options:
  --db <text>
  --feature <type | type:source>
  --all
  --sub
  --coord
  --start=<integer>
  --stop=<integer>
  --pos [ 5 | m | 3 | 53 ]
  --out <filename>
  --bed
  --gff 
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--db <text>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  from which gene or feature annotation may be derived. A database is  required for generating new data files with features. For more information  about using annotation databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.

> 
--feature <type | type:source>


> Optionally specify the type of the feature(s) to collect. The GFF  primary\_tag or primary\_tag:source\_tag should be specified. More than  one feature may be specified at a time, either as a comma de-limited  list or separate options. If not specified, then an interactive list  will be presented to the user for selection.

> 
--all


> Optionally indicate that all features present in the database must  be included. By default, certain features may be excluded based on  parameters defined in the BioToolBox configuration file. See below  for details.

> 
--sub


> Optionally include all subfeatures in the output. For example,  transcript, CDS, and/or exon subfeatures of a gene.

> 
--coord


> When writing a standard format file, optionally include the chromosome,  start, stop, and strand coordinates. These are automatically included  when writing a BED or GFF format.

> 
--start=<integer>


--stop=<integer>


> Optionally specify adjustment values to adjust the reported start and  end coordinates of the collected regions. A negative value is shifted  upstream (towards the 5 prime end), and a positive value is shifted  downstream (towards the 3 prime end). Adjustments are made relative  to the indicated position (--pos option, below) based on the feature  strand. Adjustments are ignored if a GFF file is written.

> 
--pos `[` 5 | m | 3 | 53 `]`


> Indicate the relative position from which both coordinate adjustments  are made. Both start and stop adjustments may be made from the respective  5 prime, 3 prime, or middle position as dictated by the feature's strand  value. Alternatively, specify '53' to indicate that the start adjustment  adjusts the 5 prime end and the stop adjustment adjusts the 3 prime end.  The default is '53'.

> 
--out <filename>


> Specify the output file name. Default is the joined list of features.

> 
--bed


> Optionally indicate that a 6-column BED format file should be  written. Currently, 12-column BED formats with exon information is  not supported (yet).

> 
--gff


> Optionally indicate that a GFF3 format file should be written. This  option enables the database features to be written completely with  all attributes. Coordinate adjustments are ignored.

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
This program will extract a list of features from a database and  write them out to a file. Specifically, the requested features in  a Bio::DB::SeqFeature::Store schema database are pulled and written  as either a list of named features with or without coordinate information,  a BED-style formatted file, or a GFF3-formatted file. The GFF option  is essentially a database dump, as it enables a low-level option to  write the features as original GFF3 lines complete with all attributes.

Features may be specified through their GFF type or primary\_tag. They may be specified as a command-line option or selected interactively from a presented list. They may be restricted through two options defined in the BioToolBox configuration file, biotoolbox.cfg. These include a database-specific or default database option, "chromosome\_exclude", which excludes features located on the listed chromosomes (such as the mitochondrial chromosome), and the "exclude\_tags", which are attribute keys and values to be avoided. More information may be found in the configuration file itself.

## COORDINATE ADJUSTMENTS ##
Coordinates of the features may be adjusted as desired. Adjustments  may be made relative to either the 5 prime, 3 prime, both ends, or the  feature midpoint. Positions are based on the feature strand. Use the  following examples as a guide.

upstream 500 bp only


```
  get_features.pl --start=-500 --stop=-1 --pos 5
```
```
  get_features.pl --start=-500 --stop=500 --pos 5
```
last 500 bp of feature


```
  get_features.pl --start=-500 --pos 3
```
middle 500 bp of feature


```
  get_features.pl --start=-250 --stop=250 --pos m
```
entire feature plus 1 kb of flanking


```
  get_features.pl --start=-1000 --stop=1000 --pos 53
```
Note that positions are always in base coordinates, and the resulting regions  may be 1 bp longer depending on whether the reference base was included or not.

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
