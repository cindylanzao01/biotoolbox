_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
Bio::ToolBox::Data::Feature - Objects representing rows in a data table

## DESCRIPTION ##
A Bio::ToolBox::Data::Feature is an object representing a row in the  data table. Usually, this in turn represents an annotated feature or  segment in the genome. As such, this object provides convenient  methods for accessing and manipulating the values in a row, as well as  methods for working with the represented genomic feature.

This class should not be used directly by the user. Rather, Feature  objects are generated from a Bio::ToolBox::Data::Iterator object  (generated itself from the [row\_stream](Pod_Bio_ToolBox_Data.md)  function in Bio::ToolBox::Data), or the [iterate](Pod_Bio_ToolBox_Data.md)  function in Bio::ToolBox::Data. Please see the respective documentation  for more information.

Example of working with a stream object.

```
	  my $Data = Bio::ToolBox::Data->new(file => $file);
```
```
	  # stream method
	  my $stream = $Data->row_stream;
	  while (my $row = $stream->next_row) {
		 # each $row is a Bio::ToolBox::Data::Feature object
		 # representing the row in the data table
		 my $value = $row->value($index);
		 # do something with $value
	  }
```
```
	  # iterate method
	  $Data->iterate( sub {
	     my $row = shift;
	     my $number = $row->value($index);
	     my $log_number = log($number);
	     $row->value($index, $log_number);
	  } );
```
```
```
## METHODS ##
### General information methods ###
row\_index


> Returns the index position of the current data row within the  data table. Useful for knowing where you are at within the data  table.

> 
feature\_type


> Returns one of three specific values describing the contents  of the data table inferred by the presence of specific column  names. This provides a clue as to whether the table features  represent genomic regions (defined by coordinate positions) or  named database features. The return values include:

> 
> coordinate: Table includes at least chromosome and start

> 
> named: Table includes name, type, and/or Primary\_ID

> 
> unknown: unrecognized

> 
### Methods to access row feature attributes ###
These methods return the corresponding value, if present in the  data table, based on the column header name. If the row represents  a named database object, try calling the feature() method first.  This will retrieve the database SeqFeature object, and the attributes  can then be retrieved using the methods below or on the actual  database SeqFeature object.

These methods do not set attribute values. If you need to change the  values in a table, use the value() method below.

seq\_id


> The name of the chromosome the feature is on.

> 
start


end


stop


> The coordinates of the feature or segment. Coordinates from known  0-based file formats, e.g. BED, are returned as 1-based. Coordinates  must be integers to be returned. Zero or negative start coordinates  are assumed to be accidents or poor programming and transformed to 1.  Zero or negative stop coordinates are just ignored. Use the value()  method if you don't want this to happen.

> 
strand


> The strand of the feature or segment. Returns -1, 0, or 1. Default is 0,  or unstranded.

> 
name


display\_name


> The name of the feature.

> 
type


> The type of feature. Typically either primary\_tag or primary\_tag:source\_tag.  In a GFF3 file, this represents columns 3 and 2, respectively. In annotation  databases such as [Bio::DB::SeqFeature::Store](Pod_Bio_DB_SeqFeature_Store.md), the type is used to restrict  to one of many different types of features, e.g. gene, mRNA, or exon.

> 
id


> Here, this represents the primary\_ID in the database. Note that this  number is unique to a specific database, and not portable between databases.

> 
length


> The length of the feature or segment.

> 
### Accessing and setting values in the row. ###
value($index)


value($index, $new\_value)


> Returns or sets the value at a specific column index in the  current data row.

> 
row\_values


> Returns an array or array reference representing all the values  in the current data row.

> 
### Convenience Methods to database functions ###
The next three functions are convenience methods for using the  attributes in the current data row to interact with databases.  They are wrappers to methods in the <Bio::ToolBox::db\_helper>  module.

feature


> Returns a SeqFeature object from the database using the name and  type values in the current Data table row. The SeqFeature object  is requested from the database named in the general metadata. If  an alternate database is desired, you should change it first using   the $Data->database() method. If the feature name or type is not  present in the table, then nothing is returned.

> 
> See <Bio::DB::SeqFeature> and [Bio::SeqFeatureI](Pod_Bio_SeqFeatureI.md) for more information  about working with these objects.

> 
segment


> Returns a database Segment object corresponding to the coordinates  defined in the Data table row. If a named feature and type are  present instead of coordinates, then the feature is first automatically  retrieved and a Segment returned based on its coordinates. The  database named in the general metadata is used to establish the  Segment object. If a different database is desired, it should be  changed first using the general database() method.

> 
> See [Bio::DB::SeqFeature::Segment](Pod_Bio_DB_SeqFeature_Segment.md) and [Bio::RangeI](Pod_Bio_RangeI.md) for more information  about working with Segment objects.

> 
get\_score(%args)


> This is a convenience method for the  [get\_chromo\_region\_score](Pod_Bio_ToolBox_db_helper.md)  method. It will return a single score value for the region defined by the  coordinates or typed named feature in the current data row. If  the Data table has coordinates, then those will be automatically  used. If the Data table has typed named features, then the  coordinates will automatically be looked up for you by requesting  a SeqFeature object from the database.

> 
> The name of the dataset from which to collect the data must be  provided. This may be a GFF type in a SeqFeature database, a  BigWig member in a BigWigSet database, or a path to a BigWig,  BigBed, Bam, or USeq file. Additional parameters may also be  specified; please see the [Bio::ToolBox::db\_helper](Pod_Bio_ToolBox_db_helper.md)  for full details.

> 
> If you wish to override coordinates that are present in the  Data table, for example to extend or shift the given coordinates  by some amount, then simply pass the new start and end  coordinates as options to this method.

> 
> Here is an example of collecting mean values from a BigWig  and adding the scores to the Data table.

> 
```
  my $index = $Data->add_column('MyData');
  my $stream = $Data->row_stream;
  while (my $row = $stream->next_row) {
     my $score = $row->get_score(
        'method'    => 'mean',
        'dataset'   => '/path/to/MyData.bw',
     );
     $row->value($index, $score);
  }
```
get\_position\_scores(%args)


> This is a convenience method for the  [get\_region\_dataset\_hash](Pod_Bio_ToolBox_db_helper.md)  method. It will return a hash of  positions => scores over the region defined by the  coordinates or typed named feature in the current data row.  The coordinates for the interrogated region will be  automatically provided.

> 
> Just like the [get\_score](Pod_get_score.md) method, the dataset from which to  collect the scores must be provided, along with any other  optional arguments.

> 
> If you wish to override coordinates that are present in the  Data table, for example to extend or shift the given coordinates  by some amount, then simply pass the new start and end  coordinates as options to this method.

> 
> Here is an example for collecting positioned scores around  the 5 prime end of a feature from a [BigWigSet](Pod_Bio_DB_BigWigSet.md)  directory.

> 
```
  my $stream = $Data->row_stream;
  while (my $row = $stream->next_row) {
     my %position2score = $row->get_position_scores(
        'ddb'       => '/path/to/BigWigSet/',
        'dataset'   => 'MyData',
        'position'  => 5,
     )
     # do something with %position2score
  }
```
### Feature Export ###
These methods allow the feature to be exported in industry standard  formats, including the BED format and the GFF format. Both methods  return a formatted tab-delimited text string suitable for printing to  file. The string does not include a line ending character.

These methods rely on coordinates being present in the source table.  If the row feature represents a database item, the feature() method  should be called prior to these methods, allowing the feature to be  retrieved from the database and coordinates obtained.

bed\_string(%args)


> Returns a BED formatted string. By default, a 6-element string is  generated, unless otherwise specified. Pass an array of key values  to control how the string is generated. The following arguments  are supported.

> 
> bed => <integer>

> 
> > Specify the number of BED elements to include. The number of elements  correspond to the number of columns in the BED file specification. A  minimum of 3 (chromosome, start, stop) is required, and maximum of 6  is allowed (chromosome, start, stop, name, score, strand).

> 
> > 

> chromo => <text>

> 
> seq\_id => <text>

> 
> start  => <integer>

> 
> stop   => <integer>

> 
> end    => <integer>

> 
> strand => $strand

> 
> > Provide alternate values from those defined or missing in the current  row Feature. Note that start values are automatically converted to 0-base  by subtracting 1.

> 
> > 

> name => <text>

> 
> > Provide alternate or missing name value to be used as text in the 4th  column. If no name is provided or available, a default name is generated.

> 
> > 

> score => <number>

> 
> > Provide a numerical value to be included as the score. BED files typically  use integer values ranging from 1..1000.

> 
> > 
gff\_string(%args)



> Returns a GFF3 formatted string. Pass an array of key values  to control how the string is generated. The following arguments  are supported.

> 
> chromo => <text>

> 
> seq\_id => <text>

> 
> start  => <integer>

> 
> stop   => <integer>

> 
> end    => <integer>

> 
> strand => $strand

> 
> > Provide alternate values from those defined or missing in the current  row Feature.

> 
> > 

> source => <text>

> 
> > Provide a text string to be used as the source\_tag value in the 2nd  column. The default value is null ".".

> 
> > 

> primary\_tag => <text>

> 
> > Provide a text string to be used as the primary\_tag value in the 3rd  column. The default value is null ".".

> 
> > 

> type => <text>

> 
> > Provide a text string. This can be either a "primary\_tag:source\_tag" value  as used by GFF based BioPerl databases, or "primary\_tag" alone.

> 
> > 

> score => <number>

> 
> > Provide a numerical value to be included as the score. The default  value is null ".".

> 
> > 

> name => <text>

> 
> > Provide alternate or missing name value to be used as the display\_name.  If no name is provided or available, a default name is generated.

> 
> > 

> attributes => `[`index`]`,

> 
> > Provide an anonymous array reference of one or more row Feature indices  to be used as GFF attributes. The name of the column is used as the GFF  attribute key.

> 
> > 
## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.
