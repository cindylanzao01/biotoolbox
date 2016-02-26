# HOWTO: Working with Next Generation Sequencing data #

This is an example guide for collecting data from next generation sequencing experiments. These are usually short sequence tags, sequenced by the millions in a parallel fashion, representing genomic DNA, cDNA from RNA, or ChIP. In these cases, we want to associate the number of sequence tags with specific genomic annotation, usually genes. For example, what is the expression level of a gene (how many sequenced cDNA fragments align to that gene?) or where does a transcription factor occupy (how many ChIP DNA fragments associate with a gene promoter?).

### Notes on running the **biotoolbox** scripts ###
  * All of the scripts are designed to be run from the scripts directory. Most require helper modules found in the lib directory, which the script should be able to find on its own if the directory structure is not changed.
  * All of the scripts, when run without any arguments, should present a short synopsis of the arguments.
  * Most of the scripts will provide additional help when run with the `-h` or `--help` arguments. The help is taken from internal POD documentation, which can also be viewed by entering `perldoc <script.pl>`.
  * A configuration file, `biotoolbox.cfg`, for defining database arguments, among other things, is included in the **biotoolbox** root directory. A custom copy may be placed in the root of your home directory, or specified using an environment variable `BIOTOOLBOX`.

### Alignment data ###
We'll begin by assuming you have your sequence data. It's usually returned as FastQ files - sequence with quality. This will, in turn, need to be aligned to your reference genome. There are numerous alignment algorithms out there, some better than others, some faster than others. These programs will generate an alignment for each read (if it was mappable), consisting of at minimum chromosome, start, stop, strand, and usually lots of other information, such as probability scores, mismatch information, etc.

Each alignment program may have a native file format, but the de facto standard used now is the [SAM format](http://samtools.sourceforge.net/). More specifically, the compressed, indexed, binary version is the BAM format, which allows for quick, random lookups of any alignment anywhere in the genome, and can usually be accessed locally or across the network.

All of the **biotoolbox** scripts described here presume the use of Bam files. Most alignment programs now output in SAM format; if not, there is usually a conversion utility to generate the Sam file. From there, the SAM file may be converted to a BAM file using [Samtools](http://samtools.sourceforge.net/) or its sister project, the Java-based [Picard](http://picard.sourceforge.net/index.shtml). Additionally, the Bam file should be sorted and indexed.

It's possible to represent the alignments in other formats. See below for using the Big File formats, BigWig and BigBed.

### Getting Annotation ###
Since we're interested in genomic annotation, we need a source for the annotation. If you're using [GBrowse](http://www.gmod.org/wiki/GBrowse) and have a [Bio::DB::SeqFeature::Store](http://bioperl.org/wiki/Module:Bio::DB::SeqFeature::Store) database already set up, then GREAT! you can use that. Be sure to edit the **biotoolbox** file `biotoolbox.cfg` with the credentials for connecting to the database.

If you don't have annotation yet, please check out some of the other **biotoolbox** scripts for obtaining annotation, including [ucsc\_table2gff3.pl](Pod_ucsc_table2gff3.md) and [get\_ensembl\_annotation.pl](Pod_get_ensembl_annotation.md). If you have simple annotation that can be represented by a 6-column BED format, then you can skip the database and just use your BED file as input.

### Collecting quick read coverage ###
The main program we will use is [get\_datasets.pl](Pod_get_datasets.md). For this, we'll presume we have a Bio::DB::SeqFeature::Store database named `hg19` with proper credentials and/or path recorded in the `biotoolbox.cfg` file.

To get simple coverage over all genes, over their entire length, we run the following command using our Bam file as the data
<pre>
Elessar:~ tim$ ./biotoolbox/scripts/get_datasets.pl --db hg19 --feature gene --data /path/to/my/data.bam --method sum --value count --out gene_count<br>
<br>
A program to collect feature data from the database<br>
<br>
Generating a new feature list from database 'hg19'...<br>
Searching for gene:refGene<br>
Found 25191 features in the database.<br>
Kept 25191 features.<br>
Collecting count sum from dataset 'file:/path/to/my/data.bam'... in 31.2 minutes"<br>
wrote file './gene_count.txt'<br>
Completed in 31.2 minutes<br>
</pre>

This will generate the file `gene_count.txt`, where each row is a gene, and each row consists of four columns: Name, Type, Alias, and a summed count of reads. You can read more about the [output format](TimDataFormat.md). We use the method `sum` to enumerate the read count, or we could easily use mean, median, max, or some other method. To specifically count the number of reads, we set the value to `count`. Alternatively, we could simply look at the basepair coverage (how many reads overlap each base within the interrogated region), in which case we would use `score` as the value.

Since human genes tend to be quite large, and often mostly intron, it may not be useful to simply count over the entire gene. In that case, we can limit to gene exons by including the `--exons` option. Note this will only work with gene models that include exon subfeatures.

A better option might be to convert the summed read count to Reads Per Kilobase per Million mapped, or RPKM. This normalizes the read count to the number of reads in the Bam file, as well as the length of the transcript (sum of exon lengths). Simply use `--method rpkm`, and the script should take care of the necessary calculations for you.

If we had multiple Bam files, we could list them all in the command line, either as separate `--data` options or as a comma-delimited list (no spaces!) under a single `--data` option. For each data source, a new column will be added to the output file.

### Collecting windowed data relative to feature ###
Perhaps we are looking at ChIP data for a transcription factor, and we want to know the relative occupancy around the promoter, or transcription start site (TSS), of each gene. We could do one of two things.

First, we could use [get\_datasets.pl](Pod_get_datasets.md) as above, but restrict the collection to just the promoter region (-500 to +500 bp). This will generate a single value for each promoter.
<pre>
Elessar:~ tim$ ./biotoolbox/scripts/get_datasets.pl --db hg19 --feature gene --data /path/to/my/data.bam --method mean --value count --start=-500 --stop=500 --out gene_promoter_count<br>
</pre>

Alternatively, we could collect windowed data across the promoter to finely map the data to a specific location within the promoter. For this, we will use [get\_relative\_data.pl](Pod_get_relative_data.md). This program will collect data in windows or bins relative to a specific feature. We will specify the same region around the TSS (-500..+500), but in ten 50 bp windows on either side (20 total).
<pre>
Elessar:~ tim$ ./biotoolbox/scripts/get_relative_data.pl --db hg19 --feature gene --data /path/to/my/data.bam --method mean --value score --num 10 --bin 50 --out gene_promoter_count<br>
</pre>

Notice here we switched to using basepair coverage (`score`) and a method of `mean` for each window. The output file will now contain twenty columns of data, each labeled with the coordinates of the window. The program defaults to using the 5' end of the feature as the relative position, but we could easily change this to the midpoint or 3' end.

### Representing Alignment Data in Other Formats ###
There are some limitations to working with Bam alignment data that could be better solved by pre-processing the data. Here are a couple of scenarios.

  * Working with Bam files can be slow, as each alignment must be processed. In most cases, we're just interested in the position of the tag. It's much faster to pre-process the alignments into position - occupancy data, where we record a value of 1 at each start position for each read.
  * ChIP DNA sequence tags represent only the ends of the fragments that collectively overlap the target binding site, and therefore the alignments rarely overlap the actual site. In a browser, this would be represented by two distinct peaks of enrichment, each on opposite strands, flanking the actual binding site. The solution is to the shift the alignment position towards the 3' direction to center the enrichment over the actual target site.
  * Paired-end sequencing, where both ends of each DNA fragment in the library are sequenced. You could treat each end separately, but in most cases you would want the entire fragment represented by both alignments. In this case, you could convert both alignments into a single segment (chromosome, start, stop), or simply enumerate into position - occupancy data recorded at the midpoint.
  * RNA-Sequencing data may unstranded or stranded, and if it is stranded, whether the first strand or second strand synthesis was sequenced. Therefore, the strand of the alignment may not represent the actual RNA strand (the alignment strands may need to be flipped).
  * Statistical enrichment of the alignments, relative to an input or reference standard, is preferred. For example, P-Value or False Discovery Rate scores may be used.

In these cases, we can convert the Bam file data into position - occupancy data representing tag enumeration, base pair coverage, or even enrichment score values. There are numerous ways to do this, including using the **biotoolbox** scripts [bam2wig.pl](Pod_bam2wig.md) (which enumerates alignments) and [bam2gff\_bed.pl](Pod_bam2gff_bed.md) (which converts alignments to segments), as well as other software packages, such as [BEDTools](http://code.google.com/p/bedtools/) or [USeq](http://useq.sourceforge.net/).

To enumerate alignment tags and convert to a normalized Reads Per Million mapped count, run [bam2wig.pl](Pod_bam2wig.md).
<pre>
Elessar:~ tim$ ./biotoolbox/scripts/bam2wig.pl --rpm --in /path/to/data.bam<br>
</pre>
This will generate by default a gzipped [wig file](http://genome.ucsc.edu/goldenPath/help/wiggle.html) in variableStep format, recording each alignment at its 5' position, and converting the resulting numbers to Reads Per Million mapped. To generate a [bigWig file](http://genome.ucsc.edu/goldenPath/help/bigWig.html) format, include the `--bw` option, which will require having the necessary converters installed.

To shift the enumeration, as desired for ChIP DNA alignments, include the `--shift` option and provide a suitable value. Usually 1/2 of the average library insert size is sufficient.

To convert paired-end alignments into segments (chromosome, start, stop), use [bam2gff\_bed.pl](Pod_bam2gff_bed.md):
<pre>
Elessar:~ tim$ ./biotoolbox/scripts/bam2gff_bed.pl --bed --pe --in /path/to/data.bam<br>
</pre>
This will generate a 6-column [BED file](http://genome.ucsc.edu/FAQ/FAQformat.html#format1). To generate a [bigBed file](http://genome.ucsc.edu/goldenPath/help/bigBed.html), specify `--bb` instead of `--bed`.

#### Using Other Formats ####
Once your alignment data is converted to a wig, bigWig, or bigBed file, you can then use the same analysis programs as above for data collection.

For wig files, you will need to either generate bigWig files (much preferred), or generate GFF3 files pointing to binary .wib files and load them in a Bio::DB::SeqFeature::Store database, as described [here](http://search.cpan.org/~lds/GBrowse-2.44/bin/wiggle2gff3.pl).

For bigWig and bigBed files, you can specify the file itself on the command line just as you would with a Bam file. The big files are self-contained, indexed data files, just as Bam files, and may be used either locally or remotely.

In most cases, you will want to use the `--value score` option (the default) for wig and bigWig files, and probably `--value count` with bigBed files.