_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
correlate\_position\_data.pl

A script to calculate correlations between two datasets along the length of a feature.

## SYNOPSIS ##
correlate\_position\_data.pl `[`--options`]` <filename>

```
  Options:
  --in <filename>
  --out <filename> 
  --db <name | filename>
  --ddb <name | filename>
  --ref <type | filename>
  --test <type | filename>
  --pval
  --shift
  --radius <integer>
  --pos [5|m|3]                 (m)
  --norm [rank|sum ]
  --force_strand
  --(no)interpolate
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input file of features. The features may be comprised of  name and type, or chromosome, start, and stop. Strand information is  optional, but is respected if included. A feature list may be  generated with the program _get\_features.pl_. The file may be  compressed with gzip.

> 
--out <filename>


> Specify the output filename. By default it rewrites the input file.

> 
--db <name | filename>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  from which gene or feature annotation may be derived. A database is  required for generating new data files with features. This option may  skipped when using coordinate information from an input file (e.g. BED  file), or when using an existing input file with the database indicated  in the metadata. For more information about using annotation databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.

> 
--ddb <name | filename>


> If the data to be collected is from a second database that is separate  from the annotation database, provide the name of the data database here.  Typically, a second `Bio::DB::SeqFeature::Store` or BigWigSet database  is provided here.

> 
--ref <type | filename>


--test <type | filename>


> Define both the reference and test datasets with which to compare and  correlate. These may be GFF type or name in a database or BigWigSet, or  they may be a BigWig or even Bam file. Both options are required. If  not provided, they may be interactively chosen from the database.

> 
--pval


> Perform an ANOVA analysis between the test and reference data sets and  report a P-value. By default, this performs a dependent, parametric  ANOVA. This requires the `Statistic::ANOVA` module to be installed.  Please refer to the module documentation for details. If your needs  require a change to the test, you may edit the parameters at the top  of this script. For convenience, the P-values are reported as -Log10(P)  transformed values. The default is false.

> 
--shift


> Optionally specify whether an optimal shift should be calculated that  would result in a better Pearson correlation value. The default is  false.

> 
--radius <integer>


> Define the radius in basepairs around a reference point to determine  the window size for the correlation analysis. This value is required  when calculating an optimal shift (--shift option). The default is to  take the length of the feature as the window for calculating the  correlation.

> 
--pos `[`5|m|3`]`


> Indicate the relative position of the feature to be used as the  reference point around which the window (determined by the radius  value) for collecting data will be centered. Three values are  accepted: "5" indicates the 5' prime end is used, "3" indicates the  3' end is used, and "m" indicates the middle of the feature is used.  The default is to use the midpoint.

> 
--norm `[`rank|sum`]`


> Optionally define a method of normalizing the scores between the  reference and test data sets prior to calculating the correlation.  Two methods are currently supported: "rank" converts all values  to rank values (the mean rank is reported for identical values)  and essentially calculating a Spearman's rank correlation, while  "sum" scales all values so that the absolute sums are identical.  Normalization occurs after missing or zero values are interpolated.  The default is no normalization.

> 
--force\_strand


> If enabled, a strand orientation will be enforced when determining the  optimal shift. This does not affect the correlation calculation, only  the direction of the reported shift. This requires the presence of a  data column in the input file with strand information. The default is  no enforcement of strand.

> 
--(no)interpolate


> Interpolate missing or zero positioned values in each window for both  reference and test data. This will improve the Pearson correlation  values, especially for sparse data. Enabled by default.

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
This program will calculate statistics between the positioned scores of two different datasets over a window from an annotated feature or chromosomal segment. These statistics will help determine whether the positions or distribution of scores across the window vary or underwent a positional shift between a test and a reference dataset. For example, if the enrichment of nucleosome signal from a ChIP experiment shifts in genomic position, indicating a change in nucleosome position.

Two statistics may be calculated. First, it will calculate a a Pearson linear correlation coefficient (r value) between the datasets (default).  Additionally, an ANOVA analysis may be performed between the datasets and  generate a P-value.

By default, the correlation is determined between the data points  collected over the entire length of the feature. Alternatively, a  radius and reference point (default is midpoint) may be provided  that sets the window for collecting scores and calculating a correlation.

To ensure a more reliable Pearson value, missing values or values of  zero are interpolated from neighboring values, when possible. Also,  values may be normalized using one of two methods. The values may be  converted to rank positions (compare to Kendall's tau), or scaled such  that the absolute sum values are equal (for example, when working with  sequence tag read counts).

In addition to calculating a correlation coefficient, an optimal shift  may also be calculated. This essentially shifts the data, 1 bp at a time,  in order to identify a shift that would produce a higher correlation.  The window is shifted from -2 radius to +2 radius relative to the  reference point, and the highest correlation is reported along with the  shift value that generated it.

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
