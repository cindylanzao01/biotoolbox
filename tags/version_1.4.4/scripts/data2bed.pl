#!/usr/bin/perl

# This script will convert a data file to a bed file

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_data_helper qw(
	find_column_index
);
use tim_db_helper qw(
	$TIM_CONFIG
	open_db_connection
);
use tim_file_helper qw(
	open_tim_data_file
	open_to_write_fh
);
eval {
	# check for bigbed file conversion support
	require tim_db_helper::bigbed;
	tim_db_helper::bigbed->import;
};

print "\n This program will write a BED file\n";

### Quick help
unless (@ARGV) { 
	# when no command line options are present
	# print SYNOPSIS
	pod2usage( {
		'-verbose' => 0, 
		'-exitval' => 1,
	} );
}



### Get command line options and initialize values
my (
	$infile,
	$outfile,
	$chr_index,
	$start_index,
	$stop_index,
	$name,
	$score_index,
	$strand_index,
	$zero_based,
	$ask,
	$bigbed,
	$bb_app_path,
	$database,
	$chromo_file,
	$gz,
	$help
);

# Command line options
GetOptions( 
	'in=s'      => \$infile, # the solexa data file
	'out=s'     => \$outfile, # name of output file 
	'chr=i'     => \$chr_index, # index of the chromosome column
	'start=i'   => \$start_index, # index of the start position column
	'stop|end=i'=> \$stop_index, # index of the stop position coloumn
	'name=s'    => \$name, # index for the name column
	'score=i'   => \$score_index, # index for the score column
	'strand=i'  => \$strand_index, # index for the strand column
	'zero!'     => \$zero_based, # source is 0-based numbering, convert
	'ask'       => \$ask, # request help in assigning indices
	'bigbed|bb' => \$bigbed, # generate a binary bigbed file
	'db=s'      => \$database, # database for bigbed file generation
	'chromof=s' => \$chromo_file, # name of a chromosome file
	'bbapp=s'   => \$bb_app_path, # path to bedToBigBed utility
	'gz!'       => \$gz, # compress output
	'help'      => \$help # request help
);

# Print help
if ($help) {
	# print entire POD
	pod2usage( {
		'-verbose' => 2,
		'-exitval' => 1,
	} );
}



### Check for requirements
unless ($infile) {
	$infile = shift @ARGV or
		die " no input file! use --help for more information\n";
}
unless (defined $gz) {
	$gz = 0;
}
unless (defined $zero_based) {
	# default is that the source file is base coordinates
	# but bed is traditionally interbase
	$zero_based = 0;
}
if ($bigbed) {
	# do not allow compression even if requested when converting to bigbed
	warn " compression not allowed when converting to BigBed format\n";
	$gz = 0;
}

# define name base or index
my $name_index;
my $name_base;
if (defined $name) {
	if ($name =~ /^(\d+)$/) {
		# looks like an index was provided
		$name_index = $1;
	}
	elsif ($name =~ /(\w+)/i) {
		# text that will be used as the name base when autogenerating
		$name_base = $1;
	}
}



### Load file
print " Opening data file '$infile'...\n";
my ($in_fh, $metadata_ref) = open_tim_data_file($infile);
unless ($in_fh) {
	die "Unable to open data table!\n";
}

# identify database if needed
if ($bigbed) {
	unless ($database or $chromo_file) {
		if (exists $metadata_ref->{db}) {
			$database = $metadata_ref->{db};
		}
		else {
			die " No database name or chromosome file provided for generating bigbed file!\n";
		}
	}
}



### Determine indices

# Ask user interactively
if ($ask) {
	# the user has specified that we should ask for specific indices
	
	# print the column names
	print " These are the column names in the datafile\n";
	for (my $i = 0; $i < $metadata_ref->{'number_columns'}; $i++) {
		print "   $i\t", $metadata_ref->{$i}{'name'}, "\n";
	}
	print " Note that not all options are not required\n";
	
	# request chromosome index
	unless (defined $chr_index) {
		my $suggestion = find_column_index($metadata_ref, '^chr|seq|refseq');
		print " Enter the index for the chromosome column [$suggestion]  ";
		my $in = <STDIN>;
		if ($in =~ /(\d+)/) {
			$chr_index = $1;
		}
		elsif (defined $suggestion) {
			$chr_index = $suggestion;
		}
		else {
			die " No identifiable chromosome column index!\n";
		}
	}
	
	# request start index
	unless (defined $start_index) {
		my $suggestion = find_column_index($metadata_ref, 'start');
		print " Enter the index for the start column [$suggestion]  ";
		my $in = <STDIN>;
		if ($in =~ /(\d+)/) {
			$start_index = $1;
		}
		elsif (defined $suggestion) {
			$start_index = $suggestion;
		}
		else {
			die " No identifiable start position column index!\n";
		}
	}
	
	# request stop index
	unless (defined $stop_index) {
		my $suggestion = find_column_index($metadata_ref, 'stop|end');
		print " Enter the index for the stop or end column [$suggestion]  ";
		my $in = <STDIN>;
		if ($in =~ /(\d+)/) {
			$stop_index = $1;
		}
		elsif (defined $suggestion) {
			$stop_index = $suggestion;
		}
		else {
			die " No identifiable stop position column index!\n";
		}
	}
	
	# request name index or text
	unless (defined $name) {
		print " Enter the index for the feature name column or\n" . 
			"   the base text for auto-generated names   ";
		my $in = <STDIN>;
		if ($in =~ /^(\d+)$/) {
			$name_index = $1;
		}
		elsif ($in =~ /(\w+)/) {
			$name_base = $1;
		}
	}
	
	# request score index
	unless (defined $score_index) {
		print " Enter the index for the feature score column  ";
		my $in = <STDIN>;
		if ($in =~ /(\d+)/) {
			$score_index = $1;
		}
	}
	
	# request strand index
	unless (defined $strand_index) {
		print " Enter the index for the feature strand column  ";
		my $in = <STDIN>;
		if ($in =~ /(\d+)/) {
			$strand_index = $1;
		}
	}
}

# automatically identify gff format
elsif (
	$metadata_ref->{'extension'} =~ /gff/ and
	!defined $chr_index and
	!defined $start_index and 
	!defined $stop_index
) {
	$chr_index    = 0 unless defined $chr_index;
	$start_index  = 3 unless defined $start_index;
	$stop_index   = 4 unless defined $stop_index;
	$score_index  = 5 unless defined $score_index;
	$strand_index = 6 unless defined $strand_index;
	$name_index   = 8 unless defined $name_index;
}


# confirm indices
unless (defined $chr_index and defined $start_index and defined $stop_index) {
	die " Must define indices for chromosome, start and stop!\n";
}


### Convert to BED progressively
# print summary of conversion options
print " converting to BED using\n";
print "  - '", $metadata_ref->{$chr_index}{name}, "' for chromosome\n" 
	if defined $chr_index;
print "  - '", $metadata_ref->{$start_index}{name}, "' for start\n" 
	if defined $start_index;
print "  - '", $metadata_ref->{$stop_index}{name}, "' for stop\n" 
	if defined $stop_index;
print "  - '", $metadata_ref->{$name_index}{name}, "' for name\n" 
	if defined $name_index;
print "  - '", $metadata_ref->{$score_index}{name}, "' for score\n" 
	if defined $score_index;
print "  - '", $metadata_ref->{$strand_index}{name}, "' for strand\n" 
	if defined $strand_index;

# open output file handle
unless ($outfile) {
	$outfile = $metadata_ref->{'basename'} . '.bed';
	$outfile .= '.gz' if $gz;
}
my $out_fh = open_to_write_fh($outfile, $gz) or 
	die " unable to open output file for writing!\n";

# write very simple metadata
unless ($bigbed) {
	$out_fh->print("# Converted from file " . $metadata_ref->{'filename'} . "\n");
}

# parse through the data lines in the input data file
my $count = 0; # the number of lines processed
my $strand_warning = 0; # warning for strand of 0
while (my $line = $in_fh->getline) {
	
	# Get the line data
	chomp $line;
	my @data = split /\t/, $line;
	
	# Convert the coordinates
	my @bed;
	push @bed, $data[$chr_index]; # chromosome
	if ($zero_based) {
		# source is already interbase !?
		push @bed, $data[$start_index];
		push @bed, $data[$stop_index];
	}
	else {
		# convert source base coordinates to interbase coordinates
		push @bed, $data[$start_index] - 1;
		push @bed, $data[$stop_index];
	}
	
	# Convert the name 
		# the name index could either be a simple one-word element
		# or it could be embeded in the group column of a GFF file
	if (defined $name_index and $name_index == 8 and $metadata_ref->{'gff'}) {
		# name is embedded in the group column of a gff file
		# need to extract
		
		# split the groups column into elements
		# semi-colon delimited, space optional
		my @groups = split / ?; ?/, $data[$name_index]; 
		foreach my $element (@groups) {
			my ($key, $value) = split / ?= ?/, $element;
			if ($key =~ /^name$/i) {
				push @bed, $value;
				last;
			}
		}
	}
	elsif (defined $name_index) {
		# a simple one-word element
		push @bed, $data[$name_index];
	}
	elsif (defined $name_base) {
		# auto-generate the names
		push @bed, $name_base . '_' . sprintf("%08d", $count);
	}
	
	# Convert the score
	if (
		(defined $name_index or defined $name_base) and 
		defined $score_index
	) {
		if ($data[$score_index] eq '.') {
			# bed files don't accept null values
			push @bed, '0';
		}
		else {
			push @bed, $data[$score_index];
		}
	}
	
	# Convert the strand
	if (
		(defined $name_index or defined $name_base) and 
		defined $score_index and 
		defined $strand_index
	) {
		my $value = $data[$strand_index];
		if ($value =~ m/\A [f \+ 1 w]/xi) {
			# forward, plus, one, watson
			push @bed, '+';
		}
		elsif ($value =~ m/\A [r \- c]/xi) {
			# reverse, minus, crick
			push @bed, '-';
		}
		elsif ($value =~ m/\A [0 \.]/xi) {
			# zero, period
			push @bed, '0';
		}
		else {
			# unidentified, assume it's non-stranded
			push @bed, '0';
		}
		
		# print warning
		if ($bed[5] eq '0') {
			unless ($strand_warning) {
				warn "   Using non-standard feature strand value of 0 at input data line ", $count + 1, "\n";
				$strand_warning = 1;
			}
		}
	}
	
	# write
	# there should be chromosome, start, stop, name, score, strand
	$out_fh->print( join("\t", @bed) . "\n");
	
	# increment counter
	$count++;
}

$out_fh->close;




### Convert to BigBed format
if ($bigbed) {
	# requested to continue and generate a binary bigbed file
	print " wrote $count lines to temporary bed file '$outfile'\n";
	print " converting to bigbed file....\n";
	
	# check that bigbed conversion is supported
	unless (exists &bed_to_bigbed_conversion) {
		warn "\n  Support for converting to bigbed format is not available\n" . 
			"  Please convert manually. See documentation for more info\n";
		print " finished\n";
		exit;
	}
	
	
	# open database connection if necessary
	my $db;
	if ($database) {
		$db = open_db_connection($database);
	}
	
	# find bedToBigBed utility
	unless ($bb_app_path) {
		# check for an entry in the configuration file
		$bb_app_path = $TIM_CONFIG->param('applications.bedToBigBed') || 
			undef;
	}
	unless ($bb_app_path) {
		# next check the system path
		$bb_app_path = `which bedToBigBed` || undef;
	}
	unless ($bb_app_path) {
		warn "\n  Unable to find conversion utility 'bedToBigBed'! Conversion failed!\n" . 
			"  See documentation for more info\n";
		print " finished\n";
		exit;
	}
		
			
	# determine reference sequence type
	my $ref_seq_type = 
		$TIM_CONFIG->param("$database\.reference_sequence_type") ||
		$TIM_CONFIG->param('default_db.reference_sequence_type');
	
	# perform the conversion
	my $bb_file = bed_to_bigbed_conversion( {
			'bed'       => $outfile,
			'db'        => $db,
			'seq_type'  => $ref_seq_type,
			'chromo'    => $chromo_file,
			'bbapppath' => $bb_app_path,
	} );

	
	# confirm
	if ($bb_file) {
		print " BigBed file '$bb_file' generated\n";
		unlink $outfile; # remove the bed file
	}
	else {
		die " BigBed file not generated! see standard error\n";
	}
	
}
else {
	print " wrote $count lines to BED file '$outfile'\n",
}


__END__

=head1 NAME

data2bed.pl

=head1 SYNOPSIS

data2bed.pl [--options...] <filename>
  
  Options:
  --in <filename>
  --ask
  --chr <column_index>
  --start <column_index>
  --stop | --end <column_index>
  --name <column_index | base_text>
  --score <column_index>
  --strand <column_index>
  --zero
  --out <filename> 
  --bigbed | --bb
  --chromof <filename>
  --db <database>
  --bbapp </path/to/bedToBigBed>
  --(no)gz
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --in <filename>

Specify the file name of a data file. It must be a tab-delimited text file,
preferably in the tim data format as described in 'tim_file_helper.pm', 
although any format should work. The file may be compressed with gzip.

=item --ask

Indicate that the program should interactively ask for the indices for 
feature data. It will present a list of the column 
names to choose from. Enter nothing for non-relevant columns or to 
accept default values.

=item --chr <column_index>

The index of the dataset in the data table to be used 
as the chromosome or sequence ID column in the BED data.

=item --start <column_index>

The index of the dataset in the data table to be used 
as the start position column in the BED data.

=item --start <column_index>

=item --end <column_index>

The index of the dataset in the data table to be used 
as the stop or end position column in the BED data.

=item --score <column_index>

The index of the dataset in the data table to be used 
as the score column in the BED data.

=item --name <column_index | base_text>

Supply either the index of the column in the data table to 
be used as the name column in the BED data, or the base text 
to be used when auto-generating unique feature names. The 
auto-generated names are in the format 'text_00000001'.

=item --strand <column_index>

The index of the dataset in the data table to be used
for strand information. Accepted values might include
any of the following "f(orward), r(everse), w(atson),
c(rick), +, -, 1, -1, 0, .".

=item --zero

Indicate that the source data is already in interbase (0-based) 
coordinates and do not need to be converted. By convention, all 
BioPerl (and, by extension, all biotoolbox) scripts are base 
(1-based) coordinates. Default behavior is to convert.

=item --out <filename>

Specify the output filename. By default it uses the basename of the input 
file.

=item --bigbed

=item --bb

Indicate that a binary BigBed file should be generated instead of 
a text BED file. A .bed file is first generated, then converted to 
a .bb file, and then the .bed file is removed.

=item --chromf <filename>

When converting to a BigBed file, provide a two-column tab-delimited 
text file containing the chromosome names and their lengths in bp. 
Alternatively, provide a name of a database, below.

=item --db <database>

Specify the database from which chromosome lengths can be derived when 
generating a BigBed file. This option is only required when generating 
BigBed files. It may also be supplied from the metadata in the source 
data file.

=item --bbapp </path/to/bedToBigBed>

Specify the path to the Jim Kent's bedToBigBed conversion utility. The 
default is to first check the tim_db_helper.cfg configuration file for 
the application path. Failing that, it will search the default 
environment path for the utility. If found, it will automatically 
execute the utility to convert the bed file.

=item --(no)gz

Specify whether (or not) the output file should be compressed with gzip.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program will convert a tab-delimited data file into a BED file,
according to the specifications here
http://genome.ucsc.edu/goldenPath/help/customTrack.html#BED. A minimum of
three and a maximum of six columns may be generated. Column identification 
may be specified on the command line or interactively. GFF source files  
have columns automatically identified. All lower-numbered
columns must be defined before writing higher-numbered columns. Thin and
thick block data are not written. Browser and Track lines are also not
written. Following specification, all coordinates are written in interbase
(0-based) coordinates. Base (1-based) coordinates (the BioPerl standard) will
be converted. Score values are not converted, however, to a 1..1000 scale.
The biotoolbox script C<manipulate_datasets.pl> has tools to do this if
required.

An option exists to further convert the BED file to an indexed, binary BigBed 
format. Jim Kent's bedToBigBed conversion utility must be available, and 
either a chromosome definition file or access to a Bio::DB database is required.




=head1 AUTHOR

 Timothy J. Parnell, PhD
 Howard Hughes Medical Institute
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112

This package is free software; you can redistribute it and/or modify
it under the terms of the GPL (either version 1, or at your option,
any later version) or the Artistic License 2.0.  

