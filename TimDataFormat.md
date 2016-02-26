# Format Of Tim Data Text File #

Many of the **biotoolbox** scripts read and write a special tab-delimited text file called, for (a complete) lack of a better name, the tim data format.

The tim data file format is not indicated by a special file extension. Rather, a generic '.txt' extension is used to preserve functionality with other text processing programs. The file is essentially a simple tab delimited text file representing rows (lines) and columns (demarcated by the tabs).

What makes it unique are the metadata header lines, each prefixed by a '# '. These metadata lines describe the data within the table with regards to its type, source, methodology, history, and processing. The metadata is designed to be read by both human and computer. Opening files without this metadata will result in basic default metadata assigned to each column. Special files recognized by their extension (e.g. GFF or BED) will have appropriate metadata assigned.

## Specific metadata lines ##

The specific metadata lines that are specifically recognized are listed below.

#### Feature ####

The Feature describes the types of features represented on each row in the data table. These can include gene, transcript, genome, etc.

#### Database ####

The name of the database used in generation of the feature table. This is often also the database used in collecting the data, unless the dataset metadata specifies otherwise.

#### Program ####

The name of the program generating the data table and file. It usually includes the whole path of the executable.

#### Column ####

The next header lines include column specific metadata. Each column will have a separate header line, specified initially by the word 'Column', followed by an underscore and the column number (1-based). Following this is a series of 'key=value' pairs separated by ';'. Spaces are generally not allowed. Obviously '=' or ';' are not allowed or they will interfere with the parsing. The metadata describes how and where the data was collected. Additionally, any modifications performed on the data are also recorded here. The only two keys that are required are the first two, 'name' and 'index'. If the file being read does not contain metadata, then it will be generated with these two basic keys.

## Standard Column metadata keys ##

A list of standard column header keys is below, but is not exhaustive.

#### name ####

The name of the column. This should be identical to the table header.

#### index ####

The 0-based index number of the column.

#### database ####

Included if different from the main database indicated above.

#### window ####

The size of the window for genome datasets

#### step ####

The step size of the window for genome datasets

#### dataset ####

The name of the dataset(s) from which data is collected. Comma delimited.

#### start ####

The starting point for the feature in collecting values

#### stop ####

The stopping point of the feature in collecting values

#### extend ####

The extension of the region in collecting values

#### strand ####

The strandedness of the data collecte. Values include 'sense', 'antisense', or 'none'

#### method ####

The method of collecting values

#### log2 ####

boolean indicating the values are in log2 space or not

## Data Table ##

Finally, the data table follows the metadata. The table consists of tab-delimited data. The same number of fields should be present in each row. Each row represents a genomic feature or landmark, and each column contains either identifying information or a collected dataset. The first row will always contain the column names, except in special cases such as the GFF format where the columns are strictly defined. The column name should be the same as defined in the column's metadata. When loading GFF files, the header names and metadata are automatically generated for conveniance.
