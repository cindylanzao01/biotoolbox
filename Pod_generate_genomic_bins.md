_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
generate\_genomic\_bins.pl

## SYNOPSIS ##
generate\_genomic\_bins.pl `[`--options...`]` --db <database> --out <file>

```
  Options:
  --db <database>
  --win <integer>
  --step <integer>
  --mito
  --split
  --max <integer>
  --out <filename> 
  --(no)gz
  --help
```
```
```
## OPTIONS ##
The command line flags and descriptions:

--db <database>


> Specify the name of the BioPerl gff database to use as source. This is required.

> 
--win <integer>


> Optionally specify the window size. The default size is defined in the configuration file, biotoolbox.cfg.

> 
--step <integer>


> Optionally indicate the step size. The default is equal to the window size.

> 
--mito


> Specify whether the mitochondrial chromosome should be included. The  default is false.

> 
--split


> Specify whether the output file should be split into individual chromosome  files.

> 
--max <integer>


> When splitting the output file, optionally specify the maximum number of  lines in each file part.

> 
--out <filename>


> Specify the output filename. By default it uses

> 
--(no)gz


> Specify whether (or not) the output file should be compressed with gzip.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will generate a tim data format file of genomic bins or  intervals. Generating bins of small size (say, 1 or 10 bp in size)  for an entire genome, particularly metazoan genomes, produces  extremely large data files, which demands large memory resources to  load. This simple script avoids the memory demands by writing  directly to file as the bins are generated. It will optionally also  split the file by chromosome (using the biotoolbox script  split\_data\_file.pl).

```
```
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