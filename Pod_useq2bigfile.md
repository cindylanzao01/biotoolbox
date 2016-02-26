_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

# THIS SCRIPT IS DEPRECATED #

## NAME ##
useq2bigfile.pl (DEPRECATED)

## SYNOPSIS ##
useq2bigfile.pl --bw|bb `[`--options`]` <filename.useq>

```
  Options:
  --in <filename.useq>
  --bw
  --bb
  --gr
  --method [mean|median|sum|max]
  --(no)log
  --strand [f|r]
  --chromof <chromosome_sizes_filename>
  --db <database>
  --bigapp </path/to/bigFileConverter>
  --useqapp </path/to/USeq2Text>
  --out <filename>
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input useq archive file. The file must have an .useq extension.

> 
--bw


--bb


> Specify the output format of the big file to be generated. A bigWig file (bw)  may be generated, or a bigBed (bb) file may be generated.

> 
--gr


> When generating a bigWig file, specify that a source bedgraph file should be  written. This requires the application bedGraphToBigWig. If the source data  represents regions (> 1 bp) with scores, it is best to use bedGraph. The  default is to write a variableStep wig file (regions are converted to the  midpoint position), in which case the application wigToBigWig is used instead.

> 
--method `[`mean|median|sum|max`]`


> Specify the method for dealing with multiple values at identical positions.  USeq and Bar files tolerate multiple values at identical positions, but Wig  and BigWig files do not. Hence, the values at these positions must be combined  mathematically. This does not apply to BigBed files.

> 
--(no)log


> If multiple data values need to be combined at a single identical  position, indicate whether the data is in log2 space or not. This  affects the mathematics behind the combination method.

> 
--strand `[`f|r`]`


> Specify that only one strand of data should be taken. The strand should be  specified as either 'f' (forward or +) or 'r' (reverse or -). Unstranded  data is always kept. The default is to keep all data and merge the data.

> 
--chromof <chromosome\_sizes\_filename>


> A chromosome sizes file may be provided. This is a simple text file  comprised of two columns separated by whitespace. The first column is the  chromosome name, the second column is the chromosome length in bp. There is  no header. This file is required by the BigFile converter applications.

> 
--db <database>


> As an alternative to specifying the chromosome sizes file, a database may  be specified from which to collect the chromosome lengths. A GFF3 file or  SQLite database file may also be provided.

> 
--bigapp </path/to/bigFileConverter>


> Specify the path to the appropriate BigFile converter application. Supported  applications include wigToBigWig, bedGraphToBigWig, and bedToBigBed. These  may be obtained from UCSC. The default is check the biotoolbox.cfg  configuration file, followed by the default environment path using the  'which' command. The appropriate utility is selected based on the selected  output format. When generating bigWig files, the bedGraph source format can  be specified using the --gr option.

> 
--useqapp </path/to/USeq2Text>


> Specify the path to David Nix's USeq2Text application, part of the USeq  package. The default is check the biotoolbox.cfg configuration file.

> 
--out <filename>


> Specify the output filename. By default it uses the input base name.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
NOTE: This program is deprecated. David now includes a USeq2UCSCBig App in  the USeq package. Furthermore, the USeq2Text App generates a different  output that is currently incompatible with this script. Such is progress.

This program will convert a USeq archive into a Big file format, either bigWig or bigBed. This program is essentially a wrapper around two other converter applications with some text manipulation in between. The first is a java application from David Nix's USeq package, USeq2Text, which extracts the coordinates, scores, and text from the USeq archive and writes a 6-column bed file. The bed file is then parsed to remove anomolous data and prepared for conversion to a big file format. The second convertor application, one of three utilities developed by Jim Kent, is then used to convert to the appropriate big file.

Two different output formats are possible, bigWig and bigBed. The bigWig  format is best used with data that contains scores at discrete genomic  positions or intervals. The bigBed format can also support scores at  discrete positions, as well as genomic intervals (features) of varying  lengths that may or may not include text (names) and/or scores.

The intermediate bed file is screened for anomolous data, including multiple  scores at identical genomic positions (not supported with wig, bedGraph, or  BigWig files) and positions outside of the genomic coordinates (greater than  the chromosome length). These will cause the conversion to a big file format  to fail.

Two converters are supported for generating bigWig files: bedGraphToBigWig  and wigToBigWig. The bedGraphToBigWig converter uses slightly less memory  but generates larger bigWig files. It also handles scored regions > 1 bp.  The wigToBigWig converter produces smaller files but requires more memory,  and in this case only works with point data (for regions it uses the  midpoint).

For converting to bigBed files, the bedToBigBed convertor is used. Note that bigBed files have stricter requirements for the score value, which should be an integer between 0 and 1000. Score values which do not meet these requirements are converted and warnings are issued. If these are important to you, you may wish to manually scale the scores using [manipulate\_datasets.pl](Pod_manipulate_datasets_pl.md) or convert to bigWig instead.

More information about bigWig files may be found here [Pod\_http_"/genome.ucsc.edu/goldenPath/help/bigWig.html" in http:]. More information about  bigBed files may be found here  <http://genome.ucsc.edu/goldenPath/help/bigBed.html>. More information about  the USeq archive may be found here [Pod\_http_ "/useq.sourceforge.net/useqArchiveFormat.html" in http:].

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
