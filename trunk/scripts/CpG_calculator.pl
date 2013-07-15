#!/usr/bin/env perl

# documentation at end of file

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_data_helper qw(
	generate_tim_data_structure
	find_column_index
);
use tim_db_helper qw(
	open_db_connection
	get_new_genome_list 
);
use tim_file_helper qw(
	load_tim_data_file 
	write_tim_data_file 
);
my $VERSION = '1.12.2';

print "\n This program will calculate observed & expected CpGs\n\n";

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
	$database,
	$window,
	$outfile,
	$gz,
	$help,
	$print_version,
);

# Command line options
GetOptions( 
	'in=s'      => \$infile, # the input data file
	'db|fasta=s'=> \$database, # a SeqFeature::Store database or fasta file
	'win=i'     => \$window, # window size to take
	'out=s'     => \$outfile, # name of output file 
	'gz!'       => \$gz, # compress output
	'help'      => \$help, # request help
	'version'   => \$print_version, # print the version
) or die " unrecognized option(s)!! please refer to the help documentation\n\n";

# Print help
if ($help) {
	# print entire POD
	pod2usage( {
		'-verbose' => 2,
		'-exitval' => 1,
	} );
}

# Print version
if ($print_version) {
	print " Biotoolbox script CpG_calculator.pl, version $VERSION\n\n";
	exit;
}



### Check for requirements
unless ($database) {
	die " no database or fasta file given! use --help for more information\n";
}
unless ($window) {
	# default window size
	# could get from biotoolbox.cfg but I'm lazy right now
	$window = 1000;
	unless ($infile) {
		# print the obligatory default statement if no input file 
		print " using default window size of $window bp\n";
	}
}
if (!$infile and !$outfile) {
	die " must define an output file name!\n";
}
unless (defined $gz) {
	$gz = 0;
}




### Open the database
my $db = open_db_connection($database) or 
		die " unable to open database connection!\n";
my $db_ref = ref $db;
unless ($db_ref =~ /SeqFeature|Fasta/) {
	die " unsupported database type $db_ref!\n";
}




### Prepare the main data structure
my $data;
if ($infile) {
	# an input file of regions is provided
	$data = load_tim_data_file($infile) or 
		die " unable to open input file '$infile'!\n";
}
else {
	# make a new genome list based on the type of database we're using
	if ($database) {
		# get the list from the database
		$data = get_new_genome_list(
			'db'   => $db,
			'win'  => $window,
		) or die " unable to generate genome window list!\n";
	}
	else {
		# working with a fasta db
		# custom subroutine
		$data = get_genome_list_from_fasta_db();
	}
}




### Process regions
print " Processing regions....\n";
my $start_time = time;
process_regions();




### Finished
unless ($outfile) {
	# re-use the input file basename, no path
	$outfile = $data->{'basename'};
}

my $written_file = write_tim_data_file(
	# we will write a tim data file
	# appropriate extensions and compression should be taken care of
	'data'     => $data,
	'filename' => $outfile,
);
if ($written_file) {
	print " Wrote data file '$written_file' ";
}
else {
	print " unable to write data file! ";
}
printf "in %.2f minutes\n", (time - $start_time) / 60;




########################   Subroutines   ###################################


sub identify_indices {
	
	# the indices to identify
	my ($chrom, $start, $stop);
	
	# check obvious indices
	if ($data->{'gff'}) {
		$chrom = 0;
		$start = 3;
		$stop  = 4;
	}
	elsif ($data->{'bed'}) {
		$chrom = 0;
		$start = 1;
		$stop  = 2;
	}
	elsif ($data->{'program'} eq $0) {
		# genome data generated by this program
		$chrom = 0;
		$start = 1;
		$stop  = 2;
	}
	else {
		# custom tim data file
		$chrom = find_column_index($data, '^chr|seq|ref|id');
		$start = find_column_index($data, '^start');
		$stop  = find_column_index($data, '^stop|end');
	
		# check
		unless (defined $chrom and defined $start and defined $stop) {
			die " unable to identify one or more coordinate column indices!\n";
		}
	}
	
	return ($chrom, $start, $stop);
}


sub process_regions {
	
	# Identify the indices
	my ($chr_i, $start_i, $stop_i) = identify_indices();
	
	# Add new columns
	# Fraction gc
	my $fgc_i = $data->{'number_columns'};
	$data->{$fgc_i} = {
		'name'   => 'Fraction_GC',
		'index'  => $fgc_i,
	};
	$data->{'number_columns'} += 1;
	
	# number of CpG
	my $cg_i = $data->{'number_columns'};
	$data->{$cg_i} = {
		'name'   => 'Number_CpG',
		'index'  => $cg_i,
	};
	$data->{'number_columns'} += 1;
	
	# expected number of CpG
	my $exp_i = $data->{'number_columns'};
	$data->{$exp_i} = {
		'name'   => 'Expected_CpG',
		'index'  => $exp_i,
	};
	$data->{'number_columns'} += 1;
	
	# observed/expected ratio
	my $oe_i = $data->{'number_columns'};
	$data->{$oe_i} = {
		'name'   => 'Obs_Exp_Ratio',
		'index'  => $oe_i,
	};
	$data->{'number_columns'} += 1;
	
	# add column header names
	foreach ($fgc_i, $cg_i, $exp_i, $oe_i) { 
		$data->{'data_table'}->[0][$_] = $data->{$_}{'name'};
	}
	
	
	# Process the regions
	for (my $row = 1; $row <= $data->{'last_row'}; $row++) {
		
		# get the region subsequence
		my $seq = $db->seq(
			$data->{'data_table'}->[$row][$chr_i],
			$data->{'data_table'}->[$row][$start_i],
			$data->{'data_table'}->[$row][$stop_i] + 1,
			# we add 1 bp so that we can count CpG that cross a window border
		);
		unless ($seq) {
			# this may happen if 0 or >1 chromosomes match the name
			# or possibly coordinates are off the end, although I thought this was 
			# checked by the db adaptor
			warn "No sequence for segment " . 
				$data->{'data_table'}->[$row][$chr_i] . ":" .
				$data->{'data_table'}->[$row][$start_i] . ".." .
				$data->{'data_table'}->[$row][$stop_i] . " at row $row, skipping.\n";
			
			# fill out null data
			$data->{'data_table'}->[$row][$fgc_i] = '.';
			$data->{'data_table'}->[$row][$cg_i]  = '.';
			$data->{'data_table'}->[$row][$exp_i] = '.';
			$data->{'data_table'}->[$row][$oe_i]  = '.';
			next;
		}
		
		# count frequencies
		# we could use the transliterate tr function to count single 
		# nucleotides quite efficiently, but it will NOT count dinucleotides
		# therefore, we will use the slightly more intensive approach of using 
		# substr to march through the sequence and count
		my $numC  = 0;
		my $numG  = 0;
		my $numCG = 0;
		for (my $i = 0; $i < length($seq) - 1; $i++) {
			my $dinuc = substr($seq, $i, 2);
			$numC  += 1 if $dinuc =~ m/^c/i;
			$numG  += 1 if $dinuc =~ m/^g/i;
			$numCG += 1 if $dinuc =~ m/^cg/i;
		}
		
		# record the statistics
		# we subtract 1 from the length because we added 1 when we generated the seq
		if (length($seq) > 1) {
			# must have reasonable length to avoid div by 0 errors
			$data->{'data_table'}->[$row][$fgc_i] = 
				sprintf "%.3f", ($numC + $numG) / (length($seq) - 1); # fraction GC
		
			$data->{'data_table'}->[$row][$cg_i]  = $numCG; # number CpG
		
			$data->{'data_table'}->[$row][$exp_i] = 
				sprintf "%.0f", ($numC * $numG) / (length($seq) - 1); # expected CpG
		
			$data->{'data_table'}->[$row][$oe_i]  = 
				$data->{'data_table'}->[$row][$exp_i] ? # avoid div by 0
				sprintf("%.3f", $numCG / $data->{'data_table'}->[$row][$exp_i]) : 
				0; # obs/exp ratio
		}
		else {
			# a sequence of 1 bp? odd, just record default values
			$data->{'data_table'}->[$row][$fgc_i] = 0;
			$data->{'data_table'}->[$row][$cg_i]  = $numCG; # number CpG
			$data->{'data_table'}->[$row][$exp_i] = 0;
			$data->{'data_table'}->[$row][$oe_i]  = 0;
		}
	}
	
}


__END__

=head1 NAME

CpG_calculator.pl

A script to calculate observed vs expected CpG dinucleotides

=head1 SYNOPSIS

CpG_calculator.pl --fasta <directory|filename> [--options...]

CpG_calculator.pl --db <text> [--options...]
  
  Options:
  --db <name|file|directory>
  --in <filename>
  --win <integer>
  --out <filename> 
  --gz
  --version
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --db <name|file|directory>

Provide the name of a Bio::DB::SeqFeature::Store database from which to 
collect the genomic sequence. A relational database name, SQLite file, or 
GFF3 file with sequence may be provided. Alternatively, provide the name 
of an uncompressed Fasta file (multi-fasta is ok) or directory containing 
multiple fasta files representing the genomic sequence. The directory 
must be writeable for a small index file to be written. Required.

=item --in <filename>

Optionally specify an input file representing a list of regions to 
analyze. If not provided, then the entire genome will be scanned using 
the specified window size. Supported formats include BED, GFF, and tab 
delimited text files with column headers (chromosome, start, and stop
columns must be present and labeled as such or similarly). The file may 
be compressed with gzip.

=item --win <integer>

Optionally provide the window size in bp with which to scan the genome. 
Option is ignored if an input file is provided. Default is 1000 bp.

=item --out <filename>

Specify the output filename. By default it uses the input file base 
name if provided. Required if no input file is provided.

=item --gz

Specify whether (or not) the output file should be compressed with gzip.

=item --version

Print the version number.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program will calculate percent GC composition, number of CpG 
dinucleotide pairs, number of expected CpG dinucleotide pairs based 
on GC content, and the ratio of observed / expected CpG pairs. 
Calculations are performed on either windows across the entire genome 
(default behavior using 1000 bp windows) or user-provided regions in an 
input file (BED, GFF, or custom text file are supported). 

Genomic sequence may be provided in two ways. First, a Fasta file or 
directory of Fasta files may be provided. A small index file will be 
written to assist in random access using the Bio::DB::Fasta module. 
Alternatively, a Bio::DB::SeqFeature::Store database with sequence may 
be provided. Depending on the database driver and implementation, the 
fasta option is usually faster.

The four additional columns of information are appended to the input 
or generated file.

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
