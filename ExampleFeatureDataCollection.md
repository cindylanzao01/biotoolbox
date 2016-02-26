# HOWTO: Generating a feature list and collecting data #

This is an example guide for collecting features and dataset from a Bio::DB::SeqFeature::Store database housing genomic features and a microarray data set using **biotoolbox** scripts. This presumes that the database is already set up and loaded. You can read more about [loading a database](WorkingWithDatabases.md).

### Notes on running the **biotoolbox** scripts ###
  * All of the scripts are designed to be run from the scripts directory. Most require helper modules found in the lib directory, which the script should be able to find on its own if the directory structure is not changed.
  * All of the scripts, when run without any arguments, should present a short synopsis of the arguments.
  * Most of the scripts will provide additional help when run with the `-h` or `--help` arguments. The help is taken from internal POD documentation, which can also be viewed by entering `perldoc <script.pl>`.
  * A configuration file, `biotoolbox.cfg`, for defining database arguments, among other things, is included in the **biotoolbox** root directory. A custom copy may be placed in the root of your home directory, or specified using an environment variable `BIOTOOLBOX`.

### Generating a feature list ###
We want to collect a list of genes from the database. First, we need to identify the feature type we want from the database. We can use [db\_types.pl](Pod_db_types.md) to generate a list of features present in the database. We are using the database _cerevisiae\_20100109_
<pre>
Elessar:~ tim$ db_types.pl cerevisiae_20100109<br>
Found 28 feature types in database 'cerevisiae_20100109'<br>
There are 2 feature types with source 'Publication'<br>
TF_binding_site<br>
uORF<br>
There are 25 feature types with source 'SGD'<br>
ARS<br>
CDS<br>
LTR_retrotransposon<br>
binding_site<br>
centromere<br>
chromosome<br>
external_transcribed_spacer_region<br>
five_prime_UTR_intron<br>
gene<br>
....<br>
</pre>
The feature we are after is gene. To collect the gene features from the database, we can specify `gene`. But what if there are multiple gene features stored in the database from different sources, say refseq and ensembl? We can include the source in the specification, as in `gene:SGD`. This would correspond to the 3rd:2nd columns in the original source GFF annotation file.

To collect the dataset, we use the script [get\_datasets.pl](Pod_get_datasets.md). There are several programs which are capable of generating new feature lists. We won't be collecting a dataset at this moment, so we'll specify no dataset.
<pre>
Elessar:~ tim$ get_datasets.pl --db cerevisiae_20100109 --feature gene:SGD --data none --out gene_list<br>
<br>
A program to collect feature data from the database<br>
<br>
Generating a new feature list from database 'cerevisiae_20100109'...<br>
Searching for gene:SGD<br>
Found 6607 features in the database.<br>
Kept 5778 features.<br>
wrote file './gene_list.txt'<br>
Completed in 0.0 minutes<br>
</pre>

The file that is generated, `gene_list.txt`, is in a tab-delimited text format with special comment lines that I've (not so) creatively called a [Tim Data Format](TimDataFormat.md). We can see this format here.
<pre>
Elessar:~ tim$ head gene_list.txt<br>
# Program /Applications/biotoolbox/scripts/get_datasets.pl<br>
# Database cerevisiae_20100109<br>
# Feature gene:SGD<br>
# Column_1 index=0;name=Name<br>
# Column_2 index=1;name=Type<br>
# Column_3 index=2;name=Aliases<br>
Name	Type	Aliases<br>
YAL068C	gene:SGD	PAU8<br>
YAL067W-A	gene:SGD	.<br>
YAL067C	gene:SGD	SEO1<br>
</pre>
The comment lines provide metadata regarding which program generated the list, the database used, and the feature type. Additionally, each column or dataset has a metadata line comprised of key=value pairs. At least two metadata keys are required, index and name. The first row of the tab-delimited table are the column headers, and should match the name in the metadata lines.


### Refining the feature list ###
Say that we are interested in only genes from chromosome 2 that are above 2 kb in length (PI's can be very particular in their questions). To collect additional information about our genes, we can use [get\_feature\_info.pl](Pod_get_feature_info.md). We specify two attributes to collect: chromo(some) and length.
<pre>
Elessar:~ tim$ get_feature_info.pl --attrib chromo,length gene_list.txt<br>
<br>
This script will get additional information about features<br>
<br>
Loading feature list from 'gene_list.txt'....<br>
Retrieving chromo, length<br>
Wrote file './gene_list.txt'<br>
That's it!<br>
</pre>
We do not need to specify the database when running this program, as it will automatically get the database name from the input file metadata. We see that two additional columns have been added.
<pre>
Elessar:~ tim$ head gene_list.txt<br>
# Program /Applications/biotoolbox/scripts/get_datasets.pl<br>
# Database cerevisiae_20100109<br>
# Feature gene:SGD<br>
# Column_1 index=0;name=Name<br>
# Column_2 index=1;name=Type<br>
# Column_3 index=2;name=Aliases<br>
# Column_4 index=3;name=chromo<br>
# Column_5 index=4;name=length<br>
Name	Type	Aliases	chromo	length<br>
YAL068C	gene:SGD	PAU8	chr1	363<br>
</pre>

To toss out all genes that fall below 2 kb, we can use the [manipulate\_datasets.pl](Pod_manipulate_datasets.md) script. This script provides a convenient interactive mode, where you can select manipulations from a list, select the datasets (columns) from a list, and provide additional arguments. Multiple manipulations may be performed sequentially before writing the file. For this example, though, we will specify the manipulation on the command line, which is limited to only one manipulation at a time. Multiple manipulations should be done either interactively or batch scripted.
Here, we will use the toss below manipulation.
<pre>
Elessar:~ tim$ manipulate_datasets.pl --func below --index 4 --target 2000 gene_list.txt<br>
<br>
A tool for manipulating datafiles<br>
Loaded 'gene_list.txt' with 5777 data rows and 5 columns<br>
<br>
Executing automatic manipulation with function 'below'<br>
using '4' for option index<br>
using '2000' for option target<br>
4497 data lines were removed that had values below threshold in length<br>
1280 data lines are remaining<br>
1 manipulations performed<br>
Wrote datafile ./gene_list.txt<br>
</pre>
Notice that we specify the column index of 4, which is the fifth column (numbering is 0-based).

To separate the genes based on chromosome, we could use `grep`, but we would lose the metadata. We could also load the file in a competent text editor and manually select the genes, but that could be cumbersome. Another alternative is to use [split\_data\_file.pl](Pod_split_data_file.md). While this program was initially designed to split extremely large data files into smaller, manageable files, it can also come in handy here to pull out just chromosome 2 genes. To run the program, we specify the column index that will be used to split the file. Multiple files will then be written, each one containing only the genes with a specific value, in this case chromosome.
<pre>
Elessar:~ tim$ split_data_file.pl --col 3 gene_list.txt<br>
<br>
This script will split a data file<br>
<br>
Splitting file by elements in column 'chromo'...<br>
wrote 23 lines to file './gene_list#chr1.txt'<br>
wrote 97 lines to file './gene_list#chr2.txt'<br>
wrote 27 lines to file './gene_list#chr3.txt'<br>
wrote 158 lines to file './gene_list#chr4.txt'<br>
wrote 55 lines to file './gene_list#chr5.txt'<br>
wrote 27 lines to file './gene_list#chr6.txt'<br>
wrote 111 lines to file './gene_list#chr7.txt'<br>
wrote 46 lines to file './gene_list#chr8.txt'<br>
wrote 49 lines to file './gene_list#chr9.txt'<br>
wrote 89 lines to file './gene_list#chr10.txt'<br>
wrote 75 lines to file './gene_list#chr11.txt'<br>
wrote 130 lines to file './gene_list#chr12.txt'<br>
wrote 102 lines to file './gene_list#chr13.txt'<br>
wrote 77 lines to file './gene_list#chr14.txt'<br>
wrote 117 lines to file './gene_list#chr15.txt'<br>
wrote 97 lines to file './gene_list#chr16.txt'<br>
Split 'gene_list.txt' into 16 files<br>
</pre>
We now have 16 separate files. More importantly, we have one file with all of the chromosome 2 genes (97 of them). Each file also retains the metadata lines. If we ever want to merge the files back into one file, we can do that as well using the [join\_data\_file.pl](Pod_join_data_file.md) script.
<pre>
Elessar:~ tim$ join_data_file.pl gene_list#chr*.txt<br>
<br>
This script will join two or more data files<br>
<br>
Joining file 'gene_list#chr1.txt'...  23 data lines merged<br>
Joining file 'gene_list#chr10.txt'...  112 data lines merged<br>
Joining file 'gene_list#chr11.txt'...  187 data lines merged<br>
Joining file 'gene_list#chr12.txt'...  317 data lines merged<br>
Joining file 'gene_list#chr13.txt'...  419 data lines merged<br>
Joining file 'gene_list#chr14.txt'...  496 data lines merged<br>
Joining file 'gene_list#chr15.txt'...  613 data lines merged<br>
Joining file 'gene_list#chr16.txt'...  710 data lines merged<br>
Joining file 'gene_list#chr2.txt'...  807 data lines merged<br>
Joining file 'gene_list#chr3.txt'...  834 data lines merged<br>
Joining file 'gene_list#chr4.txt'...  992 data lines merged<br>
Joining file 'gene_list#chr5.txt'...  1047 data lines merged<br>
Joining file 'gene_list#chr6.txt'...  1074 data lines merged<br>
Joining file 'gene_list#chr7.txt'...  1185 data lines merged<br>
Joining file 'gene_list#chr8.txt'...  1231 data lines merged<br>
Joining file 'gene_list#chr9.txt'...  1280 data lines merged<br>
Wrote combined file './gene_list.txt'<br>
</pre>


### Collecting microarray data from the database ###
Now that we have a gene list, we're ready to collect some data. I come from an epigenetics lab, so we're interested in chromatin modifications. We want to draw a correlation between H3K4me3, a mark of transcription activation found at promoters, with H3K36me3, a mark of past transcription found in the body of the gene.

We'll use [get\_datasets.pl](Pod_get_datasets.md) script again to collect the data. The data is stored in a separate database, _sc\_public\_ma_, so we'll need to explicitly specify that; otherwise, the database listed in the metadata is used. This database contains the basic annotation (genes) as well as microarray data from [Pokholok](http://www.ncbi.nlm.nih.gov/pubmed/16122420) et al. (2005), which published genome-wide histone modifications in _S. cerevisiae_. Because this dataset was derived from a relatively small tiling microarray with only 44K probes, the data was simply converted to a GFF3 file, with a each probe as a feature and the microarray value recorded as the score, which was then loaded directly into the database. For working with higher density datasets, see below.

A note about data and **biotoolbox** scripts. I break GFF3 format convention for the datasets by using the GFF type column (column 3) as a unique identifier for datasets. Officially, only Sequence Ontology terms should be used as types, which in this case would be _microarray\_probe_. However, it is much more convenient to identify data in the database using the GFF type (and source), than the Name tag (found in column 9 of the GFF file). The Bio::DB::SeqFeature::Store API (fortunately) does not strictly check SO terms. Nevertheless, I apply the same value to both the GFF type (column 3) and Name tag (column 9) to all my data, just in case this is changed in the future.

First we'll collect the H3K4me3 data. We want to constrain the data collection to just the promoter region, say 300 bp upstream of the gene.
<pre>
Elessar:~ tim$ get_datasets.pl --db sc_public_ma --data Pokholok_H3k4me3_ChIP_44k --log --start=-300 --stop 1 --in gene_list.txt<br>
<br>
A program to collect feature data from the database<br>
<br>
Loading feature list from file 'gene_list.txt'...<br>
Collecting mean data for dataset Pokholok_H3k4me3_ChIP_44k...<br>
in 0.1 minutes<br>
wrote file './gene_list.txt'<br>
Completed in 0.1 minutes<br>
</pre>
We restrict the location to the promoter by specifying the `--start` and `--stop` options. Since the dataset is in the log2 space, I also specify the `--log` option so that the values are properly handled. Unfortunately, the log status of a dataset is not automatically determined, and you should know a priori what space the data is in, log2 or linear. The microarray probe spacing is about 250 bp for this dataset, so we should have on average of 1-2 datapoints in each window. The mean value is automatically taken here, although other methods could be applied using the `--method` option.

Now that we've collected the H3K4me3 data, we now want the H3K36me3 data. We're interested in the 3' half of the gene, but since each gene is a different size, we're unable to specify strict relative bp positions. Therefore, we use the fraction options.
<pre>
Elessar:~ tim$ get_datasets.pl --db sc_public_ma --data Pokholok_H3k36me3_ChIP_44k --log --fstart 0.5 --fstop 1 --in gene_list.txt<br>
<br>
A program to collect feature data from the database<br>
<br>
Loading feature list from file 'gene_list.txt'...<br>
Collecting mean data for dataset Pokholok_H3k36me3_ChIP_44k...<br>
in 0.1 minutes<br>
wrote file './gene_list.txt'<br>
Completed in 0.1 minutes<br>
Elessar:~ tim$ head gene_list.txt<br>
# Program /Applications/biotoolbox/scripts/get_datasets.pl<br>
# Database cerevisiae_20100109<br>
# Feature gene:SGD<br>
# Column_1 index=0;name=Name<br>
# Column_2 index=1;name=Type<br>
# Column_3 index=2;name=Aliases<br>
# Column_4 index=3;name=chromo<br>
# Column_5 index=4;name=length;tossed=4497_lines_below_threshold_2000<br>
# Column_6 dataset=Pokholok_H3k4me3_ChIP_44k;db=sc_public_ma;index=5;log2=1;method=mean;name=Pokholok_H3k4me3_ChIP_44k;start=-300;stop=1;strand=none<br>
# Column_7 dataset=Pokholok_H3k36me3_ChIP_44k;db=sc_public_ma;fstart=0.5;fstop=1;index=6;limit=1000;log2=1;method=mean;name=Pokholok_H3k36me3_ChIP_44k;strand=none<br>
</pre>

Notice that we now have two additional datasets in our file, and we have metadata lines describing where and how we obtained these datasets.

### Collecting high density data ###

When working with high density tiling microarray data (up to a few millions of probes) or next generation sequencing (many, many millions of sequence tags), storing the data in a SQL database, while possible, is inefficient. Fortunately, there are binary file formats that allow for quick, random access of the data. These include the [wig](http://genome.ucsc.edu/goldenPath/help/wiggle.html) file (for dense quantative data) and [Bam](http://samtools.sourceforge.net/) file (for short sequence alignments). Furthermore, there are improved binary versions of the wig and bed file, the [bigWig](http://genome.ucsc.edu/goldenPath/help/bigWig.html) and [bigBed](http://genome.ucsc.edu/goldenPath/help/bigBed.html) file formats.

Fortunately, there are Perl modules which can read and process these file formats, notably [Bio-SamTools](http://search.cpan.org/search?query=samtools&mode=dist) and [Bio-BigFile](http://search.cpan.org/search?query=bigfile&mode=dist). These are also used by GBrowse for visualization of the data across the genome.

The **biotoolbox** data collection scripts can collect data and other values from these files. The files can be referenced in one of two ways.
First, a simple GFF3 file may be generated using the script [big\_file2gff3.pl](Pod_big_file2gff3.md) that references the location of the file. This can then be loaded into the database.
Second, the file may be directly referenced with a command line option when executing the data collection script.
<pre>
Elessar:~ tim$ get_datasets.pl --db sc_public_ma --data path/to/my/data.bam --log --start=-300 --stop 1 --in gene_list.txt<br>
<br>
A program to collect feature data from the database<br>
<br>
Loading feature list from file 'gene_list.txt'...<br>
Collecting mean data for dataset file:path/to/my/data.bam...<br>
in 0.1 minutes<br>
wrote file './gene_list.txt'<br>
Completed in 0.1 minutes<br>
</pre>
This is a convenient method for quickly analyzing your data without having to load it into a database first.

There are also numerous **biotoolbox** scripts for converting and manipulating these data formats.

### Visualizing the data ###
We first want to check some basic statistics on our datasets. We can use the [manipulate\_datasets.pl](Pod_manipulate_datasets.md) script to do this.
<pre>
Elessar:~ tim$ manipulate_datasets.pl --func stat --index 6 gene_list.txt<br>
<br>
A tool for manipulating datafiles<br>
Loaded 'gene_list.txt' with 1280 data rows and 7 columns<br>
<br>
Executing automatic manipulation with function 'stat'<br>
using '6' for option index<br>
Statistics for dataset index '6'<br>
Dataset name is 'Pokholok_H3k36me3_ChIP_44k'<br>
'fstart' is '0.5'<br>
'db' is 'sc_public_ma'<br>
'dataset' is 'Pokholok_H3k36me3_ChIP_44k'<br>
'log2' is '1'<br>
'fstop' is '1'<br>
'strand' is 'none'<br>
'limit' is '1000'<br>
'method' is 'mean'<br>
Count is 1262<br>
Mean is 0.725<br>
Median is 0.771<br>
Standard deviation is 0.566<br>
Min is -1.605<br>
Max is 2.672<br>
Mode is 1.344<br>
Sum is 915.577<br>
No changes written<br>
</pre>


Next we want a simple histogram plot of the distribution. We can use the script [graph\_histogram.pl](Pod_graph_histogram.md) to do this. We see from the statistics above that the data ranges from -1.6 to 2.7. So let's create a histogram from -3 to 3, in 0.2 increments. This would be 30 bins with a bin size of 0.2.
<pre>
Elessar:~ tim$ graph_histogram.pl --bins 30 --size 0.2 --col 6 --min=-3 gene_list.txt<br>
<br>
This script will plot histograms of value frequencies<br>
<br>
Loading data from file gene_list.txt....<br>
Preparing graph for Pokholok_H3k36me3_ChIP_44k....<br>
wrote bar graph distribution_Pokholok_H3k36me3_ChIP_44k.png in directory gene_list_graphs<br>
Finished!<br>
</pre>

Here, we specified the number of bins (30), the bin size (0.2), the starting or minimum bin value (-3), and the dataset index. The script will also allow for datasets to be selected from a list interactively if it's not provided as a command line argument. The output graphic file is written in a subdirectory named after the input file.

Finally, we want to show the correlation between the two datasets. For this we use another script, [graph\_data.pl](Pod_graph_data.md), which plots a pairwise XY plot between two datasets.
<pre>
Elessar:~ tim$ graph_data.pl --type scatter --pair 5,6 --min=-3 --max=3 --in gene_list.txt<br>
<br>
This script will graph correlation plots for two microarry data sets<br>
<br>
Loading data from file gene_list.txt....<br>
Preparing graph for Pokholok_H3k4me3_ChIP_44k vs. Pokholok_H3k36me3_ChIP_44k....<br>
Pearson correlation is 0.59, R^2 is 0.34<br>
</pre>

Here, we specify a scatter plot between datasets 5 and 6, with a mininum and a maximum value of -3 and 3, respectively. Simple correlation stats are printed as output in the terminal (r = 0.59, moderately correlated), in the graphic title, and in a text file in the output graph subdirectory.

While these graphs are not exactly publication quality, they are certainly good enough for lab meeting presentations and interpreting data.



