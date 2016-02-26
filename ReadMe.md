# README for BioToolBox #

## Description ##

This is a collection of libraries and high-quality end-user scripts for bioinformatic analysis, particularly of genomic data obtained from microarray and next-generation sequencing.

The Bio::ToolBox libraries provide an abstraction layer over a variety of different specialized BioPerl-style modules. For example, there is a special emphasis on the collection data values for defined genomic coordinate regions, regardless of whether the values come from a GFF database, Bam file, BigWig file, etc. See the documentation with the Bio::ToolBox::Data module for more information on working with tables of information, for example BED files of genomic coordinates, and using that information to collect data from databases.

The Bio::ToolBox package also includes a large number of high quality scripts for setting up databases of annotation, collecting annotated features, collecting genomic data relative to features, manipulating and analyzing data, and data format conversion. These scripts are installed in your local scripts bin directory.

## Requirements ##

These are Perl modules and scripts. They require Perl and a unix-like command-line environment. They have been developed and tested on Mac OS X and linux; Microsoft Windows compatability is not tested nor guaranteed.

Most recent versions of Perl will work; older versions will require additional updating for compatibility.

Several different Perl modules are required for specific programs to work, most notably BioPerl, among a few others. Most of these dependencies can be taken care of by the installer.

## Installation ##

Installation is simple with the standard Perl incantation.
<pre>
perl ./Build.PL<br>
./Build installdeps     # if necessary<br>
./Build<br>
./Build test<br>
./Build install<br>
</pre>

Installation may also be managed through a package manager, either the CPAN shell or a utility such as cpanminus.

## Usage of Provided Scripts ##

### Configuration ###
There is a configuration file that may be customized for your particular installation. The default file is written to `~/.biotoolbox.cfg`. It is a simple INI-style file that is used to set up database connection profiles, feature aliases, helper application locations, etc. The file may be edited by users. More documentation can be found in the Bio::ToolBox::db\_helper::config documentation. This file is automatically written as needed; it is not installed by the Installer.

### Execution ###
All biotoolbox scripts are designed to be run from the command line or executed from another script. Some programs, for example manipulate\_datasets.pl, also provide an interactive interface to allow for spontaneous work or when the exact index number or name of the dataset in the file or database is not immediately known.

### Help ###
All scripts require command line options for execution. Executing the program without any options will present a synopsis of the options that are available. Most programs also have a `--help` option, which will display detailed information about the program and execution (usually by displaying the internal POD). The options are given in the long format (`--help`, for example), but may be shortened to single letters if the first letter is unique (`-h`, for example).

### File Formats ###
Many of the programs are designed to input and output a tabbed-delimited text format (unix line endings), where the rows represent genomic features, bins, etc. and the columns represent descriptive information and data. The first line in the table are the column headings. Metadata about each column are recorded in header lines at the beginning of the file and prefixed by a # symbol. The files may be compressed with gzip. More information may be found Bio::ToolBox::file\_helper.

## Project Website ##

The BioToolBox project repository may be found at http://code.google.com/p/biotoolbox/.

Please contact the author for bugs. Feature requests are also accepted, within time constraints. Contact information is at the project website.

## Online Documentation ##

  * [Quick Guide to setup](QuickGuide.md)
  * [Setting](BioToolBoxSetUp.md) up a computer for BioToolBox
  * Setting up [Mac OS X](SetupForMacOSX.md) for bioinformatics
  * Up to date list of BioToolBox [programs](ProgramList.md)
  * Working with annotation in [databases](WorkingWithDatabases.md)
  * Working with data files and [datasets](WorkingWithDatasets.md)
  * Description of supported data [file formats](DataFileFormats.md)
  * [Mapping SNPs](MappingSNPs.md)
  * Description of the text data [report format](TimDataFormat.md)