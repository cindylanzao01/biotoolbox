_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
find\_nucleosome\_movement.pl

A script to map nucleosome movement based on mononucleosome DNA hybridzed  to Agilent cerevisiae 244K arrays.

## SYNOPSIS ##
find\_nucleosome\_movement.pl `[`--options...`]`

```
  --db <database_name>
  --dataf <filename>
  --data <dataset_name>
  --gain <number>
  --loss <number>
  --type <gff_type>
  --source <gff_source>
  --out <filename>
  --delta <number>
  --win <integer>
  --help
```
```
```
```
```
## OPTIONS ##
The command line flags and descriptions:

--db <database\_name>


> Specify the name of the BioPerl gff database to pull the source data.

> 
--dataf <filename>


> Provide the name of a data file containing the dataset. The file  should provide genomic coordinates (e.g. GFF file). If more than  one dataset is within the file, then the dataset name should be  provided.

> 
--data <dataset\_name>


> Provide the name of the dataset containing the nucleosome occupancy data from which to identify the movements. The dataset should be a ratio  or normalized difference between experimental and control nucleosome  occupancies. It is assumed to be in log2 data space.

> 
--gain <number>


> Provide the minimum score value required to identify a gain event.  Adjacent concordant gain and loss identifies nucleosome movement.

> 
--loss <number>


> Provide the minimum score value required to identify a loss event.  Adjacent concordant gain and loss identifies nucleosome movement.  The loss number is automatically converted to a negative if  necessary (assuming the data is in log2 space).

> 
--type <gff\_type>


> Provide the text to be used as the GFF type (or method) used in  writing the GFF file. It is also used as the base for the event  name. The default value is the dataset name appended with  '`_`movement'.

> 
--source <gff\_source>


> Provide the text to be used as the GFF source used in writing the  GFF file. The default value is the name of this program.

> 
--out <filename>


> Specify the output file name. The default is to use the type provided.

> 
--delta <number>


> Provide the minimum absolute difference value to call a nucleosome  movement event. The default is the sum of absolute gain and loss  values.

> 
--win <integer>


> Provide the maximum window size in bp to look for adjacent probes when  calling nucleosome movement events. The number should be greater than  the average microarray probe spacing but less than the length of a  nucleosome. The default value is 100 bp.

> 
--help


> Display the POD documentation of the script.

> 
## DESCRIPTION ##
This program will look for nucleosome movement. It was designed explicitly to look for shifts in nucleosome occupancy in medium to high resolution microarrays, such as the Agilent 244K array for cerevisiae. A nucleosome movement event is defined as a concordant gain and loss of nucleosome signal (occupancy) at two neighboring probes. The neighboring probes must be within a specified window size (default 100 bp). The dataset to be scanned should be a log2 ratio or normalized difference between experimental and control nucleosome occupancies. Both minimum gain and loss values must be met, and optionally the minimum delta value (absolute difference between the adjacent probe values).

A tim data file will be written and a GFF file suitable for  loading in GBrowse are written.

```
```
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
## TODO ##
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