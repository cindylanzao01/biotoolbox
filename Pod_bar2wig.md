_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
bar2wig.pl

A script to convert bar files to wig files.

## SYNOPSIS ##
bar2wig.pl `[`--options...`]` <filename>

```
  Options:
  --in <filename>
  --out <filename> 
  --method [mean|median|sum|max]
  --log
  --track
  --bw
  --barapp </path/to/Bar2Gr>
  --bwapp </path/to/wigToBigWig>
  --db <database>
  --chromof </path/to/chromosomes>
  --gz
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input bar file or (more likely) a directory of bar files.  The bar files may be zipped (`*`.bar.zip).

> 
--out <filename>


> Specify the output filename. By default it uses the base name of the  input file or the input directory name. The output file will either  have a .wig or .bw file extension.

> 
--method `[`mean | median | sum | max`]`


> Define the method used to combine multiple data values at a single  position. Bar files can frequently have one or more values at a single  position, usually due to either multiple identical oligo probes (microarray  data) or multiple sequence tags aligning to the same position (next  generation sequencing data). Typically, with FDR or microarray data,  the mean or max value should be taken, while bar files representing  sequence tag PointData should be summed.

> 
--log


> If multiple data values need to be combined at a single identical  position, indicate whether the data is in log2 space or not. This  affects the mathematics behind the combination method.

> 
--track


> Wig files typically include a track line at the beginning of the file which  defines the appearance. However, conversion of a wig file to bigWig  requires that the track line is absent. Do not include the track line when  generating bigWig files manually. The default is to include for wig files  (true), and exclude for bigWig files (false).

> 
--bw


> Flag to indicate that a binary bigWig file should be generated rather than  a text wig file.

> 
--barapp </path/to/Bar2Gr>


> Specify the full path to David Nix's USeq or T2 application Bar2Gr (it  is included in both software packages). By default it uses the path  defined in the biotoolbox configuration file, biotoolbox.cfg.

> 
--bwapp </path/to/wigToBigWig>


> Specify the full path to Jim Kent's wigToBigWig conversion utility. By  default it uses the path defined in the biotoolbox configuration file,  biotoolbox.cfg. If it is not defined here or in the config file, then  the system path is searched for the executable.

> 
--db <database>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  or other indexed data file, e.g. Bam or bigWig file, from which chromosome  length information may be obtained. For more information about using databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>. It  is only required when generating a bigWig file.

> 
--chromof </path/to/chromosomes>


> Alternative to the --db argument, a pre-generated chromosome sizes text  file may be specified. This text file should consist of two columns,  delimited by whitespace, consisting of the chromosome name and size.

> 
--gz


> Specify whether (or not) the output wig file should be compressed with gzip. Default is false.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will convert binary .bar files to a conventional  text-based wig file, with the option to further convert to a binary  bigWig format.

The bar file is a Java serialized, floating-point, binary file used natively by David Nix's TiMAT2 (T2) and USeq software packages. It allows for effective visualization by the Integrated Genome Browser (IGB), but very few (any?) other genome browsers.

The wig file is a commonly used text-based file format for exchanging and  representing dense genomic data (microarray and sequencing) that is read  by nearly all genome browsers. In most genome browsers, the data values are  downsampled to 8-bit precision (0-255), sufficient for visualization but  limited for data analysis.

The bigWig format is an indexed, compressed, binary extension of the wig format. It maintains numeric precision, allows for rapid statistical summaries, and can be rapidly and randomly accessed either locally or remotely. It is supported by the UCSC and GBrowse genome browsers as well  as biotoolbox scripts.

This program first uses David Nix's Bar2Gr application to convert the bar  file to a very simplified text format, a .gr file. This is then further  processed into one or more wig (or bigWig) files. Stranded data (denoted  by `_`+`_` and `_`-`_` in the bar file names) is written to two stranded output  files, appended with either '`_`f' or '`_`r' to the basename. The wig files  are in variableStep format.

You may find the latest version of the USeq package, which contains the  Bar2Gr Java application, at http://sourceforge.net/projects/useq/. Specify  the path to the Bar2Gr file in the USeq/Apps directory. You may record this information in the BioToolBox configuration file biotoolbox.cfg.

Conversion from wig to bigWig requires Jim Kent's wigToBigWig utility or  Lincoln Stein's Bio::DB::BigFile support.

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
