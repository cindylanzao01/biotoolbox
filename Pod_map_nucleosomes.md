_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
map\_nucleosomes.pl

A script to map nucleosomes.

## SYNOPSIS ##
map\_nucleosomes.pl --db <text> --thresh <number> `[`--options...`]`

map\_nucleosomes.pl --data <text|file> --thresh <number> `[`--options...`]`

```
  Options:
  --db <text>
  --data <text|file>
  --thesh <number>
  --win <integer>       (145)
  --buf <integer>       (5)
  --gff
  --type <gff_type>
  --source <gff_source>
  --out <filename>
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--db <database\_name>


> Specify the name of a `Bio::DB::SeqFeature::Store` annotation database  or other indexed data file, e.g. Bam or bigWig file, from which chromosome  length information may be obtained. For more information about using databases,  see <https://code.google.com/p/biotoolbox/wiki/WorkingWithDatabases>.  Required unless data is pulled from a bigWig file (.bw).

> 
--data <text|file>


> Provide the name of the dataset and/or data files (bigWig format) containing the nucleosome midpoint occupancy data from which to identify nucleosomal positions. If data is obtained from a database, the name or type should be provided.

> 
--thresh <number>


> Provide the minimum score value required to call a nucleosome position.  This is only used when scanning the scan dataset.

> 
--win <integer>


> Provide the window size for which to scan the chromosome. Setting this   value too large and overlapping nucleosomes may result, while setting  this value too low may miss some nucleosomes. The default value is 145 bp.

> 
--buf <integer>


> Provide the buffer size in bp which will be added between the end of the  previous found nucleosome and the beginning of the window to scan for the  next nucleosome. Setting this value may limit the number of overlapping  nucleosomes. Default is 5 bp.

> 
--gff


> Indicate whether a GFF file should be written in addition to the standard  text data file. The GFF file version is 3. The default value is false.

> 
--type <gff\_type>


> Provide the text to be used as the GFF type (or method) used in  writing the GFF file. The default value is the name of the scan  dataset appended with "`_`nucleosome".

> 
--source <gff\_source>


> Provide the text to be used as the GFF source used in writing the  GFF file. The default value is the name of this program.

> 
--out <filename>


> Specify the output file name. The default is the name of the scan  dataset appended with "`_`nucleosome".

> 
--version


> Print the version number.

> 
--help


> Display the POD documentation of the script.

> 
## DESCRIPTION ##
This program will identify and map the positions of nucleosomes given a  dataset of nucleosome occupancy data. The dataset should ideally be  enumerated counts of sequenced nucleosomal fragment midpoints, although  very high resolution microarray data could also be used in principle.

Nucleosome calls are made by scanning the chromosomes in windows of specified size (default 145 bp, set with --win option) looking for the maximum peak that exceeds the minimum threshold value. The position of the maximum peak is called as the new nucleosome midpoint. The window is then advanced starting at the previous just-identified nucleosome endpoint, or at the end of the previous window if no nucleosome was identified. This position may be further advanced by setting the buffer value (default 5 bp), which inserts space between the previous nucleosome end and the next window. By advancing the window relative to the previously identified nucleosome, the program can adapt to variable nucleosome spacing and (hopefully) avoid overlapping nucleosome calls.

This approach works reasonably well if the data shows an inherent,  periodic pattern of peaks. Noisy datasets derived from partially  fragmented nucleosomes or low sequencing depth may require some  statistical smoothing.

## DATASETS ##
This programs expects to work with enumerated midpoint counts of  nucleosomal sequence fragments at a single bp resolution. Typically,  nucleosome fragments are sequenced using massively parallel sequencing  technologies, and the mapped alignments are converted to predicted  midpoint occupancy counts. The midpoints may be precisely mapped with  paired-end sequencing, or estimated by 3' end shifting of single-end  sequence alignments. See the BioToolBox script bam2wig.pl for one  approach.

## REPORTING ##
Two attributes of each identified nucleosome are calculated, Occupancy and Fuzziness. Occupancy represents the sum of the tag counts that support the nucleosome position; higher scores indicate a more highly occupied nucleosome. Fuzziness indicates how well all of the scores are aligned in register. The Fuzziness value is the standard deviation of the population of scores from the peak; a high value indicates the nucleosome has a fuzzy or variable position, whereas a low value indicates the nucleosome is highly positioned. For both attributes, the scores are counted in a window representing 1/2 of a nucleosome length (74 bp) centered on the defined nucleosome midpoint. The size of this window is arbitrary but reasonable.

The identified nucleosomes are artificially set to 147 bp in length, centered at the maximum peak. A second script, `get_actual_nuc_sizes.pl`, can determine the actual nucleosome sizes based on paired-end reads in a BAM file. Because of stochastic  positioning of nucleosomes in vivo, it is common to see 10-20% of  the mapped nucleosomes exhibit predicted overlap with its neighbors.

## PARAMETERS ##
The default values (window and buffer) were determined empirically using yeast nucleosomes and paired-end next generation sequencing.   Parameters tested included windows of 140 to 180 bp in 5 bp increments,  and buffers of 0 to 20 bp in 5 bp increments. In general, in order of  importance, lower threshold, lower buffer sizes (with the exception of  a buffer of 0 bp), and lower window sizes, lead to higher numbers of  nucleosomes identified. The percentages of predicted nucleosome overlap  and offcenter nucleosomes (where the observed tag dataset peak does not  correspond to the reported nucleosome midpoint) generally increase as  the number of nucleosomes are identified.

Values should be optimized and adjusted empirically for new datasets and confirmed in a genome browser.

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
