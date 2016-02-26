# HOWTO: Working with an annotation database #
The **BioToolBox** scripts are designed to work with annotation from a relational database. This is designed to simplify data collection by not having to maintain separate annotation files, e.g. Bed files, for every gene, transcript, promoter, and everything else you're possibly interested in. Keeping those files properly annotated, labeled, and up-to-date with the latest genome version can be difficult.

Instead, the **BioToolBox** scripts allow you to collect a list of gene names and identifiers from the database, and use those in data collection, without regard to maintaining chromosome, start, stop, strand coordinates, especially between genome builds. The scripts automatically look up the gene names in the database and grab the coordinates for you behind the scenes prior to data collection.

This HowTo describes some possible scenarios with working with databases.

## Contents ##
  1. [Fast and easy database setup](WorkingWithDatabases#Fast_and_easy_database_setup.md)
  1. [Annotation](WorkingWithDatabases#Annotation.md)
    1. [Obtaining Annotation](WorkingWithDatabases#Obtaining_Annotation.md)
      1. [Annotation from UCSC](WorkingWithDatabases#Annotation_from_UCSC.md)
      1. [Annotation from Ensembl](WorkingWithDatabases#Annotation_from_Ensembl.md)
    1. [Sequence information](WorkingWithDatabases#Sequence_information.md)
    1. [Database setup](WorkingWithDatabases#Database_setup.md)
    1. [Loading the database](WorkingWithDatabases#Loading_the_database.md)
  1. [Specifying and using a database](WorkingWithDatabases#Specifying_and_using_a_database.md)
  1. [Getting a gene list](WorkingWithDatabases#Getting_a_gene_list.md)
  1. [Getting more from the database](WorkingWithDatabases#Getting_more_from_the_database.md)
    1. [Additional information](WorkingWithDatabases#Additional_information.md)
    1. [Getting nonannotated regions](WorkingWithDatabases#Getting_nonannotated_regions.md)
    1. [Collecting sequences](WorkingWithDatabases#Collecting_sequences.md)
    1. [Calculating CpG frequency](WorkingWithDatabases#Calculating_CpG_frequency.md)

## Fast and easy database setup ##
By far, the fastest, simplest, and easiest way to set up an annotation database is to run the **BioToolBox** script [db\_setup.pl](Pod_db_setup.md). This script uses annotation from the UCSC Genome website, converts it to GFF3 format, fast loads a Bio::DB::SeqFeature::Store database using the SQLite engine, and appends the database information to the BioToolBox configuration file, `.biotoolbox.cfg`. For example, to load human genome annotation, run this command
<pre>
db_setup.pl --db hg19<br>
</pre>

For custom annotation or database configuration (e.g. custom annotation or using the MySQL engine), continue reading below on how to do this manually.

To work with your database, jump to [Getting a gene list](WorkingWithDatabases#Getting_a_gene_list.md) or [Getting more from the database](WorkingWithDatabases#Getting_more_from_the_database.md).

## Annotation ##
The **BioToolBox** scripts work primarily with the BioPerl [Bio::DB::SeqFeature::Store](http://bioperl.org/wiki/Module:Bio::DB::SeqFeature::Store) schema, which was designed to use primarily annotation in the GFF3 format.

### Obtaining Annotation ###
The most important component of the database is the annotation. The annotation should be obtained from an official organism genome repository online, such as [SGD](http://www.yeastgenome.org/) or [FlyBase](http://flybase.org/), a general genomics repository such as [UCSC](http://genome.ucsc.edu/) or [Ensembl](http://www.ensembl.org), or one you've [annotated](http://gmod.org/wiki/MAKER) yourself.

Ideally, the annotation should be provided in GFF3 format, making loading in the database simple. For example, SGD provides the yeast genome in GFF3 files. Unfortunately, this isn't always the case, as annotation can come in many different flavors.

BioPerl includes some converters. For example, there is a converter for the NCBI GenBank format, `genbank2gff3.pl`. For files in GTF format (a variation of GFF v.2), there is a GTF to GFF3 [converter](http://www.sequenceontology.org/cgi-bin/converter.cgi) available.

### Annotation from UCSC ###
Annotation may be downloaded from the UCSC Table Browser in a simple tab-delimited gene table format. It's also possible to download as a GTF, but it is not compatible with the above GTF converter.

The GBrowse distribution provides a script, ucsc\_genes2gff.pl, which will convert the gene table. However, it produces fairly simple annotation, and in my experience has some issues. The Chado distribution also includes a different [ucsc\_genes2gff.pl](http://gmod.svn.sourceforge.net/viewvc/gmod/schema/trunk/chado/bin/ucsc_genes2gff.pl?revision=21190&view=markup) script, which, although I have not used it, appears to produce more complete GFF3 features.

The **BioToolBox** collection also includes a UCSC gene table to GFF3 converter script, [ucsc\_table2gff3.pl](Pod_ucsc_table2gff3.md). It will conveniently download the appropriate gene tables and supporting tables via FTP and generate much more complete GFF3 files than the above programs. It works well with the refGene, ensGene, knownGene, and xenoRefGene tables.

To download the refGene and ensGene annotation files from UCSC for the zebrafish genome, execute this command. You will need to first identify the genome version name from their list of official [releases](http://genome.ucsc.edu/FAQ/FAQreleases.html).
<pre>
biotoolbox/scripts/ucsc_table2gff3.pl --ftp refGene,ensGene --db danRer7<br>
</pre>

This will fetch the relevant annotation tables from their FTP server and process them into GFF3 files. You should result in three files:
<pre>
danRer7_refGene.gff3<br>
danRer7_ensGene.gff3<br>
danRer7_chromo.gff3<br>
</pre>

### Annotation from Ensembl ###
Ensembl conveniently provides GTF files for their annotated genomes. However, the information content is limited in the GTF file. Nevertheless, it is compatible with the above GTF to GFF3 converter.

To obtain more complete annotation, however, use the **BioToolBox** script, [get\_ensembl\_annotation.pl](Pod_get_ensembl_annotation.md), which connects directly to the Ensembl public database and downloads the annotation, converting it to a GFF3 file. The information content is more complete compared to that provided in the GTF.

You must have the latest  [Ensembl Perl modules installed](BioToolBoxSetUp#Installing_the_Ensembl_Perl_API.md) to use this script. To run this script for zebrafish, execute the following command.
<pre>
biotoolbox/scripts/get_ensembl_annotation.pl --species danio_rerio<br>
</pre>

You should get out one file: `danio_rerio.gff3`.

### Sequence information ###
You need to generate a GFF3 file representing the chromosomes, contigs, and/or scaffolds for your genome. Each of the above **BioToolBox** scripts above will default to downloading sequence information, either as a separate file or embedded in the GFF3 file. Each sequence must have a line similar to this.
<pre>
chr1	UCSC	chromosome	1	60348388	.	.	.	Name=chr1;ID=chr1<br>
</pre>

**CAUTION** Each genome repository may use different naming schemes. For example, UCSC prefixes chromosome names with `chr`, while Ensembl does not. Beware of these naming conventions and adjust accordingly, especially when mixing annotation from different repositories! The [get\_ensembl\_annotation.pl](Pod_get_ensembl_annotation.md) script has an option to prefix chromosome names like UCSC.

Also, make sure you have only one reference per database for each sequence. Funny things may happen if you load `chr1` more than once.

While it is not required, a fasta file of the genomic sequence is helpful. You may use
individual files or a single multi-fasta file.

### Database setup ###
The database may be loaded into one of three relational database systems: MySQL, PostGresSQL, or SQLite. MySQL appears to be the most commonly used. Both MySQL and PostGresSQL provide a robust multi-user resouce, but requires installation of the server. SQLite, in contrast, requires minimal resources and is suitable for single workstations.

You may have to install the database server and necessary Perl modules for your system. When in doubt, the SQLite system is the simplest choice.

Relational database servers such as MySQL use users and passwords to control access to their contents. The `root` or other priveleged user is required to load the database. At minimal the following permissions are required: `select, insert, update, delete, create, drop, alter`. For querying content, as with all of the **BioToolBox** scripts, we only need a read-only account (`select` permission).

For a MySQL database, the following example session shows creating a new database `zv9`, adjusting permissions, and creating a read-only account (user nobody, password hello).
<pre>
admin@gbrowse-vm:~$ mysql -u root -p<br>
Enter password: gbrowse<br>
<br>
mysql> create database zv9;<br>
Query OK, 1 row affected (0.00 sec)<br>
<br>
mysql> show databases;<br>
+--------------------+<br>
| Database           |<br>
+--------------------+<br>
| information_schema |<br>
| mysql              |<br>
| performance_schema |<br>
| test               |<br>
| zv9                |<br>
+--------------------+<br>
5 rows in set (0.01 sec)<br>
<br>
mysql> grant all privileges on zv9.* to 'admin'@'localhost';<br>
Query OK, 0 rows affected (0.00 sec)<br>
<br>
mysql> create user 'nobody'@'localhost' identified by 'hello';<br>
Query OK, 0 rows affected (0.00 sec)<br>
<br>
mysql> grant select on zv9.* to 'nobody'@'localhost';<br>
Query OK, 0 rows affected (0.00 sec)<br>
<br>
mysql> quit;<br>
Bye<br>
admin@gbrowse-vm:~$<br>
</pre>

See the documentation for your database server for more details.

**IMPORTANT** For BioToolBox scripts, you must enter the read-only user name and password in the `.biotoolbox.cfg` configuration file. Since this is a plain text file, a read-only user account would be critical here.

### Loading the database ###
The SQL database may then be loaded using the BioPerl provided script, [bp\_seqfeature\_load.pl](http://search.cpan.org/perldoc?bp_seqfeature_load.pl). A typical command for loading a MySQL database with zv9 annotation would look like this
<pre>
bp_seqfeature_load.pl -c -f -d zv9 -u admin -p password danRer7_refGene.gff3 ...<br>
</pre>

Provide as many input annotation and sequence files as you would like. The only requirement is that the GFF3 file with the reference sequences should be listed and loaded first. Note that you must enter the password on the command line; you may wish to use a priveleged user rather than `root` if you're concerned with security.

A typical command for loading a SQLite database would look like this
<pre>
bp_seqfeature_load.pl -c -f -a DBI::SQLite -d ./zv9.sqlite danRer7_refGene.gff3 ...<br>
</pre>

Note that the dsn option is the name of the SQLite file, and that a user and password are not necessary.

Both commands above use the `-f` or fast loading option to increase loading time. This will dramatically decrease loading time, sometimes by orders of magnitude for extremely large datasets. For hierarchical gene annotation, this presumes parent and child features are clustered within the file; otherwise, this trick won't work.

After loading the database, you may check the contents with the **BioToolBox** script [print\_features.pl](Pod_print_features.md).
<pre>
biotoolbox/scripts/print_features.pl zv9<br>
</pre>

This should generate a list of feature types sorted by their source tags printed to standard out.

## Specifying and using a database ##

In many of the **BioToolBox** scripts, an annotation database is used to retrieve gene or feature information. Typically, the name of the database is specified using the `--db` option. Here, the value can be one of several things.
  1. The name of a database in the `.biotoolbox.cfg` configuration file. This file is typically located in your home folder, and includes stanzas of key = value pairs that specify the connection type and parameters for connecting to the database. For example, the database adaptor (MySQL, SQLite, etc.), path (SQLite file), or user and password (MySQL). If you used the [easy database setup](WorkingWithDatabases#Fast_and_easy_database_setup.md) above, this connection information is added automatically.
  1. The direct path to a SQLite database. Typically, these have a `.db` or `.sqlite` extension.
  1. The path to a GFF3 annotation file that can be directly loaded into memory. While fast, this option should only be reserved for small genomes. Yeast is OK, human is not.
  1. When using a database for data collection, the path to a directory of bigWig files may be specified. Known as a [BigWigSet directory](DataFileFormats#BigWigSet_directory.md), this allows a collection of two or more bigWig files to be treated as a BioPerl database, complete with metadata and attributes, including type and possibly strand, to be assigned to each bigWig file.
  1. When only chromosome information or sequence is required, the path to a single uncompressed fasta (multi-fasta is OK) or a directory of fasta files may be supplied. The directory should be writable by the user for a small index file to be written.
  1. In some cases, when only coordinate information is required, a [Bam](DataFileFormats#BAM_file.md), [bigWig](DataFileFormats#bigWig.md), or [bigBed](DataFileFormats#bigBed.md) file may be used.

For some **BioToolBox** data collection scripts, a second, data-specific database may be optionally specified using the `--ddb` option. The same options as above can be supplied. Note that this is not the same as collecting data from a Bam file, for example, which would be supplied separately as a `--data` option.

The database name or path is typically recorded in the metadata of the output file, especially when new files are generated. When you reuse these files in additional scripts, the `--db` option can often be skipped in subsequent programs, since it can be readily obtained from the metadata.

## Getting a gene list ##
Getting a gene list out of the database is easy. It may be done separately or in conjunction with collecting data. To illustrate, we'll just collect a gene list.

We use the **BioToolBox** script [get\_features.pl](Pod_get_features.md). We must provide the name of the database, or the path to a local SQLite file. An interactive list of available feature types will be presented, and we can select the one (or more) we want by number. Alternatively, if we know the feature type beforehand (using [print\_features.pl](Pod_print_features.md) for example), we can provide it on the command line. Here is an example interactively collecting genes from a MySQL database and previewing the file.
<pre>
localhost:~ tim$ get_features.pl --db zv9<br>
<br>
This program will collect features from a database<br>
<br>
These are the available data sets in the database:<br>
1	chromosome:UCSC<br>
2	scaffold:UCSC<br>
3	CDS:refGene<br>
4	exon:refGene<br>
5	five_prime_UTR:refGene<br>
6	gene:refGene<br>
7	mRNA:refGene<br>
8	miRNA:refGene<br>
9	ncRNA:refGene<br>
10	pseudogene:refGene<br>
11	three_prime_UTR:refGene<br>
Enter the feature(s) to collect. A comma de-limited list or range may be given<br>
6<br>
Collecting features...<br>
Collected 15,453 features<br>
Wrote file './gene_refGene.txt'<br>
localhost:~ tim$<br>
localhost:~ tim$ head gene_refGene.txt<br>
# Program /usr/local/biotoolbox/scripts/get_features.pl<br>
# Database zv9<br>
# Feature gene:refGene<br>
# Column_0 name=Primary_ID<br>
# Column_1 name=Name<br>
# Column_2 name=Type<br>
Primary_ID	Name	Type<br>
1052992	zgc:163025	gene:refGene<br>
1053018	f7	gene:refGene<br>
1053040	f7i	gene:refGene<br>
</pre>

The output file is a simple tab-delimited text file of the found features and their unique identifiers, including the database specific Primary\_ID, Name and Aliases (if any), and the GFF type:source (representing columns 3 and 2 in the source GFF, respectively). The file has a column header as well as metadata lines, which are prefixed with a `#` symbol. You can learn more about this format [here](TimDataFormat.md).

We can also modify the output depending on what we want. If we want genomic coordinates, or output as BED or GFF format, we can specify that through additional command line options. If we want to include, for example, 1 kb of flanking region for each gene, we can provide start and stop adjustment coordinates, like so.
<pre>
localhost:~ tim$ get_features.pl --db zv9 --feature gene:refGene --start=-1000 --stop=1000 --pos 53<br>
<br>
This program will collect features from a database<br>
<br>
Collecting features...<br>
Collected 15,453 features<br>
Wrote file './gene_refGene.txt'<br>
localhost:~ tim$<br>
localhost:~ tim$ head -n 15 gene_refGene.txt<br>
# Program /usr/local/biotoolbox/scripts/get_features.pl<br>
# Database zv9<br>
# Feature region<br>
# Column_0 name=Name<br>
# Column_1 name=Type<br>
# Column_2 name=Chromosome<br>
# Column_3 name=Start<br>
# Column_4 name=End;position=53;start_adjustment=-1000<br>
# Column_5 name=Strand;position=53;stop_adjustment=1000<br>
Name	Type	Chromosome	Start	End	Strand<br>
zgc:163025	gene:refGene	chr1	2800	16140	1<br>
f7	gene:refGene	chr1	14962	22248	1<br>
f7i	gene:refGene	chr1	22260	31081	1<br>
f10	gene:refGene	chr1	31089	38349	1<br>
pcid2	gene:refGene	chr1	47009	54546	-1<br>
localhost:~ tim$<br>
</pre>

Note that the output now includes start and stop coordinates for each gene, and that each have been adjusted by 1000 bp. The `--pos` option indicates the reference point from which the coordinates will be adjusted; in this case, we have indicated `53`, which means use the `5'` end for the start adjustment and the `3'` end for the stop adjustment. See the documentation for more examples. Note that the reported start and end coordinates are absolute (start `<` stop), but that the adjustment factors are based on the strand of the feature.

Also note that the coordinates are in base (not interbase, or 0-based) format. This is standard for all **BioToolBox** programs and BioPerl in general, and different from the UCSC-style BED format. A standard BED file may be written using `--bed` option.

## Getting more from the database ##

### Additional information ###
Sometimes we want more information about a gene than what [get\_features.pl](Pod_get_features.md) tells us. For example, there may be attributes encoded in the source GFF file that we want, such as Alias, Parent, or even exon count. We can use the **BioToolBox** script [get\_feature\_info.pl](Pod_get_feature_info.md) to collect additional information.

To continue our example, we want the number of exons and the gene status. We're using the interactive method to choose the attributes, but these can also be specified on the command line.
<pre>
localhost:~ tim$ get_feature_info.pl gene_refGene.txt<br>
<br>
This script will collect information for a list of features<br>
<br>
Loading feature list from 'gene_refGene.txt'....<br>
These are the attributes which may be collected:<br>
1	Chromosome<br>
2	Start<br>
3	Stop<br>
4	Strand<br>
5	Score<br>
6	Length<br>
7	Midpoint<br>
8	Phase<br>
9	RNA_count<br>
10	Exon_count<br>
11	Transcript_length<br>
12	Parent<br>
13	Primary_ID<br>
14	Dbxref<br>
15	Note<br>
16	load_id<br>
Enter the attribute number(s) to collect, comma-delimited or range  10,14<br>
Retrieving Exon_count, Dbxref<br>
Wrote file './gene_refGene.txt'<br>
That's it!<br>
localhost:~ tim$<br>
localhost:~ tim$ head gene_refGene.txt<br>
# Program /usr/local/biotoolbox/scripts/get_features.pl<br>
# Database zv9<br>
# Feature gene:refGene<br>
# Column_0 name=Primary_ID<br>
# Column_1 name=Name<br>
# Column_2 name=Type<br>
# Column_3 name=Exon_count<br>
# Column_4 name=Dbxref<br>
Primary_ID	Name	Type	Exon_count	Dbxref<br>
1052992	zgc:163025	gene:refGene	10	RefSeq:NM_001089558<br>
localhost:~ tim$<br>
</pre>

### Getting nonannotated regions ###
Sometimes the information we want is not specifically defined in the database or source GFF files. Rather, they must be inferred or calculated. For example, we may want just the promoter region, or the first or last exon, or the first or last intron. In this case, we can use the **BioToolBox** script [get\_gene\_regions.pl](Pod_get_gene_regions.md). Note that this script works with canonical gene structures, such as gene `->` mRNA `->` CDS, as typically found in GFF3 files.

Here, we need to specify two things. First, the feature type in the database that we want to collect, same as above, for example gene:refGene. Second, the region to collect, for example firstIntron. Here is a sample session.
<pre>
localhost:~ tim$ get_gene_regions.pl --db zv9 --feature gene:refGene --out 1stExon<br>
<br>
This program will get specific regions from features<br>
<br>
These are the available feature types in the database:<br>
1	first exon<br>
2	last exon<br>
3	transcription start site<br>
4	transcription stop site<br>
5	splice sites<br>
6	introns<br>
7	first intron<br>
8	last intron<br>
Enter the type of region to collect   1<br>
Collecting transcript types: mRNA<br>
Collecting first exon regions...<br>
collected 14,927 regions<br>
wrote file './1stExon.txt'<br>
localhost:~ tim$<br>
localhost:~ tim$ head -n 15 1stExon.txt<br>
# Program /usr/local/biotoolbox/scripts/get_gene_regions.pl<br>
# Database zv9<br>
# Feature region<br>
# Column_0 name=Parent;feature=gene:refGene<br>
# Column_1 name=Transcript;type=first_exon<br>
# Column_2 name=Name;type=mRNA<br>
# Column_3 name=Chromosome<br>
# Column_4 name=Start<br>
# Column_5 name=Stop<br>
# Column_6 name=Strand<br>
Parent	Transcript	Name	Chromosome	Start	Stop	Strand<br>
tec	NM_001114743	NM_001114743.exon0	Zv9_NA110	3370	3564	1<br>
ppp4r1	NM_200260	NM_200260.exon0	Zv9_NA119	3816	3883	-1<br>
etv6	NM_131832	NM_131832.exon0	Zv9_NA122	12902	13196	-1<br>
zgc:165507	NM_001099419	NM_001099419.exon0	Zv9_NA123	44693	44920	-1<br>
localhost:~ tim$<br>
</pre>

The program collected the first exon from mRNA subfeature of the requested gene type, and reported the exon Name, its parent gene and transcript, and coordinates. Note that in this context, we are referring to the 5' intron with respect to gene orientation.

This program can also be used to conveniently obtain the promoter regions by specifying the Transcription Start Site (tss) region and adjusting the coordinates with `--start` and `--stop` parameters (otherwise it will return a 1 bp region). But what if there are multiple alternative transcripts and/or promoters for a gene? You could specify mRNA as the feature type, but there may be lots of identical regions. Specify the `--unique` and `--slop` parameters to collect just the unique alternative promoter regions of genes. See the [documentation](Pod_get_gene_regions.md) for more details.

### Collecting sequences ###
Perhaps you want to look for your favorite transcription factor binding site in the first exon or promoter. You can use the **BioToolBox** script [data2fasta.pl](Pod_data2fasta.md) script with the file of regions you just collected as input, collect the sequences from the database or a fasta file, and write out a multi-fasta file.

### Calculating CpG frequency ###
Perhaps you have just identified differentially methylated regions in your latest genome-wide bisulfite sequencing data, and you want to now calculate whether the CpG frequency in these regions are below or above expected. You can use the **BioToolBox** script [CpG\_calculator.pl](Pod_CpG_calculator.md) to calculate the observed and expected (based on GC content) CpG dinucleotides and their ratio.