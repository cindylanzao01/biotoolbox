#!/usr/bin/perl

# a quick and dirty program to print out the feature types in the current database

use strict;
use Pod::Usage;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_db_helper qw(
	open_db_connection
	get_dataset_list
);
my $VERSION = '1.5.8';

print "\n A script to print all available feature types in a database\n\n";


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
	$dbname,
	$help,
	$print_version,
);

# Command line options
GetOptions( 
	'db=s'      => \$dbname, # the database name
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
	print " Biotoolbox script print_feature_types.pl, version $VERSION\n\n";
	exit;
}





# Check for database
unless ($dbname) {
	$dbname = shift @ARGV or 
		die " Must provide a database name!\n";
}



# Initialize
my $count = 0;
my %source2type;

# Get the features
my %types = get_dataset_list($dbname, 'all');
	# this returns a hash where key is a unique number and the value
	# is the actual gff type
	
foreach my $type (values %types) {
	
	# each type is usually comprised of primary_tag:source_tag
	# although sometimes it is just the primary_tag
	
	# get individual tags
	my ($primary, $source);
	if ($type =~ /:/) {
		($primary, $source) = split /:/, $type;
	}
	else {
		$primary = $type;
		$source  = 'NONE';
	}
	
	# store the type in an array under the source
	if (exists $source2type{$source}) {
		push @{ $source2type{$source} }, $primary;
	}
	else {
		$source2type{$source} = [ ($primary) ];
	}
	$count++;
}
print " Found $count feature types in database '$dbname'\n";


# Print the database types by source type
foreach my $source (sort {$a cmp $b} keys %source2type) {
	print "  There are ", scalar @{$source2type{$source}}, " feature types ", 
		"with source '$source'\n";
	foreach (sort {$a cmp $b} @{$source2type{$source}} ) {
		print "     $_\n";
	}
}


print "That's all\n";



__END__

=head1 NAME

print_feature_types.pl

=head1 SYNOPSIS

print_feature_types.pl <database>
  
  --db <database>
  --version
  --help
  

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --db <database>

Specify the name of a Bio::DB::SeqFeature::Store database, or a BigWigSet 
directory.

=item --version

Print the version number.

=item --help

Display this POD documentation.

=back

=head1 DESCRIPTION

This program will print a list of all of the known feature types present 
in a Bio::DB::SeqFeature::Store database. The types are organized into 
groups by their source tag.

BigWigSet databases, comprised of a directory of BigWig files and a 
metadata file, are also supported.

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
