_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
bam2wig.pl

A script to enumerate Bam alignments or coverage into a wig file.

## SYNOPSIS ##
bam2wig.pl `[`--options...`]` <filename.bam>

```
  Required options:
  --in <filename.bam>
```
```
  Reporting options:
  --position [start|mid|span|extend]                (start)
  --coverage
  --bin <integer>
  --strand
  --flip
  --rpm
  --log [2|10]
  --max <integer>
  --ext <integer>
```
```
  Alignment options:
  --pe
  --splice
  --qual <integer>
```
```
  Shift options:
  --shift
  --shiftval <integer>
  --chrom <integer>                                 (2)
  --sample <integer>                                (300)
  --minr <float>                                    (0.25)
  --model
```
```
  Output options:
  --out <filename> 
  --bw
  --bwapp </path/to/wigToBigWig or /path/to/bedGraphToBigWig>
  --gz
```
```
  General options:
  --cpu <integer>                                   (2)
  --max_cnt <integer>
  --buffer <integer>
  --count <integer>
  --verbose
  --version
  --help                              detailed documentation
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input Bam alignment file. The file should be sorted by  genomic position and indexed, although it may be indexed automatically.

> 
--position `[`start|mid|span|extend`]`


> Specify the position of the alignment coordinate which should be  recorded. Several positions are accepted:

> 
```
    start     the 5 prime position of the alignment
    mid       the midpoint of the alignment (or pe fragment)
    span      along the length of the alignment (read coverage)
    extend    along the length of the predicted fragment
              equal to 2 x the shift value (enables --shift) 
    coverage  another way to specify --coverage
```
> With paired-end alignments, the positions are relative to the entire  insert fragment defined by two proper alignments. For single-end  alignments, the default value is coverage if no other options are  specified, otherwise start. For paired-end alignments, the midpoint  position is the default.

> 
--coverage


> Quickly calculates the coverage of the alignments over the genome,  either at single bp resolution (default) or in bins. This method ignores  the position, quality, strand, shift, and log options. It is  equivalent to specifying --position=span, --split, --nope, --noshift,  --nostrand, --qual=0, --max=8000, --norpm, and no log.

> 
--bin <integer>


> Specify the window or bin size in which alignment counts are summed.  This option is compatible with start, mid, and coverage recording  options, but is automatically disabled with span and extend recording  options. The default is to count at single basepair resolution.

> 
--strand


> Indicate that separate wig files should be written for each strand.  The output file basename is appended with either '`_`f' or '`_`r' for  both files. For paired-end RNA-Seq alignments that were generated with  TopHat, the XS attribute is honored for strand information.  The default is to take all alignments regardless of strand.

> 
--flip


> Flip the strand of the output files when generating stranded wig files.  Do this when RNA-Seq alignments map to the opposite strand of the  coding sequence.

> 
--rpm


> Convert the data to Reads (or Fragments) Per Million mapped. This is useful  for comparing read coverage between different datasets. Only alignments  that match the minimum mapping quality are counted. Only proper paired-end  alignments are counted, they are counted as one fragment. The conversion is  applied before converting to log, if requested. This will increase processing  time, as the alignments must first be counted. Note that all duplicate reads  are counted during the pre-count. The default is no RPM conversion.

> 
--log `[`2|10`]`


> Transform the count to a log scale. Specify the base number, 2 or  10. Only really useful with Bam alignment files with high count numbers.  Default is to not transform the count.

> 
--max <integer>


> Set a maximum number of duplicate alignments tolerated at a single position.  This uses the alignment start (or midpoint if recording midpoint) position  to determine duplicity. Note that this has no effect in coverage mode.  You may want to set a limit when working with random fragments (sonication)  to avoid PCR bias. Note that setting this value in conjunction with the --rpm  option may result in lower coverage than anticipated, since the pre-count  does not account for duplicity. The default is undefined (no limit).

> 
--ext <integer>


> Manually set the length for reads to be extended when position is set to  either span or extend. By default, the alignment length is used for single-end span, the insertion size for paired-end span, and 2 X the shift value for  extend.

> 
--pe


> The Bam file consists of paired-end alignments, and only properly  mapped pairs of alignments will be counted. Properly mapped pairs  include FR reads on the same chromosome, and not FF, RR, RF, or  pairs aligning to separate chromosomes. The default is to  treat all alignments as single-end.

> 
--splice


> The Bam file alignments may contain splices, where the  read is split between two separate alignments. This is most common  with splice junctions from RNA-Seq data. In this case, treat each  alignment as a separate tag. This only works with single-end alignments.  Splices are disabled for paired-end reads. Note that this will  increase processing time.

> 
--qual <integer>


> Set a minimum mapping quality score of alignments to count. The mapping quality score is a posterior probability that the alignment was mapped incorrectly, and reported as a -10Log10(P) value, rounded to the nearest integer (range 0..255). Higher numbers are more stringent. For performance reasons, when counting paired-end reads, only the left alignment is checked. The default value is 0 (accept everything).

> 
--shift


> Specify that the positions of the alignment should be shifted towards  the 3' end. Useful for ChIP-Seq applications, where only the ends of  the fragments are counted and often seen as separated discrete peaks  on opposite strands flanking the true target site. This option is  disabled with paired-end and spliced reads (where it is not needed).

> 
--shiftval <integer>


> Provide the value in bp that the recorded position should be shifted.  The value should be 1/2 the average length of the library insert size. The default is to automatically and empirically determine the  appropriate shift value using cross-strand correlation (recommended).

> 
--chrom <integer>


> Indicate the number of sequences or chromosomes to sample when  empirically determining the shift value. The reference sequences  listed in the Bam file header are taken in order of decreasing  length, and one or more are taken as a representative sample of  the genome. The default value is 2.

> 
--sample <integer>


> Indicate the number of top coverage regions from each chromosome  scanned to sample when empirically determining the shift value.  The default is 200.

> 
--minr <float>


> Provide the minimum R^2 value to accept a shift value when  empirically determining the shift value. Enter a decimal value  between 0 and 1. Higher values are more stringent. The default  is 0.25.

> 
--model


> Indicate that the shift model profile data should be written to  file for examination. The average profile, including for each  sampled chromosome, are reported for the forward and reverse strands,  as  well as the shifted profile. A standard text file is generated  using the output base name. The default is to not write the model  shift data.

> 
--out <filename>


> Specify the output base filename. An appropriate extension will be  added automatically. By default it uses the base name of the  input file.

> 
--bw


> Specify whether or not the wig file should be further converted into  an indexed, compressed, binary BigWig file. The default is false.

> 
--bwapp < /path/to/wigToBigWig or /path/to/bedGraphToBigWig >


> Specify the full path to Jim Kent's bigWig conversion utility. Two  different utilities may be used, bedGraphToBigWig or wigToBigWig,  depending on the format of the wig file generated. The application  paths may be set in the biotoolbox.cfg file.

> 
--gz


> Specify whether (or not) the output file should be compressed with  gzip. The default is compress the output unless a BigWig file is  requested. Disable with --nogz.

> 
--cpu <integer>


> Specify the number of CPU cores to execute in parallel. This requires  the installation of Parallel::ForkManager. With support enabled, the  default is 2. Disable multi-threaded execution by setting to 1.

> 
--max\_cnt <integer>


> In special coverage mode only, this option sets the maximum coverage count  at any given base. The default is 8000 (set by the bam adaptor).

> 
--buffer <integer>


> Specify the length in bp to reserve as buffer when writing a bedGraph  file to account for future read coverage. This value must be greater  than the expected alignment length (including split alignments),  paired-end span length (especially RNA-Seq), or extended coverage  (2 x alignment shift). Increasing this value may result in increased  memory usage, but will avoid errors with duplicate positions  written to the wig file. The default is 5000 bp.

> 
--count <integer>


> Specify the number of alignments processed before writing to file.  Increasing this count will reduce the number of disk writes and increase  performance at the cost of increased memory usage. Lowering will  decrease memory usage. The default is 200,000 alignments.

> 
--verbose


> Print warnings when read counts go off the end of the chromosomes,  particularly with shifted read counts. Also print the correlations  for each sampled region as they are calculated when determining the  shift value. When writing the model file, data from each region is  also written. The default is false.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will enumerate aligned sequence tags and generate a wig,  or optionally BigWig, file. Alignments may be counted and recorded  in several different ways. Strict enumeration may be performed and  recorded at either the alignment's start or midpoint position.  Alternatively, either the alignment or fragment may be recorded  across its span. Finally, a basic unstranded, unshifted, and  non-transformed alignment coverage may be generated.

Both paired-end and single-end alignments may be counted. Alignments  with splices (e.g. RNA-Seq) may be counted singly or separately.  Alignment counts may be separated by strand, facilitating analysis of  RNA-Seq experiments.

For ChIP-Seq experiments, the alignment position may be shifted  in the 3 prime direction. This effectively merges the separate peaks  (representing the ends of the enriched fragments) on each strand  into a single peak centered over the target locus. Alternatively,  the entire predicted fragment may be recorded across its span.  This extended method of recording infers the mean size of the  library fragments, thereby emulating the coverage of paired-end  sequencing using single-end sequence data. The shift value is  empirically determined from the sequencing data (see below) or  provided by the user. If requested, the shift model profile may be  written to file. Use the BioToolBox script [graph\_profile.pl](Pod_graph_profile_pl.md) to  graph the data.

The output wig file may be either a variableStep, fixedStep, or  bedGraph format. The file format is dictated by where the alignment  position is recorded. Recording start and midpoint at single  base-pair resolution writes a variableStep wig file. Binned start  or midpoint counts and coverage are written as a fixedStep wig file.  Span and extended positions are written as a bedGraph file.

The wig file may be further converted into a compressed, indexed, binary  bigWig format, dependent on the availability of the appropriate  conversion utilities.

## RECOMMENDED SETTINGS ##
The type of wig file to generate for your Bam sequencing file can vary  depending on your particular experimental application. Here are a few  common sequencing applications and my recommended settings for generating  the wig or bigWig file.

Straight coverage


> To generate a straight-forward coverage map, similar to what most genome  browsers display when using a Bam file as source, use the following  settings:

> 
```
 bam2wig.pl --coverage --in <bamfile>
```
Single-end ChIP-Seq


> When sequencing Chromatin Immuno-Precipitation products, one generally  performs a 3 prime shift adjustment to center the fragment's end reads  over the predicted center and putative target. To adjust the positions  of tag count peaks, let the program empirically determine the shift  value from the sequence data (recommended). Otherwise, if you know  the mean size of your ChIP eluate fragments, you can use the --shiftval  option.

> 
> To evaluate the empirically determined shift value, be sure to include  the --model option to examine the profiles of stranded and shifted read  counts and the distribution of cross-strand correlations.

> 
> Depending on your downstream applications and/or preferences, you  can record strict enumeration (start positions) or coverage (extend  position).

> 
> Finally, to compare ChIP-Seq alignments from multiple experiments,  convert your reads to Reads Per Million Mapped, which will help to  normalize read counts.

> 
```
 bam2wig.pl --pos start --shift --model --rpm --in <bamfile>
```
```
 bam2wig.pl --pos extend --model --rpm --in <bamfile>
```
Paired-end ChIP-Seq


> If both ends of the ChIP eluate fragments are sequenced, then we do not  need to calculate a shift value. Instead, we will simply count at the  midpoint of each properly-mapped sequence pair, or record the defined  fragment span.

> 
```
 bam2wig.pl --pos mid --pe --rpm --in <bamfile>
```
```
 bam2wig.pl --pos span --pe --rpm --in <bamfile>
```
Unstranded RNA-Seq


> With RNA-Sequencing, we may be interested in either coverage (generating  a transcriptome map) or simple tag counts (differential gene expression),  so we can count in one of two ways.

> 
> To compare RNA-Seq data from different experiments, convert the read  counts to Reads Per Million Mapped, which will help to normalize read  counts.

> 
```
 bam2wig --pos span --rpm --in <bamfile>
```
```
 bam2wig --pos mid --rpm --in <bamfile>
```
Stranded, single-end RNA-Seq


> If the library was generated in such a way as to preserve strand, then  we can separate the counts based on the strand of the alignment. Note  that the reported strand may be accurate or flipped, depending upon  whether first-strand or second-strand synthesized cDNA was sequenced,  and whether your aligner took this into account. Check the Bam  alignments in a genome browser to confirm the orientation relative to  coding sequences. If alignments are opposite to the direction of  transcription, you can include the --flip option to switch the output.

> 
```
 bam2wig --pos span --strand --rpm --in <bamfile>
```
```
 bam2wig --pos mid --strand --rpm --in <bamfile>
```
Stranded, paired-end RNA-Seq


> Strand presents a complication when sequencing both ends of the cDNA  product from a library that preserves orientation. Currently,  the TopHat aligner can handle stranded, paired-end RNA-Seq alignments.  Because each pair will align to both strands, the aligner must record  separately which strand the original fragment should align. The TopHat  program records an 'XS' attribute for each alignment, and, if present,  bam2wig.pl will use this to set the strand.

> 
```
 bam2wig --pe --pos span --strand --rpm --in <bamfile>
```
```
 bam2wig --pe --pos mid --strand --rpm --in <bamfile>
```
## TEXT REPRESENTATION OF RECORDING ALIGNMENTS ##
To help users visualize how this program records alignments in a wig  file, drawn below are 10 alignments, five forward and five reverse.  They may be interpreted as either single-end or paired-end. Drawn  below are the numbers that would be recorded in a wig file for various  parameter settings. Note that alignments are not drawn to scale and  are drawn for visualization purposes only. Values of X represent 10.

Alignments


```
  ....>>>>>>.....................................<<<<<<.............
  .....>>>>>>..................................<<<<<<...............
  ........>>>>>>.......................................<<<<<<.......
  ........>>>>>>.........................................<<<<<<.....
  ..........>>>>>>............................................<<<<<<
```
Starts


```
  ....11..2.1.......................................1.1.....1.1....1
```
Midpoints


```
  ......11..2.1..................................1.1.....1.1....1...
```
Stranded Starts


```
  F...11..2.1.......................................................
  R.................................................1.1.....1.1....1
```
Span (Coverage)


```
  ....122244433311.............................112222111122221211111
```
Stranded Span


```
  F...122244433311..................................................
  R............................................112222111122221211111
```
Shifted Starts (shift value 26)


```
  .........................1.1.11..3.11...1.........................
```
Shifted Span (shift value 26)


```
  .........................23447776552311111........................
```
Extend (extend value 52)


```
  12223445789999XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX999887665321111
```
Paired-End Midpoints


```
  ............................1...111..1............................
```
Paired-End Span


```
  ....12224455555555555555555555555555555555555555555443333332211111
```
## TROUBLESHOOTING ##
If you have spliced reads spanning introns from RNA-Seq data, you may  get warnings about duplicate positions in your wig or bedGraph file.  This is especially the case when converting to bigWig files. In this  case, increase the --buffer value to accomodate these large introns.

## SHIFT VALUE DETERMINATION ##
To empirically determine the shift value, a cross-strand correlation  method is employed. Regions with the highest read coverage  are sampled from one or more chromosomes listed in the Bam file.  The default number of regions is 200 sampled from each of the two  largest chromosomes. The largest chromosomes are used merely as a  representative fraction of the genome for performance reasons. Stranded read counts are collected in 10 bp bins over a 1300 bp region (the  initial 500 bp high coverage region plus flanking 400 bp). A Pearson  product-moment correlation coefficient is then reiteratively determined  between the stranded data sets as the bins are shifted from 0 to 400 bp.  The shift corresponding to the highest R squared value is recorded for  each sampled region. The default minimum R squared value to record an  optimal shift is 0.25, and not all sampled regions may return a  significant R squared value. After collection, outlier shift values  > 1.5 standard deviations from the mean are removed, and the trimmed  mean is used as the final shift value.

This approach works best with clean, distinct peaks, although even  noisy data can generate a reasonably good shift model. If requested,  a text file containing the average read count profiles for the forward  strand, reverse strand, and shifted data are written so that a model  graph may be generated. You can generate a visual graph of the shift  model profiles using the following command:

```
 graph_profile.pl --skip 4 --offset 1 --in <shift_model.txt>
```
The peak shift may also be evaluated by viewing separate, stranded wig  files together with the shifted wig file in a genome browser.

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
