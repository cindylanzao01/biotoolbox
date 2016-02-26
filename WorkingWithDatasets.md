# HOWTO: Working with dataset files #
The **BioToolBox** scripts are designed to work with a variety of data file formats for collecting data associated with a list of sequence features: genes, transcripts, promoters, etc. See the [Working with Databases](WorkingWithDatabases.md) document for more information on obtaining lists of sequence features to work with. Using this list, we are able to collect genomic data for each item in the list, be it expression data (RNA), factor occupancy data (ChIP), or even the number of discrete features (e.g. predicted binding sites).

This HowTo describes some possible scenarios for collecting data and working with the data afterwards.

## Contents ##
  1. [Data File Formats](WorkingWithDatasets#Data_File_Formats.md)
    1. [Single File Formats](WorkingWithDatasets#Single_File_Formats.md)
    1. [Database Scores](WorkingWithDatasets#Database_Scores.md)
    1. [Directory of BigWig Files](WorkingWithDatasets#Directory_of_Bigwig_Files.md)
  1. [Collecting Scores](WorkingWithDatasets#Collecting_Scores.md)
    1. [Collecting Single Scores](WorkingWithDatasets#Collecting_Single_Scores.md)
    1. [Collecting Class Averages](WorkingWithDatasets#Collecting_Class_Averages.md)
      1. [Averaging Over Features](WorkingWithDatasets#Averaging_Over_Features.md)
      1. [Averaging Around A Specific Point](WorkingWithDatasets#Averaging_Around_A_Specific_Point.md)
  1. [Graphing Data](WorkingWithDatasets#Graphing_data.md)
    1. [Comparing Two Datasets with XY Plot](WorkingWithDatasets#Comparing_Two_Datasets_With_XY_Plot.md)
    1. [Graphing A Profile](WorkingWithDatasets#Graphing_A_Profile.md)
    1. [Plotting A Histogram](WorkingWithDatasets#Plotting_A_Histogram.md)
  1. [Manipulating Datasets](WorkingWithDatasets#Manipulating_Datasets.md)
    1. [Merging Files](WorkingWithDatasets#Merging_Files.md)
    1. [Splitting and joining files](WorkingWithDatasets#Splitting_and_joining_files.md)
    1. [Selecting Specific Rows](WorkingWithDatasets#Selecting_Specific_Rows.md)
  1. [Generating Clusters](WorkingWithDatasets#Generating_Clusters.md)

## Data File Formats ##
The **BioToolBox** programs can work with a number of common data file formats representing scores or other genomic data from microarray or next generation sequencing. These include the following
  * Wig
  * BigWig
  * Bed
  * BigBed
  * Bam
  * USeq
  * GFF

For a more detailed look at these file types, including what they represent, how they can be used, and how to generate them, please refer to the [Data File Formats](DataFileFormats.md) document.

### Single File Formats ###
Some file formats are self-contained, indexed formats that can be accessed directly and randomly without a time consuming parsing through the file contents. These include
  * BigWig
  * BigBed
  * Bam
  * USeq

By virtue of being indexed, scores may be collected quickly at any point in the genome. This makes data collection simple, as the file may be directly specified on the command line of the data collection program, usually using the `--data` option.

### Database Scores ###
When the data is not in an indexed format, such as GFF or BED, then it must be integrated into a database, such that it may be accessed randomly. Usually, this is a BioPerl formatted database, such as the [Bio::DB::SeqFeature::Store](http://bioperl.org/wiki/Module:Bio::DB::SeqFeature::Store) schema. Each feature recorded in the database may have a score associated with, and these scores are used in the data collection.

It is also possible to associate an indexed or binary data file with a chromosome-length feature in the database. Usually the path to the file is recorded in the feature's attribute. This is the method employed by the [Bio::Graphics::Wiggle](http://search.cpan.org/dist/Bio-Graphics/) module for wig file support. Here, a text-based wig file is converted to a binary `*.wib` file using [wiggle2gff3.pl](http://search.cpan.org/perldoc?wiggle2gff3.pl) and the resulting GFF3 file is loaded into the database. **BioToolBox** scripts also supports BigWig and Bam files in this manner, although direct file access is simpler and faster.

In **BioToolBox** scripts the database is specified using the `--db` or `--ddb` options. The difference between these options is whether genomic annotation (the list of features against which we are collecting data) is present in the same database as the data to be collected (use the single `--db` option) or in separate databases (use `--db` for annotation database, and `--ddb` for the data database).

The advantage of storing dataset scores in a relational database is that many different scores from different sources may be stored in a single database. Usually different datasets are identified through the use of the GFF3 `type` and `source` attributes (GFF3 columns 3 and 2 respectively). In **BioToolBox** scripts, the specific dataset may be identified on the command line (using the `--data` option) or selected from a list interactively.

### Directory of Bigwig Files ###
One of the advantages of databases is storing multiple datasets within them, or assigning metadata, such as strand, to datasets. We can accomplish similar goals with a directory of multiple BigWig files, whereupon it is referred to as a BigWigSet. The metadata may be assigned using a special INI-style `metadata.index` file in the directory along with the BigWig files. Here, we can take advantage of interactively choosing just the few datasets (BigWig files) amongst an entire directory of files. We can also collect stranded data, since BigWig files do not inherently support stranded information.

To work with a BigWigSet, specify the directory using the `--ddb` option. More information can be found in the documentation for [Bio::DB::BigWigSet](http://search.cpan.org/perldoc?Bio%3A%3ADB%3A%3ABigWigSet).

## Collecting Scores ##
There are three primary **BioToolBox** scripts for collecting scores:
  * [get\_datasets.pl](Pod_get_datasets.md)
  * [average\_gene.pl](Pod_average_gene.md)
  * [get\_relative\_data.pl](Pod_get_relative_data.md)
These are detailed below.

When running **BioToolBox** scripts, executing the script without any options will present a list of available options. Detailed help may be obtained from the command line using the `--help` option (same as the wikis here).

In general, three primary options are required.
  1. An input file containing a list of features or intervals for which to collect the scores. In some cases, the script may generate this list for you. See [Working with Databases](WorkingWithDatabases.md) for more information on generating lists. It is specified using the `--in` option, or simply appended to the end of the command.
  1. A database that contains the features and/or the dataset scores. In some cases, this may not be required. For example, collecting scores from a single indexed file (BigWig) using a BED file of interval coordinates as input. Note that two databases may be specified, if required, using the `--db` and `--ddb` options.
  1. The dataset(s) from which to collect the scores. In some cases this may be optional, triggering the script to enter an interactive mode whereupon the feature types available in the database are presented to the user as a list from which to select. For single, indexed files (e.g. BigWig), the path to the file may be provided.

Additionally, two other options control how and what is collected.
  1. The statistical method for combining scores into a single value is controlled by the `--method` option. The default is to simply take the mean value.
  1. The type of score or value that is collected may also be controlled. Typically, the `score` is collected. However, when collecting information regarding annotation (e.g. putative binding sites in the genomic sequence), then two other values may be collected: `count` or `length`. These values are also subject to the `--method` option.

As of **BioToolBox** version 1.12, these scripts are now multi-core enabled, allowing for increased performance on modern machines.

### Collecting Single Scores ###
A single score may be collected for each feature or genomic interval using the [get\_datasets.pl](Pod_get_datasets.md) script. Typically scores are collected across the entire feature or interval and then combined statistically. For example, to collect the mean enrichment score from a BigWig file for a series of intervals
<pre>
get_datasets.pl --data path/to/Enrichment.bw --method mean --in my_regions.bed<br>
</pre>

Through the use of options, we can adjust where we collect the scores. For example, to collect in the 500 bp region upstream of each interval
<pre>
get_datasets.pl --data path/to/Enrichment.bw --method mean --start=-500 \<br>
--stop=-1 --in my_regions.bed<br>
</pre>
If the input Bed file is a BED6 format file complete with strand information, then the orientation is taken into consideration when collecting the upstream data.

If we wish to collect stranded RNASeq transcription data for genes, then we might use a Bam file and an annotation database. Here we will let the script collect the list of genes for us, in this case genes from UCSC.
<pre>
get_datasets.pl --db annotation --feature gene:UCSC --data path/to/RNASeq.bam \<br>
--method rpkm --strand sense --out my_expression_data<br>
</pre>
This will collect coverage over each exon and normalize to length and sequence depth.

If we have a list of putative transcription factor binding sites in a BigBed file (perhaps identified using the [EMBOSS profit](http://emboss.sourceforge.net/apps/cvs/emboss/apps/profit.html) utility), then we can count their occurrence in the promoter. First, we can collect unique promoter regions following this [example](WorkingWithDatabases#Getting_nonannotated_regions.md).
<pre>
get_datasets.pl --data path/to/binding_sites.bb --method sum --value count \<br>
-in promoters.txt<br>
</pre>

The get\_datasets.pl script may also collect multiple datasets at a time. Provide a comma delimited list to the `--data` option, or provide multiple `--data` options, and each dataset will be appended as a new column to the output file.

### Collecting Class Averages ###
We can collect a profile of scores across the length of a feature or interval. For a list of features or intervals, we can average these profiles into a class average profile. This allows one to determine what the typical distribution or profile of scores looks like.

There are two types of profiles that may be collected. The first is to collect scores in percentile bins across the length of the feature. The second is to collect scores in set bins flanking a specific point, usually the start, mid, or end point of a feature, e.g. the Transcription Start Site (TSS). In both cases, we must provide additional information to the program regarding the number and/or size of the bins.

Unlike the get\_datasets.pl script, these scripts only take a single dataset at a time.

Both programs will output two files. The first data file is the collected scores in each bin across the feature for the entire list of input features. The second data file is a summary profile, or the mean score for each bin across the entire list of features. This summary file is transposed, such that the bins becomes rows and the dataset becomes a single column. The reasoning behind this is that we can combine the profiles from multiple datasets into a single file for generating graphs with overlapping plots. See [Graphing A Profile](WorkingWithDatasets#Graphing_A_Profile.md) below for how to do this.

### Averaging Over Features ###
The [average\_gene.pl](Pod_average_gene.md) script will collect data in percentile bins across the length of the feature. For example, to collect normalized RNASeq read counts across a gene in 10 percentile bins (each corresponding to 10% of the length of the feature), run
<pre>
average_gene.pl --db annotation --feature gene:UCSC --data path/to/RNASeq.bam \<br>
--method rpm --strand sense --out my_average_gene_profile<br>
</pre>

For a list features with variable lengths, e.g. genes, each bin will be a different size, as it is based on a percentage of the length. A minimum size may be imposed before dividing into bins if this is a concern.

We may also extend the bins beyond the borders of the feature, if desired. These may also be based on the percentage length, or set at a specific length. This example will extend two additional bins of 100 bp.
<pre>
average_gene.pl --db annotation --feature gene:UCSC --data path/to/RNASeq.bam \<br>
--method rpm --strand sense --ext 2 --extsize 100 --out my_average_gene_profile<br>
</pre>

### Averaging Around A Specific Point ###
The [get\_relative\_data.pl](Pod_get_relative_data.md) script will also collect scores in bins, but centered around a specific point. Hence, all scores are relative to this reference point. Common applications include collecting histone modification data around a Transcription Start Site of a gene. Here, we provide the number of windows to collect and the size of each window in bp. Note that these numbers are essentially the radius, and that twice the number of bins are collected, both upstream and downstream of the reference point. As with the other scripts, strand is always considered when calculating upstream and downstream points.

To collect enrichment data in a radius of 1 kb in 10 bins relative to the transcription start site, we can run
<pre>
get_relative_data.pl --db annotation --feature gene:SGD --data path/to/ChIP.bw \<br>
--num 10 --win 100 --pos 5 --out my_tss_profile<br>
</pre>

Sometimes we want to avoid interference from neighboring genes. For example, the yeast genome is extremely compact, with intergenic distances commonly only a few hundred basepairs. In this case, in our example above, we would collect data overlapping neighboring genes. We can avoid collecting this overlapping data by adding the `--avoid` option, which ensures that neighboring features are avoided. Note that this only works when collecting data for features in a database, where other neighboring features may be queried; it does not work with input files using genomic coordinates, e.g. BED files.

## Graphing Data ##
We can graph the data we just collected for visual inspection. These are simple graphs, suitable for getting a quick answer or for a lab meeting, but not really for publication.

There are three types of graphs that may be generated.
  1. XY plots (line or dot) between two samples
  1. Profile plots along a linear (gene) scale
  1. Histogram plots of counts or frequencies

Each program takes an input file of data. It will generate a PNG file (800x600 pixels) in a new directory named after the basename of the input file. Each PNG file is named after the dataset (column) name or names. You may specify the datasets on the command line or in an interactive mode where the datasets (column) names are presented as a list to the user. Each program has a number of command line options for adjusting axes parameters.

### Comparing Two Datasets with XY Plot ###
Two datasets can be compared to each other by generating a XY plot using the [graph\_data.pl](Pod_graph_data.md) script. Three types of plots may be made:
  1. A scatter plot with a linear regression line
  1. A line plot
  1. A smoothened (bezier curve) line plot

Only those points with both a valid X and Y value are plotted. Pairs may be identified on the command line using the `--pair` or `--index` options, selected interactively from a list, or all available combinations may be graphed automatically using the `--all` option. For example
<pre>
graph_datasets.pl --pair 3,4 --pair 3,5 --type scatter --in my_datasets.txt<br>
<br>
graph_datasets.pl --index "3&4,3&5" --type scatter --in my_datasets.txt<br>
<br>
graph_datasets.pl --all --type scatter --in my_datasets.txt<br>
</pre>

When drawing a line plot with noisy datasets, the data may be smoothed using a moving average along the Y axis. The window and step sizes must be defined; usually a step size half of the window size, e.g. window 20, step 10, works well.
<pre>
graph_datasets.pl --pair 3,4 --ma 20,10 --type line --in my_datasets.txt<br>
</pre>

For datasets with dissimilar dynamic range, the values in each dataset may be converted to percentile rank (range 0..1) using the `--norm` option.

Some statistics, including the linear regression correlation and R squared values, are printed in a text file written to the output directory.

### Graphing A Profile ###
When relative data was collected using the [get\_relative\_data.pl](Pod_get_relative_data.md) or [average\_gene.pl](Pod_average_gene.md) scripts, the summary file may be plotted as a class average profile using the [graph\_profile.pl](Pod_graph_profile.md) script. This plots a smoothened line of Y values against a constant X axis representing a linear or gene coordinates, for example the distance, plus and minus, from the reference point.

One or more datasets may be plotted on the same graph, in different colors. For example, to plot the profiles of indexes 3 and 4 separately and together, with Y axis minimum and maximum values of 0 to 5, respectively, run the following
<pre>
graph_profile.pl --index "3,4,3&4" --min=0 --max=5 --in my_summaries.txt<br>
</pre>
The program will try to automatically pick an appropriate Y axis minimum and maximum, but in many cases, specifying exact values works best.

The X axis column should be automatically determined, especially with summary files generated as above, but it may also be explicitly defined.

### Plotting A Histogram ###
Sometimes the distribution of values in a dataset is desired, displayed as a histogram of counts in specific bins. To quickly generate these distributions, the [graph\_histogram.pl](Pod_graph_histogram.md) script works well. Here, the number of bins, size of each bin, and optionally the starting (minimum) and/or stopping (maximum) values for the bins are specified on the command line.

For example, perhaps we have counted binding sites in the promoters of genes, and now we want a distribution of those counts. We will count in integers from 0 to 5.
<pre>
graph_histogram.pl --min=0 --max=5 --size=1 --index 3 --in my_tfbs_counts.txt<br>
</pre>

A vertical bar graph is generated. Optionally, a line graph may be generated using the `--lines` option. More than one dataset column may be plotted in the same graph, using different colors.

If a histogram is desired but you wish to use a separate graphing program, then you can use the [data2frequency.pl](Pod_data2frequency.md) script, which will generate a simple table of the frequencies or counts in each bin.

## Manipulating Datasets ##
Once you have collected your datasets, you may reach a point where you wish to manipulate the values in the file. These manipulations could include
  * delete or reorder columns
  * perform simple mathematical or statistical data transformations
  * combine columns using mathematical or statistical methods
  * delete rows that match certain value criteria
  * export into another format

While the [BioToolBox Data Format](TimDataFormat.md) generated by these scripts is a simple tab-delimited text format (with column headers and metadata comment lines at the top) that could be opened in a text editor or spreadsheet program, sometimes it is more convenient to quickly make manipulations on the command line. In this case, the [manipulate\_datasets.pl](Pod_manipulate_datasets.md) script will work for you.

The script is designed to work in two modes. The first, and most convenient, is a menu-driven interactive mode, where functions may be selected by key and indices chosen from a list. Multiple manipulations may be performed in this manner before writing the file.
<pre>
manipulate_datasets.pl my_datasets.txt<br>
</pre>

The second mode is command line driven, where a single function may be specified through options. Multiple, sequential functions may only be performed by repeated execution on the same file. Here are three manipulations: deleting a column, generating a ratio (index 3 / index 4), and summing the values in columns 3 through 8, inclusive.
<pre>
manipulate_datasets.pl --func delete --index 3 my_datasets.txt<br>
<br>
manipulate_datasets.pl --func ratio --exp 3 --con 4 --in my_datasets.txt<br>
<br>
manipulate_datasets.pl --func combine --index 3-8 --target sum --in my_datasets.txt<br>
</pre>

In addition to these functions, we can perform other manipulations with other scripts.

### Merging Files ###
We can merge the columns between two or more data files, perhaps so that we can perform other manipulations, or graph datasets together, by using the [merge\_datasets.pl](Pod_merge_datasets.md) script.

To automatically merge unique datasets between files, use the `--auto` option.
<pre>
merge_datasets.pl --auto --out merged_1_2.txt data1.txt data2.txt<br>
</pre>
Otherwise, the program will ask interactively which columns to merge.

When the files do not have the same number of rows then a lookup function is automatically invoked. One column in each file must contain the unique identifiers to look up the rows when merging the columns. This may also be enabled using the `--lookup` option when you know the rows are not sorted in the same manner. The lookup column name may be automatically determined, chosen interactively, or specified on the command line.

### Splitting and joining files ###
Occasionally one needs to split the files by some attribute, for example by chromosome, where each split file contains rows with a specific attribute. Column headers and metadata are preserved across all the files. Use the [split\_data\_file.pl](Pod_split_data_file.md) to split the file. You will need to specify the column index containing the attribute on which to split the file, either on the command line or interactively.
<pre>
split_data_file.pl --index 0 my_data.txt<br>
</pre>

The split file names will be appended with the attribute value.

The reverse function can be accomplished using the [join\_data\_file.pl](Pod_join_data_file.md) script to merge the split files into one file. Note that this concatenates files by row (appropriately dealing with column headers and metadata), whereas the [merge\_datasets.pl](Pod_merge_datasets.md) script will merge columns. You may glob the input files using a wild card character.
<pre>
join_data_file.pl --out joined_data_file data_file*.txt<br>
</pre>
If you are are joining files that were previously split using split\_data\_file.pl, then the original filename should be recreated.

### Selecting Specific Rows ###
Sometimes we want to pull out specific rows or features from a data file using a list. For example, we collected relative data around a TSS for all genes in the genome. We clustered these data using a k-means cluster algorithm (see [Generating Clusters](WorkingWithDatasets#Generating_Clusters.md)). Now we wish to pull out the data rows corresponding to those specific clusters. We can use the [pull\_features.pl](Pod_pull_features.md) script to do this.

Like the lookup function of the [merge\_datasets.pl](Pod_merge_datasets.md) script, this relies on a unique identifier column in the table, and a second, simple text file containing the list of the desired identifying values. A `.kgg` file from Cluster will suffice. The identifier columns may be automatically determined, or they can be chosen interactively.
<pre>
pull_features.pl --data my_TSS_data.txt --list TSS_cluster_K_G6.kgg --out pulled_data.txt<br>
</pre>
With a KGG file, all clusters are written to separate files, with the output name appended with the cluster number.

This program will optionally generate a new summary file for the pulled rows, just as with [get\_relative\_data.pl](Pod_get_relative_data.md) or [average\_gene.pl](Pod_average_gene.md) scripts. In this case, specify the starting and ending indices for the data columns to be summarized (these may be automatically determined).
<pre>
pull_features.pl --data my_TSS_data.txt --list TSS_cluster_K_G6.kgg --out \<br>
pulled_data.txt --sum --starti 3<br>
</pre>

## Generating Clusters ##
One common method of high level analysis is to generate a k-means cluster of the data. For this we are using the same algorithm as the [Cluster3 program](http://bonsai.hgc.jp/~mdehoon/software/cluster/) using a Perl wrapper script, [run\_cluster.pl](Pod_run_cluster.md).

This clustering algorithm requires a tab delimited text file, with one column of unique identifiers, two or more data columns, and a column header line. Extraneous columns, lines, and metadata lines are not allowed. The file is checked before passing it to the algorithm. The easiest way to dealing with this is to use the [manipulate\_datasets.pl](Pod_manipulate_datasets.md) script and export your data file as a Cluster Data file (`.cdt`).
<pre>
manipulate_datasets.pl --func treeview --index 0,3-82 --target n0,cg \<br>
--in my_TSS_data.txt<br>
</pre>

A unique identifier column and a range of data columns is provided as the index. Some simple manipulations may be performed prior to exporting, which can be defined using special codes with the `--target` option (see the help document). The manipulations specified above is to convert nulls to 0.0 (`n0`, helpful in clustering) and median center the genes or rows (`cg`, aids in visualizing differences). These manipulations could also be done interactively, allowing you more control in preparing the data for cluster analysis.

When you have a prepared data file, you can run cluster. The number of clusters must be specified. There is no magic number; rather, I will repeat the clustering to find the optimum number of interesting looking clusters. Usually between 2 and 10 is ideal. It is fun to watch the progression as clusters are split into new ones, often revealing important distinguishing groups. Too many clusters may yield redundancy and diminishing information content.

The cluster algorithm splits the features randomly and calculates the optimum correlation between the groups using the indicated method. This process is repeated a set number of times, and the number of optimum solutions is reported. With very clean data, an optimal solution may be found many times in only a few hundred iterations. With noisy data, an optimal solution may not be found until thousands of iterations have been performed. Usually whatever is found after a thousand iterations is sufficient. This process is time-consuming; if you have several clusterings to perform (perhaps with different cluster numbers), run them in parallel to save time.

Here is an example running with 6 clusters and 1000 iterations.
<pre>
run_cluster.pl --num 6 --run 1000 my_TSS_data.cdt<br>
</pre>

Once you have your cluster file (`my_TSS_data_K_G6.cdt` and `my_TSS_data_K_G6.kgg` from the example above), you may view the clustering using the [Java TreeView](http://jtreeview.sourceforge.net) program. This is a graphical Java program that will read `.cdt` files. It can export the visualizations as graphic file.