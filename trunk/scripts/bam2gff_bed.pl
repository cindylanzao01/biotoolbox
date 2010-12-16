#!/usr/bin/perl

# a script to convert bam paired_reads to a gff or bed file

use strict;
use Getopt::Long;
use Pod::Usage;
use Bio::DB::Sam;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_data_helper qw(
	format_with_commas
);
use tim_file_helper qw(
	open_to_write_fh
);
eval {
	# check for bigbed file conversion support
	require tim_db_helper::bigbed;
	tim_db_helper::bigbed->import;
};

### Quick help
unless (@ARGV) { 
	# when no command line options are present
	# print SYNOPSIS
	pod2usage( {
		'-verbose' => 0, 
		'-exitval' => 1,
	} );
}


### Command line options
my (
	$infile, 
	$outfile,
	$paired_end,
	$type, 
	$source,
	$gff,
	$bed,
	$bigbed,
	$bb_app_path,
	$gz,
	$help, 
);
GetOptions( 
	'in=s'       => \$infile, # the input bam file path
	'out=s'      => \$outfile, # name of output file 
	'pe'         => \$paired_end, # bam is paired end reads
	'gff'        => \$gff, # output a GFF v.3 file
	'bed'        => \$bed, # ouput a BED file
	'type=s'     => \$type, # the GFF type or method
	'source=s'   => \$source, # GFF source field
	'bigbed|bb'  => \$bigbed, # generate a binary bigbed file
	'bbapp=s'    => \$bb_app_path, # path to bedToBigBed utility
	'gz!'        => \$gz, # gzip the output file
	'help'       => \$help, # request help
);

# Print help
if ($help) {
	# print entire POD
	pod2usage( {
		'-verbose' => 2,
		'-exitval' => 1,
	} );
}



### Check for required values and set defaults
# input file
unless ($infile) {
	if (@ARGV) {
		$infile = shift @ARGV;
	}
	else {
		die "  An input BAM file must be specified!\n";
	}
}
unless ($infile =~ /\.bam$/) {
	die " The input file must be a .bam file!\n";
}

# output type
if ($gff and $bed) {
	die " Can not, must not, specify both GFF and BED simultaneously!\n";
}
unless ($gff or $bed) {
	print " Generating default BED formatted file\n";
	$bed = 1;
}

# set GFF options
if ($gff) {
	unless ($type) {
		# derive the type from the input file name
		$type = $infile;
		$type =~ s/\.bam$//;
		$type =~ s/\.sorted$//;
		if ($paired_end) {
			$type .= '_paired_reads';
		}
		else {
			$type .= '_reads';
		}
	}
	unless ($source) {
		# reasonable, but biased, default
		$source = 'Illumina';
	}
}

# generate default output file name
unless ($outfile) {
	if ($gff) {
		# gff file uses the type
		$outfile = $type;
	}
	else { 
		# bed file simply reuses the input file name
		$outfile = $infile;
		$outfile =~ s/\.bam$//;
		$outfile =~ s/\.sorted$//;
		if ($paired_end) {
			$outfile .= '_paired_reads';
		}
		else {
			$outfile .= '_reads';
		}
	}
}

# default is no compression
unless (defined $gz) {
	$gz = 0;
}
if ($bed and $bigbed and $gz) {
	# enforce no compression if wanting to write bigbed file
	warn " compression not allowed when converting to BigBed format\n";
	$gz = 0; 
}






### Load the BAM file
print " Opening bam file....\n";
my $sam = Bio::DB::Sam->new( 
	-bam        => $infile,
	-autoindex  => 1,
) or die " unable to open bam file '$infile'!\n";




### Open the output file
# check extension
if ($gff) {
	unless ($outfile =~ /\.gff3?$/) {
		$outfile .= '.gff';
	}
}
else {
	unless ($outfile =~ /\.bed$/) {
		$outfile .= '.bed';
	}
}
if ($gz) {
	$outfile .= '.gz';
}

# open handle
my $out = open_to_write_fh($outfile, $gz) or 
		die " unable to open output file '$outfile'!\n";

# write metadata
if ($gff) {
	# print headers for GFF file
	$out->print("##gff_version 3\n");
	$out->print("# Program $0\n");
	$out->print("# Converted from source file $infile\n");
}
else {
	# bed file
	$out->print("# Program $0\n");
	$out->print("# Converted from source file $infile\n");
}


### Initialize global variables
# determine the appropriate callback sub for processing bam alignments
my $callback;
if ($paired_end) {
	$callback = \&process_paired_end;
}
else {
	$callback = \&process_single_end;
}

# determine appropriate output sub for writing data
my $write_feature;
if ($gff) {
	$write_feature = \&write_gff_feature;
}
else {
	$write_feature = \&write_bed_feature;
}

# Initialize output variables
my $data_count = 0;
my @output_data;





### Process the reads
# Loop through the chromosomes
for my $tid (0 .. $sam->n_targets - 1) {
	# each chromosome is internally represented in the bam file as a numeric
	# target identifier
	# we can easily convert this to an actual sequence name
	# we will force the conversion to go one chromosome at a time
	
	# sequence name
	my $seq_id = $sam->target_name($tid);
	print " Converting reads on $seq_id...\n";
	
	# process the reads
	$sam->fetch($seq_id, $callback);
}

# Final write of output
incremental_write_data();

# Finished with output file
print " Wrote " . format_with_commas($data_count) . 
	" features to file '$outfile'.\n";
$out->close;




### Convert to BigBed format
if ($bed and $bigbed) {
	# requested to continue and generate a binary bigbed file
	print " converting to bigbed file....\n";
	
	# check that bigbed conversion is supported
	unless (exists &bed_to_bigbed_conversion) {
		warn "\n  Support for converting to bigbed format is not available\n" . 
			"  Please convert manually. See documentation for more info\n";
		print " finished\n";
		exit;
	}
	
	
	# generate chromosome sizes file from BAM data
	my $chromo_fh = open_to_write_fh('chromosome_sizes.txt');
	for my $tid (0 .. $sam->n_targets - 1) {
		my $seq_id = $sam->target_name($tid);
		my $length = $sam->target_len($tid);
		$chromo_fh->print("$seq_id\t$length\n");
	}
	$chromo_fh->close;
	
	
	# find bedToBigBed utility
	unless ($bb_app_path) {
		# check the system path
		$bb_app_path = `which bedToBigBed` || undef;
		chomp $bb_app_path if $bb_app_path;
	}
	unless ($bb_app_path) {
		warn "\n  Unable to find conversion utility 'bedToBigBed'! Conversion failed!\n" . 
			"  See documentation for more info\n";
		print " Finished\n";
		exit;
	}
		
			
	# perform the conversion
	my $bb_file = bed_to_bigbed_conversion( {
			'bed'       => $outfile,
			'chromo'    => 'chromosome_sizes.txt',
			'bbapppath' => $bb_app_path,
	} );

	
	# confirm
	if ($bb_file) {
		print " BigBed file '$bb_file' generated\n";
		unlink $outfile; # remove the bed file
	}
	else {
		warn " BigBed file not generated! see standard error\n";
	}
	unlink 'chromosome_sizes.txt';
	
}

print " Finished!\n";









########################   Subroutines   ###################################


### Process single end reads
sub process_single_end {
	my $a = shift;
	
	# check alignment
	return if $a->unmapped;
	
	# collect alignment data
	my $seq    = $a->seq_id;
	my $start  = $a->start;
	my $end    = $a->end;
	my $name   = $a->display_name;
	my $strand = $a->strand == 1 ? '+' : '-';
	
	# determine score from the CIGAR string
		# since we're writing a 6-column BED file, we need a score value
		# there is no inherent single score value with the alignment, so we'll 
		# make one up - the percentage of matched bases in the alignment
		# it's a reasonable one to make up
	my $cigar_ref = $a->cigar_array;
	my $match_count = 0;
	foreach (@{ $cigar_ref }) {
		# each element in this array is a reference to a two element array
		# the first element is the CIGAR operation
		# the second element is the count for the operation
		if ($_->[0] eq 'M') {
			# a match operation
			$match_count += $_->[1];
		}
	}
	# calculate the percent match out of the original query length
	# format to whole intergers 0..100
	my $score = int( ( ($match_count / $a->query->length) + 0.005) * 100);
	
	# write out the feature
	&{$write_feature}(
		$seq,
		$start,
		$end,
		$name,
		$score,
		$strand
	);
}



### Process paired end reads
sub process_paired_end {
	my $a = shift;
	
	# check alignment
	return if $a->unmapped;
	return unless $a->proper_pair;
	
	# we only need to process one of the two pairs, 
	# so only take the left (forward strand) read
	return unless $a->strand == 1;
	
	# collect alignment data
	my $seq    = $a->seq_id;
	my $start  = $a->start;
	my $name   = $a->display_name;
	my $isize  = $a->isize; # insert size
	
	# calculate end
		# I occasionally get errors if I call mate_end method
		# rather trust the reported insert size listed in the original bam file
	my $end = $start + $isize - 1;
	
	# write out the feature
	&{$write_feature}(
		$seq,
		$start,
		$end,
		$name,
		$isize, # using insert size as the score value
		'+' # technically no strand, but treat it as forward strand
	);
}



### Write GFF features
sub write_gff_feature {
	
	# passed arguments
		# $seq,
		# $start,
		# $end,
		# $name,
		# $score,
		# $strand
	
	# generate GFF fields
	push @output_data, [ (
		$_[0],
		$source,
		$type,
		$_[1],
		$_[2],
		$_[4],
		$_[5],
		'.', # phase
		"Name=$_[3]"
	) ];
	
	# increment counter
	$data_count += 1;
	
	# periodically write data to file every 5000 lines
	if (scalar(@output_data) == 5000) {
		incremental_write_data();
	}
}


### Write BED features
sub write_bed_feature {
	
	# passed arguments
		# $seq,
		# $start,
		# $end,
		# $name,
		# $score,
		# $strand
	
	# generate BED fields, they're already in bed order
	# also convert to interbase format, per the specification
	push @output_data, [ (
		$_[0],
		$_[1] - 1,
		$_[2],
		$_[3],
		$_[4],
		$_[5]
	) ];
	
	# increment counter
	$data_count += 1;
	
	# periodically write data to file every 5000 lines
	if (scalar(@output_data) == 5000) {
		incremental_write_data();
	}
}



### Periodically write to output file
sub incremental_write_data {
	
	# write the output data
	while (@output_data) {
		my $data_ref = shift @output_data;
		
		# print line
		my $string = join("\t", @{ $data_ref }) . "\n";
		$out->print($string);
	}
}






__END__

=head1 NAME

bam2gff_bed.pl

=head1 SYNOPSIS

bam2gff_bed.pl [--options...] <filename>
  
  Options:
  --in <filename>
  --bed | --gff
  --pe
  --type <text>
  --source <text>
  --out <filename> 
  --bigbed | --bb
  --bbapp </path/to/bedToBigBed>
  --(no)gz
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --in <filename>

Specify the file name of a .bam alignment file. The file should be indexed. 
If not, the program will attempt to automatically index it.

=item --bed | --gff

Specify the output file format. Either a BED file (6-columns) or GFF v.3 
file will be written. The default behavior is to write a BED file.

=item --pe

Indicate that the BAM data is paired end, and that the generated feature 
should represent the insert fragment.

=item --type <text>

For GFF output files, specify the GFF type. The default is to use the 
input file base name, appended with either '_reads' or '_paired_reads'.

=item --source <text>

For GFF output files, specify the source tag. The default is 'Illumina'.

=item --out

Specify the output file name. The default for GFF output files is to use 
the GFF type; for BED output files the input file base name is used. A 
'.bed' extension is added if necessary.

=item --bigbed

=item --bb

When generating a BED formatted output file, optionally indicate that 
a binary BigBed file should be generated instead of a text BED file. 
A .bed file is first generated, then converted to a .bb file, and then 
the .bed file is removed.

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

This program will convert alignments in a BAM formatted file into either a
BED or GFF formatted feature file. For BED output, a 6-column BED file is
generated. For GFF output, a v.3 GFF file is generated. In both cases, the
alignment name, strand, and a score value is recorded.

Both single- and paired-end alignments may be converted. For single-end 
alignments, the generated score is the percent of matched bases (1-100).
For paired-end alignments, the genomic coordinates of the entire insert 
fragment is recorded. The length of the insert is recorded as the score.

For BED files, coordinates are adjusted to interbase format, according to 
the specification.

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












