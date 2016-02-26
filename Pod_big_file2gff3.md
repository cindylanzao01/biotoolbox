_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
big\_file2gff3.pl

A script to generate GFF3 files for bigwig, bigbed, and bam files.

## SYNOPSIS ##
big\_file2gff3.pl `[`--options...`]` <filename1.bw> <filename2.bb> ...

```
  Options:
  --in <file> or <file1,file2,...>
  --path </destination/path/for/bigfiles/>
  --source <text>
  --name <text> or <text1,text2,...>
  --type <text> or <text1,text2,...>
  --strand [f|r|w|c|+|-|1|0|-1],...
  --chromo 
  --rename
  --set
  --setname <text>
  --conf
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename.bw | filename.bb | filename.bam>


> Provide the name(s) of the input BigFiles. Three types of files are  supported: BigWig (.bw), BigBed (.bb), or BAM (.bam) files.  The list may be specified three ways: by reiterating the  --in option, providing a single comma-delimited list, or simply listing  all files after the options (e.g. "data`_*`.bw").

> 
```
```
--path </destination/path/for/bigfiles/>


> Provide the destination directory name for the BigFile files. If the destination does not exist, then it will created. This directory should be writeable by the user and readable by all (or at least the Apache and MySQL users). If the input files are not currently located here, they will be copied to the directory for you. Note that when generating a BigWigSet, a subdirectory with the set name (option --setname) will be made for you. The default path is the current path for the input file.

> 
--source <text>


> Provide the name for the GFF feature's source for all of the input value.  The default value is "data". Unique values for each input file is not  supported.

> 
--name <text>


> Provide the name(s) for the GFF feature(s). This will be used as the GFF  feature's name. A unique name should be provided for each file, and may be  specified as a single comma-delimited list or by reiterating the --name  option. The default value is to use the input file basename.

> 
--type <text>


> Provide the GFF type for the GFF features for all input files. A unique  type should be provided for each file, and may be specified as a single  comma-delimited list or by reiterating the --type option. By default,  it re-uses the GFF name.

> 
--strand `[`f|r|w|c|+|-|1|0|-1`]`,...


> Indicate which strand the feature will be located. Acceptable values include  (f)orward, (r)everse, (w)atson, (c)rick, +, -, 1, or -1. By default no strand  is used. For mulitple input files with different strands, use the option  repeatedly or provide a comma-delimited list. If only one value is provided,  it is used for all input files.

> 
--chromo


> Include chromosome features in the output GFF3 file. These are necessary  to make a complete GFF3 file compatible for loading into a Bio::DB database  when chromosome information is not provided elsewhere.

> 
--rename


> Rename the input source file basenames as "$source.$name" when moving to the  target directory. This may help in organization and clarity of file listings.  Default is false.

> 
--set


> Indicate that all of the input BigWig files should be part of a BigWigSet, which treats all of the BigWig files in the target directory as a single database. A text file is written in the target directory with metadata for  each BigWig file (feature, source, strand, name) as described in the  Bio::DB::BigWigSet documentation. Additional metadata may be manually  added if desired. The default is false.

> 
--setname <text>


> Optionally specify the name for the BigWigSet track when writing the  GBrowse configuration stanza. It is also used as the basename for the  GFF3 file, as well as the name of the new subdirectory in the target path  for use as the BigWigSet directory. The default is to use the name of  the last directory in the target path.

> 
--conf


> Write sample GBrowse database and track configuration stanzas. Each BigFile  file will get individual stanzas, unless the --set option is enabled, where  a single stanza with subtracks for the BigWigSet is generated. This is  helpful when setting up GBrowse database and configurations. Default is false.

> 
--version


> Print the version number.

> 
--help


> Display this POD help.

> 
## DESCRIPTION ##
This program will generate a GFF3 file with features representing a  BigFile file. Two types of BigFiles are supported: BigWig and BigBed. BAM  files are also supported. The generated features will encompass the entire  length of each chromosome represented in the data file. The name of the data  file and its absolute path is stored as a tag value in each feature. This  tag value can be used by `Bio::ToolBox::db_helper` to collect data from the file  with respect to various locations and features in the database.

The source data file is copied to the destination directory. The file may be  renamed as "source.name" so as to avoid confusion when lots of files are  dumped into the same directory.

The BigWig files may also be designated as a BigWigSet, with unique metadata  assigned to each file (source, type, name, strand). The BigWigSet may be  treated as a single database with multiple bigwig data sources by GBrowse. A  metadata index file is written in the target directory as described in  Bio::DB::BigWigSet.

Multiple source files may be designated, and each may have its own name.  This facilitates multiple file processing.

The generated GFF3 file is written to the current directory. One GFF file is  written for each input file, or one GFF file for a BigWigSet. It uses the  provided GFF name as the basename for the file.

Optionally, sample database and track GBrowse configuration stanzas may also be  written to the current directory to facilitate setting up GBrowse. If a  BigWigSet database is requested, then the track stanza will be set up with  subtrack tables representing each BigWig file.

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
