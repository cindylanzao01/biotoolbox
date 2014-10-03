#!/usr/bin/perl

# A script to convert a datafile into a frequency distribution

use strict;
use Getopt::Long;
use Statistics::Descriptive;
use Pod::Usage;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_data_helper qw(
	generate_tim_data_structure
	parse_list
);
use tim_file_helper qw(
	load_tim_data_file
	write_tim_data_file
);
my $VERSION = '1.0.2';

print "\n This script will convert a datafile into histogram values\n\n";



### Quick help
unless (@ARGV) { 
	# when no command line options are present
	# print SYNOPSIS
	pod2usage( {
		'-verbose' => 0, 
		'-exitval' => 1,
	} );
}



### Get command line options
my (
	$infile, 
	$outfile,
	$index,
	$binnumber,
	$binsize,
	$start,
	$max,
	$help,
	$print_version,
);
GetOptions( 
	'in=s'       => \$infile, # the input file
	'index=s'    => \$index, # columns (datasets) to plot
	'out=s'      => \$outfile, # output file name
	'bins=i'     => \$binnumber, # the number of bins to put the data into
	'size=f'     => \$binsize, # the size of each bin
	'min=f'      => \$start, # the starting value to calculate the bins
	'max=f'      => \$max, # maximum value for x-axis
	'help'       => \$help, # flag to print help
	'version'    => \$print_version, # print the version
) or die " unrecognized option(s)!! please refer to the help documentation\n\n";

if ($help) {
	# print entire POD
	pod2usage( {
		'-verbose' => 2,
		'-exitval' => 1,
	} );
}

# Print version
if ($print_version) {
	print " Biotoolbox script data2frequency.pl, version $VERSION\n\n";
	exit;
}


### Required values
unless ($infile) {
	$infile = shift @ARGV or
		die " no input file! use --help for more information\n";
}
unless ($binsize) {
	die " Missing bin size!\n Please use --help for more information\n";
}
unless ($binnumber or $max) {
	die " Either bin number or maximum value must be entered!\n" . 
		" Please use --help for more information\n";
}
unless (defined $start) {
	# default value 
	$start = 0;
}
unless (defined $max) {
	# default value is calculated
	$max = $start + ($binnumber * $binsize);
}





####### Main ###########

### Load the file
# load the file using subroutine from tim_db_helper.pm
print " Loading data from file $infile....\n";
my $in_data_ref = load_tim_data_file($infile);
unless ($in_data_ref) {
	die " No data loaded!\n";
}
my $in_table_ref = $in_data_ref->{'data_table'};

# load the dataset names into hashes
my (%dataset_by_name, %dataset_by_id); # hashes for name and id
for (my $i = 0; $i < $in_data_ref->{'number_columns'}; $i++) {
	my $name = $in_data_ref->{$i}{'name'};
	if (
		# check column header names for gene or window attribute information
		$name =~ /name/i or 
		$name =~ /class/i or
		$name =~ /alias/i or
		$name =~ /^chr/i or
		$name =~ /start/i or
		$name =~ /stop/i
	) { 
		# skip on to the next header
		next; 
	} 
	else { 
		# record the data set name
		$dataset_by_id{$i} = $name;
		$dataset_by_name{$name} = $i;
	}
}	



### Calculate the Bins
my @bins; # an array for the bins
for (my $i = ($binsize + $start); $i < $max; $i += $binsize) {
	push @bins, $i;
	#print "$i ";
}



### Determine the order
my @indices; # an array of the indices to convert
if (defined $index) {
	# indices defined as command line argument
	@indices = parse_list($index);
}
else {
	# interactively ask the user
	@indices = ask_for_index();
}
unless (@indices) {
	die " no indices defined! nothing to do!\n";
}


### Convert to distribution frequency
# Generate a new output data structure
my $out_data_ref = prepare_output_data_structure();
my $out_table_ref = $out_data_ref->{'data_table'}; # quick ref
#print " this is the new output data structure:\n", Dumper($out_data_ref);

# Process each requested index
print " Converting datasets to a distributin frequency....\n";
foreach (@indices) {
	# convert this dataset to the distribution frequency
	my $success = convert_dataset($_);
	unless ($success) {
		die " unable to convert dataset index $_!\n";
	}
}


### Write the new file
unless ($outfile) {
	$outfile = $infile; # use input name
	$outfile =~ s/\.txt(\.gz)?$//; # strip extension
	$outfile .= '_frequency'; # append
}
my $write_results = write_tim_data_file( {
	'data'      => $out_data_ref,
	'filename'  => $outfile,
} );
# report write results
if ($write_results) {
	print "  Wrote new datafile '$write_results'\n";
}
else {
	print "  Unable to write datafile '$outfile'!!!\n";
}




########## Subroutines ###################################



### Ask user for the index
sub ask_for_index {
	
	# present the dataset name list
	print " These are the data sets in the file '$infile'\n";
	foreach (sort {$a <=> $b} keys %dataset_by_id) {
		print "   $_\t$dataset_by_id{$_}\n";
	}
	
	# collect user answer
	print " Enter the dataset indices, separated by comma (x,y) or as range (x-y)\n  ";
	my $answer = <STDIN>; # get user answer
	chomp $answer;
	
	# process the answer
	my @list = parse_list($answer);
	
	# check the answer
	my $check = 1; # assume all are ok
	foreach (@list) {
		unless (exists $dataset_by_id{$_}) {
			# it's not present
			$check = 0;
			last;
		}
	}
	
	# return
	if ($check) {
		return @list;
	}
	else {
		die " At least one index is not valid! Nothing done\n";
	}
}


### Prepare the output tim data structure
sub prepare_output_data_structure {
	
	# generate a new data structure
	my $data = generate_tim_data_structure(
		'distribution_frequency',
		'Bin',
		'Percentage',
	) or die " unable to generate tim data structure!\n";
	
	# add metadata
	$data->{0}{'start'}      = $start;
	$data->{0}{'bin_number'} = $binnumber;
	$data->{0}{'bin_size'}   = $binsize;
	
	
	# Record the bins
	for my $row (1..$binnumber) {
		$data->{'data_table'}->[$row][0] = $bins[$row - 1];
	}
	
	# Generate the percentages
	for (my $i = 1; $i <= $binnumber; $i++) {
		$data->{'data_table'}->[$i][1] = 
			sprintf "%.0f%%", (100 / $binnumber) * $i;
	}
	
	# Return
	return $data;
}


### Convert the dataset
sub convert_dataset {
	my $data_index = shift;
	
	# collect the original values
	my @values;
	for my $i (1..$in_data_ref->{'last_row'}) {
		# walk through the data file
		
		my $value = $in_table_ref->[$i][$data_index];
		
		# only take numerical data
		unless ($value eq '.') {
			push @values, $value; 
		}
	}
	
	# calculate the distribution frequency
	my $stat = Statistics::Descriptive::Full->new() or
		die " can initialize Statistics object!\n";
	$stat->add_data(@values);
	my $freq_ref = $stat->frequency_distribution_ref(\@bins);
		# this should return a reference to a hash where the keys
		# are the values in @bins and the value is the number of 
		# datapoints 
	unless ($freq_ref) {die " frequency distribution not generated from Statistics subroutine!\n"}
	
	#print " this is the frequency structure:\n", Dumper($freq_ref);
	
	# determine the new index
	my $new_index = $out_data_ref->{'number_columns'};
	
	# record the header name
	$out_table_ref->[0][$new_index] = $in_table_ref->[0][$data_index];
	
	# record the distribution in the output data structure
	for my $row (1..$out_data_ref->{'last_row'}) {
		# identify the bin value from the output data
		my $bin = $out_table_ref->[$row][0]; 
		# use this bin value in the lookup of the calculated distribution
		# frequency hash
		$out_table_ref->[$row][$new_index] = $freq_ref->{$bin}; 
	}
	
	# update metada, copy from old data structure
	$out_data_ref->{$new_index} = { %{ $in_data_ref->{$data_index} } };
	$out_data_ref->{$new_index}{'log2'} = 0; # no longer log2
	$out_data_ref->{$new_index}{'index'} = $new_index; # update index
	$out_data_ref->{'number_columns'} += 1;
	
}


__END__

=head1 NAME

data2gff.pl

A script to convert data into a frequency distribution, useful for graphing.

=head1 SYNOPSIS

data2frequency.pl --bins <integer> --size <number> <filename> 
  
  --in <filename>
  --bins <integer>
  --size <number>
  --index <list|range>
  --min <number>
  --max <number>
  --out <filename>
  --version
  --help


=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --in <filename>

Specify the file name of a data file. It must be a tab-delimited text file,
preferably in the tim data format as described in 'tim_data_helper.pm', 
although any format should work. The file may be compressed with gzip.

=item --bins <integer>

Specify the number of bins that the data should be placed into.

=item --size <integer>

Specify the size of each bin.

=item --index <list|range>

Specify the datasets in the input data file to be converted to a distribution.
The 0-based column number of the datasets should be provided. Multiple 
datasets may be provided as a comma-delimited list, as a consecutive list 
(start-stop), or a combination of both. Do not include spaces! If no 
datasets are provided, the program will interactively present to the user 
a list of possible datasets to convert.

=item --min <number>

Optionally indicate the minimum value of the bins. When generating 
the list of bins, this is used as the starting value. Default is 0. 
Useful for log2 distributions where the minimum value is negative. 
A negative number may be provided using the format --min=-1. 

=item --max <number>

Optionally provide the maximum bin value. This argument is optional 
and is automatically calculated as (bins * size). This argument 
may also be provided as an alternative to specifying the binsize 
value, in which case the number of bins is empirically determined.

=item --out <filename>

Specify the output file name. The default is to take the input file base name
and append '_frequency' to it. The file format is a tim data file.

=item --version

Print the version number.

=item --help

Display this help


=back

=head1 DESCRIPTION

This program will convert a datasets in a data file into a distribution. This
may then be used to conveniantly plot a histogram using a program such as 
'graph_profile.pl'.

Set the distribution parameters using the --bins and --binsize arguments, 
which set the number of bins and the size of each bin, respectively. The 
start number and maximum bin value may be optionally set as well.

One or more datasets within the data file may be converted. These may be 
specified on the command line or chosen interactively from a list presented 
to the user.

A tim data text file will be written as output. The bin values are listed 
as the first column, and the number of datapoints within each bin are 
listed in subsequent columns for each dataset requested.


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











