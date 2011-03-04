#!/usr/bin/perl

# This script will add/remove chromosome name prefixes

use strict;
use Getopt::Long;
use Pod::Usage;
use File::Temp qw( tempfile );

# check for Bam support
my $bam_support = 0;
eval {
	require Bio::DB::Sam;
	$bam_support = 1;
};

# biotoolbox library
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_file_helper qw(
	open_to_read_fh
	open_to_write_fh
);


print "\n This program will adjust chromosome names of a data file\n";

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
	$add_chr,
	$strip_chr,
	$do_contigs,
	$prefix,
	$gz,
	$help
);

# Command line options
GetOptions( 
	'in=s'      => \$infile, # the input data file
	'out=s'     => \$outfile, # name of output file 
	'add'       => \$add_chr, # add the prefix
	'strip'     => \$strip_chr, # remove the prefix
	'contig!'   => \$do_contigs, # prefix on contigs too
	'prefix=s'  => \$prefix, # the actual prefix
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
	if ($infile =~ /\.gz$/i) {
		# preserve gzip status of input file
		$gz = 1;
	}
	else {
		# no gzip by default
		$gz = 0;
	}
}

unless ($add_chr or $strip_chr) {
	die " must define an action! add or strip a prefix\n";
}

unless ($prefix) {
	# assign default
	$prefix = 'chr';
}



### Perform the conversions

# required global arguments
my $out_fh; # to be used for output filehandles
my $final_file;
my $time = time;

# convert according to type
if ($infile =~ /\.bam$/i) {
	# a Bam alignment file
	$final_file = process_bam_file($infile, $outfile);
}
elsif ($infile =~ /\.sam(?:\.gz)?$/i) {
	# a Sam file
	$final_file = process_sam_file($infile, $outfile);
}
elsif ($infile =~ /\.g[t|f]f3?(?:\.gz)?$/i) {
	# a GFF file
	$final_file = process_gff_file($infile, $outfile);
}
elsif ($infile =~ /\.bed(?:\.gz)?$/i) {
	# a BED file
	$final_file = process_bed_file($infile, $outfile);
}
elsif ($infile =~ /\.txt(?:\.gz)?$/i) {
	# a text file
	$final_file = process_text_file($infile, $outfile);
}
elsif ($infile =~ /\.fa (?:sta)? (?:\.gz)? \Z/xi) {
	# a fasta file
	$final_file = process_fasta_file($infile, $outfile);
}
else {
	die " unrecognized file format! see documentation for supported files\n";
}

printf " Finished in %.2f minutes! Wrote output file '%s'.\n", 
	( (time - $time) / 60), $final_file ;






########################   Subroutines   ###################################


sub process_bam_file {
	print "\n Processing a Bam file....\n";
	my ($infile, $outfile) = @_;
	
	
	# We can do bam files one of two ways. First, we can take advantage of 
	# of the speed of using a compiled C program, the samtools executable, 
	# and use it to convert to a text sam file, convert the chromosomes there,
	# and roundtrip back to a bam file. Or, we can go through Bio::DB::Sam and 
	# Perl. I tried this initially, but it's painfully slow, even though it 
	# still uses binary C calls to libbam. Especially, writing text sam 
	# alignments back to a bam file, whose execution time can be measured in 
	# days. Ugh. I don't think I'm doing anything wrong, 
	
	# generate bam file name
	unless ($outfile) {
		$outfile = $infile;
		
		# modify the name as appropriate
		if ($add_chr) {
			$outfile =~ s/\.bam$/_chr.bam/i;
		}
		else {
			# strip prefix
			$outfile =~ s/\.bam$/_nochr.bam/i;
		}
	}
	unless ($outfile =~ /\.bam$/) {
		# add extension as necessary
		$outfile .= '.bam';
	}
# 	my $sort_outfile = $outfile;
# 	$sort_outfile =~ s/\.bam$/.sorted/;
	
	# generate a temporary file name
	my (undef, $temp_sam_filename) = tempfile(
		'change_chrXXXXXX', 
		SUFFIX => '.sam', 
		OPEN => 0
	);
	
	my $samtools = `which samtools`; # checking the path
	if ($samtools) {
		# samtools was found in the path, yeah!
		chomp $samtools;
		print "\n Found $samtools, executing....\n";
		
		# first convert to sam
		system ($samtools, 'view', '-h', '-o', $temp_sam_filename, 
			$infile) == 0 or 
			die " could not execute samtools automatically for bam -> sam!\n";
		
		# convert chromosome names in the sam file
		my $converted_sam_file = process_sam_file($temp_sam_filename, undef);
		
		# convert to bam
		system ($samtools, 'view', '-S', '-h', '-b', '-o', $outfile, 
			$converted_sam_file) == 0 or
			die " could not execute samtools automatically for sam -> bam!\n";
		
		# re-sort bam, is this really necessary?
# 		system ($samtools, 'sort', $outfile, $sort_outfile) == 0 or
# 			die " unable to execute samtools sort!\n";
		
		# re-index bam
		system ($samtools, 'index', "$outfile") == 0 or
			die " unable to execute samtools index!\n";
	}
	
	
	
	else {
		# samtools was not found, doing it the long way
		
		
		# check that we have bam support 
		unless ($bam_support) {
			die " Bam files are not supported on this machine.\n" .
				" Please install Bio::DB::Sam for full support\n";
		}
		
		# open Input file
		my $bam = Bio::DB::Sam->new(
				-bam       => $infile, 
				-autoindex => 1,
		) or die " unable to open input Bam file '$infile'!\n";
		
		# get the headers
		my $header = $bam->header();
		my @headers = split(/\n/, $header->text);
		
		# walk through the headers and look for sequence headers 
		for my $i (0 .. $#headers) {
			
			# skip other non-sequence headers
			next unless ($headers[$i] =~ /^\@SQ/);
			
			# process the sequence headers
			$headers[$i] = process_sam_seq_header( $headers[$i] );
		}
		
		# open the temporary TAM file
			# it turns out that the alignment objects generated by reading a 
			# a bam file do not support editing their attributes, including 
			# seq_id name (maybe there is, but it's undocumented)
			# and changing the seq_id names in the header is not enough
			# so, unfortunately, we'll have to make a tedious roundtrip through 
			# a text sam file (TAM) intermediate
		# this is using a global variable to work with the callback sub below
		$out_fh = open_to_write_fh($temp_sam_filename) or 
			die " unable to open temporary sam file!\n";
		
		# print new headers
		$out_fh->print( join("\n", @headers) . "\n");
		
		# now print the alignments to the tam file
		# we will go chromosome by chromosome
		for my $tid (0 .. $bam->n_targets - 1) {
			# each chromosome is internally represented in the bam file as 
			# a numeric target identifier, this can be converted to the 
			# chromosome name
			
			# sequence name
			my $seq_id = $bam->target_name($tid);
			print "  Converting reads on $seq_id...\n";
			
			# process the reads
			$bam->fetch($seq_id, \&process_alignment);
		}
		
		# close the temporary TAM file
		$out_fh->close;
		print " Wrote temporary Sam file $temp_sam_filename.\n " . 
			" Converting back to Bam...";
		
		# now convert the temporary TAM file to a BAM file
		
		# open output bam file
		my $out_bam = Bio::DB::Bam->open($outfile, 'w') or 
			die " unable to open output Bam file '$outfile'!\n";
		
		# open the TAM file
		my $tam = Bio::DB::Tam->open($temp_sam_filename);
		
		# write new headers
		my $new_header = $tam->header_read;
		$out_bam->header_write($new_header);
		
		# start reading the text alignments and write back to the output bam file
			# the tam line parser requires a new object to load into.
			# why can't it build one itself???? sheesh, Lincoln!
		my $alignment = Bio::DB::Bam::Alignment->new();
		while ( $tam->read1($new_header, $alignment) ) {
			# reading one line returns the number of bytes read, use as true value
			
			# write the current alignment to the bam output
			$out_bam->write1($alignment);
			
			# prepare for the next one
			$alignment = Bio::DB::Bam::Alignment->new();
		}	
		
		# close out files
		$out_bam = undef;
		$tam = undef;
	
		# re-sort and re-index the output file
		print " finished writing bam.... \n indexing....\n";
# 		Bio::DB::Bam->sort_core(0, $outfile, $sort_outfile);
		Bio::DB::Bam->index_build($outfile);
	}
	
	unlink $temp_sam_filename;
	return $outfile;
}


sub process_sam_file {
	print "\n Processing a Sam file....\n";
	
	my ($infile, $outfile) = @_;
	
	# open files
	my $in_fh = open_to_read_fh($infile) or 
		die " can't open input file!\n";
	unless ($outfile) {
		# generate output file name
		$outfile = $infile;
		
		# modify the name as appropriate
		if ($add_chr) {
			$outfile =~ s/\.sam (?:\.gz)? \Z/_$prefix.sam/xi;
		}
		else {
			# strip prefix
			$outfile =~ s/\.sam (?:\.gz)? \Z/_no$prefix.sam/xi;
		}
	}
	unless ($outfile =~ /\.sam (?:\.gz)? \Z/xi) {
		# add extension as necessary
		$outfile .= '.sam';
	}
	$out_fh = open_to_write_fh($outfile, $gz) or 
		die " can't open output file '$outfile'!\n";
	
	
	# convert the chromosome names
	while (my $line = $in_fh->getline) {
		
		my $newline;
		
		# check for sequence header lines
		if ($line =~ /^\@SQ/) {
			$newline = process_sam_seq_header($line);
		}
		
		# some other header line
		elsif ($line =~ /^\@/) {
			# no need for processing
			$newline = $line;
		}
		
		# alignment line
		else {
			my @data = split /\t/, $line;
			$data[2] = change_name($data[2]);
			$newline = join("\t", $line);
		}
		
		# write the line to output
		$out_fh->print($newline);
	}
	
	# Finished
	$in_fh->close;
	$out_fh->close;
	return $outfile;
}


sub process_bed_file {
	print "\n Processing a Bed file....\n";
	
	my ($infile, $outfile) = @_;
	
	# open files
	my $in_fh = open_to_read_fh($infile) or 
		die " can't open input file!\n";
	unless ($outfile) {
		# generate output file name
		$outfile = $infile;
		
		# modify the name as appropriate
		if ($add_chr) {
			$outfile =~ s/\.bed (?:\.gz)? \Z/_$prefix.bed/xi;
		}
		else {
			# strip prefix
			$outfile =~ s/\.bed (?:\.gz)? \Z/_no$prefix.bed/xi;
		}
	}
	unless ($outfile =~ /\.bed (?:\.gz)? \Z/xi) {
		# add extension as necessary
		$outfile .= '.bed';
	}
	$out_fh = open_to_write_fh($outfile, $gz) or 
		die " can't open output file '$outfile'!\n";
	
	
	# convert the chromosome names
	while (my $line = $in_fh->getline) {
		
		if ($line =~ /\A#/) {
			# comment lines, leave as is
			$out_fh->print($line);
		}
		elsif ($line =~ /\Atrack/) {
			# track line, leave as is
			$out_fh->print($line);
		}
		else {
			# bed line 
			my @data = split /\t/, $line;
			
			$data[0] = change_name($data[0]);
			
			$out_fh->print( join("\t", @data) );
		}
	}
	$in_fh->close;
	$out_fh->close;
	return $outfile;
}


sub process_gff_file {
	print "\n Processing a GFF file....\n";
	
	my ($infile, $outfile) = @_;
	
	# open files
	my $in_fh = open_to_read_fh($infile) or 
		die " can't open input file!\n";
	unless ($outfile) {
		# generate output file name
		$outfile = $infile;
		
		# modify the name as appropriate
		if ($add_chr) {
			$outfile =~ s/\.g[t|f]f3? (?:\.gz)? \Z/_$prefix/xi;
		}
		else {
			# strip prefix
			$outfile =~ s/\.g[t|f]f3? (?:\.gz)? \Z/_no$prefix/xi;
		}
	}
	unless ($outfile =~ /\.g[t|f]f3? (?:\.gz)? \Z/xi) {
		# add extension as necessary
		if ($infile =~ /(\.g[t|f]f3?) (?:\.gz)? \Z/xi) {
			# add the same extension as the input file
			$outfile .= $1;
		}
	}
	$out_fh = open_to_write_fh($outfile, $gz) or 
		die " can't open output file '$outfile'!\n";
	
	
	# convert the chromosome names
	while (my $line = $in_fh->getline) {
		
		if ($line =~ /\A#/) {
			# comment lines, leave as is
			$out_fh->print($line);
		}
		elsif ($line !~ /\t/) {
			# not a gff line, fasta maybe? skip anyway
			$out_fh->print($line);
		}
		else {
			# gff line 
			my @data = split /\t/, $line;
			
			my $old_chr = $data[0];
			$data[0] = change_name($old_chr);
			
			# check chromosome lines
			if ($data[2] =~ /chromosome/i) {
				# need to change Name and ID tags
				$data[8] =~ s/Name=$old_chr/Name=$data[0]/;
				$data[8] =~ s/ID=$old_chr/ID=$data[0]/;
			}
			
			$out_fh->print( join("\t", @data) );
		}
	}
	$in_fh->close;
	$out_fh->close;
	
	return $outfile;
}


sub process_text_file {
	print "\n Processing a non-standard Text file....\n";
	die "\n currently unsupported! complain to Tim\n";

}


sub process_fasta_file {
	print "\n Processing a Fasta file....\n";
	
	my ($infile, $outfile) = @_;
	
	# open files
	my $in_fh = open_to_read_fh($infile) or 
		die " can't open input file!\n";
	unless ($outfile) {
		# generate output file name
		$outfile = $infile;
		
		# modify the name as appropriate
		if ($add_chr) {
			$outfile =~ s/\.fa (?:sta)? (?:\.gz)? \Z/_$prefix.fa/xi;
		}
		else {
			# strip prefix
			$outfile =~ s/\.fa (?:sta)? (?:\.gz)? \Z/_no$prefix.fa/xi;
		}
	}
	unless ($outfile =~ /\.fa (?:sta)? (?:\.gz)? \Z/xi) {
		# add extension as necessary
		$outfile .= '.fa';
	}
	$out_fh = open_to_write_fh($outfile, $gz) or 
		die " can't open output file '$outfile'!\n";
	
	
	# convert the chromosome definition lines
	while (my $line = $in_fh->getline) {
		if ($line =~ /\A>(\w+)( .+)?([\n\r]+)\z/) { # include line ending
			my $chr = $1;
			my $def = $2;
			my $end = $3;
			my $new_chr = change_name($chr);
			$out_fh->print('>' . $new_chr . $def . $end);
		}
		else {
			$out_fh->print($line);
		}
	}
	
	# finished
	$in_fh->close;
	$out_fh->close;
	return $outfile;
}


sub process_sam_seq_header {
	# subroutine to process a sequence header line from a sam/bam file
	my $line = shift;
	
	# break apart the sequence line
	my @data = split /\t/, $line;
	for my $j (0 .. $#data) {
		if ($data[$j] =~ /^SN:(.+)/) {
			my $new_name = change_name($1);
			
			$data[$j] = "SN:$new_name";
			
			last; # we've done the job, no need to continue
		}
	}
	
	# done
	return join("\t", @data);
}



sub process_alignment {
	# callback subroutine to process alignments
	my $a = shift;
	
	# convert the alignment to text data line, change chromosome, and write
	my @tam_data = split /\t/, $a->tam_line;
	$tam_data[2] = change_name($tam_data[2]);
	$out_fh->print( join("\t", @tam_data) . "\n");
}


sub change_name {
	my $name = shift;
	
	# check whether it looks like a contig
	if ($name =~ /scaffold|contig|NA/i) {
		# it looks like a contig, but it could be named anything
		# only proceed if user requested to process these too
		return $name unless $do_contigs;
	}
	
	# adjust the chromosome name as requested
	if ($add_chr) {
		# we're enforcing a chromosome name of only 1-4 characters
		# anything longer is likely to be not a simple chromosome name
		$name =~ s/\A (\w{1,4}) \Z /$prefix$1/x;
	}
	else {
		# strip
		$name =~ s/\A ${prefix} (.+) \Z /$1/x;
	}
	
	return $name;
}




__END__

=head1 NAME

change_chr_prefix.pl

=head1 SYNOPSIS

change_chr_prefix.pl [--add | --strip] [--options...] <filename>
  
  Options:
  --in <filename>
  --out <filename> 
  --add
  --strip
  --prefix <text>
  --(no)contig
  --(no)gz
  --help


=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --in <filename>

Specify the input file. Supported file types include Bam, Sam, Bed, 
GFF, Fasta, or other tab-delimited text files. Text-based files may be 
compressed with gzip.

=item --out <filename>

Specify the output filename. By default it uses the input base name, 
appended with either _chr or nochr.

=item --add

=item --strip

Specify the renaming action. One or the other must be specified. The add 
action will prefix simple chromosome names (one to four characters) with 
the prefix, while the strip action will remove the offending prefix.

=item --prefix <text>

Specify the chromosome prefix. The default value is 'chr'.

=item --(no)contig

Indicate whether (or not) contig and scaffold names should be included 
in the renaming process. These are recognized by the text 'contig', 
'scaffold', or 'NA' in the name. The default value is false (nocontig).

=item --(no)gz

Specify whether (or not) the output text file should be compressed with gzip.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program will re-name chromosome names in a data file. Supported data 
formats include Bam and Sam alignment files, GFF and BED feature files, 
Fasta sequence files, and any other tab-delimited text files. 

Re-naming consists of either adding or stripping a prefix from the chromosome 
name. Some genome repositories prefix their chromosome names with text, 
most commonly 'chr', while other repositories prefer bare numbers, or 
<gasp!> Roman Numerals. UCSC and Ensembl are two good examples. Mixing 
and matching annotation from different authorities requires matching 
chromosome names.

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
