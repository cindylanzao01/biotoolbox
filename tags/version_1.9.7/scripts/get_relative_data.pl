#!/usr/bin/perl

# A script to map data around a feature start position

use strict;
use Pod::Usage;
use Getopt::Long;
use Statistics::Lite qw(mean median sum stddevp min max);
use FindBin qw($Bin);
use lib "$Bin/../lib";
use tim_data_helper qw(
	find_column_index
	format_with_commas
);
use tim_db_helper qw(
	open_db_connection
	verify_or_request_feature_types
	get_new_feature_list
	get_region_dataset_hash
	get_chromo_region_score
	check_dataset_for_rpm_support
);
use tim_file_helper qw(
	load_tim_data_file
	write_tim_data_file
	write_summary_data
);
my $VERSION = '1.9.4';

print "\n A script to collect windowed data flanking a relative position of a feature\n\n";
  

### Quick help
unless (@ARGV) { # when no command line options are present
	# when no command line options are present
	# print SYNOPSIS
	pod2usage( {
		'-verbose' => 0, 
		'-exitval' => 1,
	} );
}


### Get command line options and initialize values

## Initialize values
my (
	$infile, 
	$outfile, 
	$main_database, 
	$data_database,
	$dataset, 
	$feature, 
	$value_type,
	$method,
	$win, 
	$number,
	$position, 
	$strand_sense,
	$set_strand,
	$avoid,
	$long_data,
	$smooth,
	$sum,
	$log,
	$gz,
	$help,
	$print_version,
); # command line variables

## Command line options
GetOptions( 
	'out=s'      => \$outfile, # output file name
	'in=s'       => \$infile, # input file name
	'db=s'       => \$main_database, # main or annotation database name
	'ddb=s'      => \$data_database, # data database
	'data=s'     => \$dataset, # dataset name
	'feature=s'  => \$feature, # type of feature
	'value=s'    => \$value_type, # the type of data to collect
	'method=s'   => \$method, # method to combine data
	'window=i'   => \$win, # window size
	'number=i'   => \$number, # number of windows
	'position=s' => \$position, # indicate relative location of the feature
	'strand=s'   => \$strand_sense, # collected stranded data
	'force_strand|set_strand' => \$set_strand, # enforce an artificial strand
				# force_strand is preferred option, but respect the old option
	'avoid!'     => \$avoid, # avoid conflicting features
	'long!'      => \$long_data, # collecting long data features
	'smooth!'    => \$smooth, # smooth by interpolation
	'sum!'       => \$sum, # generate average profile
	'log!'       => \$log, # data is in log2 space
	'gz!'        => \$gz, # compress the output file
	'help'       => \$help, # print help
	'version'    => \$print_version, # print the version
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
	print " Biotoolbox script map_data.pl, version $VERSION\n\n";
	exit;
}






## Check for required values
unless ($main_database or $infile) {
	die " You must define a database or input file!\n Use --help for more information\n";
}

unless ($outfile) {
	if ($infile) {
		$outfile = $infile;
	}
	else {
		die " You must define an output filename !\n Use --help for more information\n";
	}
}
$outfile =~ s/\.txt$//; # strip extension, we'll add it later

unless ($feature or $infile) {
	die " You must define a feature or use an input file!\n Use --help for more information\n";
}

unless ($win) {
	print " Using default window size of 50 bp\n";
	$win = 50;
}

unless ($number) {
	print " Using default window number of 20 per side\n";
	$number = 20;
}

unless (defined $log) {
	# default is to assume not log2
	$log = 0;
}

if (defined $value_type) {
	# check the region method or type of data value to collect
	unless (
			$value_type eq 'score' or
			$value_type eq 'length' or
			$value_type eq 'count'
	) {
		die " Unknown data value '$value_type'!\n " . 
			"Use --help for more information\n";
	}
}
else {
	# default is to take the score
	$value_type = 'score';
}

if (defined $method) {
	# check the requested method
	unless (
			$method eq 'mean' or
			$method eq 'median' or
			$method eq 'sum' or
			$method eq 'min' or
			$method eq 'max' or
			$method eq 'stddev' or
			$method eq 'rpm'
	) {
		die " Unknown method '$method'!\n Use --help for more information\n";
	}
	
	if ($method eq 'rpm') {
		# make sure we collect the right values
		$value_type = 'count';
	}
}
else {
	# set default method
	if ($value_type eq 'count') {
		$method = 'sum';
	}
	else {
		$method = 'mean';
	}
}

if (defined $position) {
	# check the position value
	unless (
		$position == 5 or
		$position == 3 or
		$position == 4 or
		$position eq 'm'
	) {
		die " Unknown relative position '$position'!\n";
	}
	if ($position eq 'm') {$position = 4} # change to match internal usage
}
else {
	# default position to use the 5' end
	$position = 5;
}

if (defined $strand_sense) {
	unless (
		$strand_sense eq 'sense' or
		$strand_sense eq 'antisense' or
		$strand_sense eq 'all'
	) {
		die " Unknown strand value '$strand_sense'!\n";
	}
}
else {
	# default
	$strand_sense = 'all';
}

unless (defined $sum) {
	# assume to write a summary file, nearly always want this, at least I do
	$sum = 1;
}

my $start_time = time;




## Generate or load the input dataset
my $main_data_ref; # a reference to the main data structure
if ($infile) {
	# load the gene dataset from existing file
	print " Loading feature set from file $infile....\n";
	$main_data_ref = load_tim_data_file($infile);
	
	# update program name
	unless ($main_data_ref->{'program'} eq $0) {
		$main_data_ref->{'program'} = $0;
	}
} 
else {
	# we will start a new file with a new dataset
	generate_a_new_feature_dataset();
}
unless ($main_data_ref) {
	# check for data
	die " No data loaded! Nothing to do!\n";
}

# simple reference to the data table
my $data_table_ref = $main_data_ref->{'data_table'};

# the number of columns already in the data array
my $startcolumn = $main_data_ref->{'number_columns'}; 





## Collect the data

# Open main database connection
unless ($main_database) {
	# define the database 
	if ( $main_data_ref->{'db'} ) {
		# from the input file if possible
		$main_database = $main_data_ref->{'db'};
	}
	elsif ($dataset) {
		# or use the dataset if possible
		$main_database = $dataset;
	}
	else {
		die " You must define a database or dataset!\n" . 
			" Use --help for more information\n";
	}
}
my $mdb = open_db_connection($main_database);
unless ($mdb) {
	die " You must define a database or dataset!\n" . 
		" Use --help for more information\n";
}

# Open data database
my $ddb;
if (defined $data_database) {
	# specifically defined a data database
	$ddb = open_db_connection($data_database) or 
		die "unable to establish data database connection to $data_database!\n";
}
else {
	# reuse the main database connection
	$ddb = $mdb;
}

# Check the dataset
$dataset = verify_or_request_feature_types( {
	'db'      => $ddb,
	'feature' => $dataset,
	'single'  => 1,
	'prompt'  => " Enter the number of the feature or dataset from which to" . 
					" collect data   ",
} );

# Check the RPM method if necessary
my $rpm_read_sum;
if ($method eq 'rpm') {
	print " Checking RPM support for dataset '$dataset'...\n";
	$rpm_read_sum = check_dataset_for_rpm_support($dataset, $ddb);
	if ($rpm_read_sum) {
		printf " %s total features\n", format_with_commas($rpm_read_sum);
	}
	else {
		die " RPM method not supported! Try something else\n";
	}
}


# Collect the relative data
map_relative_data();



## Interpolate values
if ($smooth) {
	print " Interpolating missing values....\n";
	go_interpolate_values();
}
# convert null values to zero if necessary
if ($method eq 'sum' or $method eq 'rpm') {
	null_to_zeros();
}


## Generate summed data - 
# an average across all features at each position suitable for plotting
if ($sum) {
	print " Generating final summed data....\n";
	my $sumfile = write_summary_data( {
		'data'        => $main_data_ref,
		'filename'    => $outfile,
		'startcolumn' => $startcolumn,
		'dataset'     => $dataset,
		'log'         => $log,
	} );
	if ($sumfile) {
		print " Wrote summary file '$sumfile'\n";
	}
	else {
		print " Unable to write summary file!\n";
	}
}



## Output the data
# reset the program metadata
$main_data_ref->{'program'} = $0;

# we will write a standard tim data file
# appropriate extensions and compression should be taken care of
my $written_file = write_tim_data_file( {
	'data'     => $main_data_ref,
	'filename' => $outfile,
	'gz'       => $gz,
} );
if ($written_file) {
	# success!
	print " wrote file $written_file\n";
}
else {
	# failure! the subroutine will have printed error messages
	print " unable to write output file!\n";
}


## Conclusion
printf " Completed in %.1f minutes\n", (time - $start_time)/60;





#### Subroutines #######

## generate a feature dataset if one was not loaded
sub generate_a_new_feature_dataset {
	# a subroutine to generate a new feature dataset
	
	$main_data_ref = get_new_feature_list( {
			'db'       => $main_database,
			'features' => $feature,
	} );
	
	# set the current program
	$main_data_ref->{'program'} = $0;
}



## Prepare columns for each window
sub prepare_window_datasets {
	
	# Determine starting and ending points
	my $startingpoint = 0 - ($win * $number); 
		# default values will give startingpoint of -1000
	my $endingpoint = $win * $number; 
		# likewise default values will give endingpoint of 1000
	
	# Print collection statement
	print " Collecting ";
	if ($log) { 
		print "log2 ";
	}
	print "data from $startingpoint to $endingpoint at the ";
	if ($position == 3) {
		print "3' end"; 
	}
	elsif ($position == 4) {
		print "midpoint";
	}
	else {
		print "5' end";
	}
	print " in $win bp windows...\n";
	
	# Prepare and annotate the header names and metadata
	for (my $start = $startingpoint; $start < $endingpoint; $start += $win) {
		# we will be progressing from the starting to ending point
		# in increments of window size
		
		# set the stop position
		my $stop = $start + $win - 1;
		
		# deal with the pesky 0 value
		# since we're working with 1-base coordinates, we don't really have 
		# a real 0 coordinate, so need to skip it as it doesn't really exist
		my $zero_check;
		for my $i ($start .. $stop) {
			$zero_check = 1 if $i == 0;
		}
		if ($zero_check) {
			# adjust the coordinates accordingly
			if ($start == 0) {
				$start += 1;
				$stop += 1;
			}
			elsif ($stop == 0) {
				$stop += 1;
			}
			else {
				# some number in between
				$stop += 1;
			}
		}
		
		# set the new index value, which is equivalent to the number of columns
		my $new_index = $main_data_ref->{'number_columns'};
		
		# the new name
		my $new_name = $start . '..' . $stop;
		
		# set the metadata
		my %metadata = (
			'name'        => $new_name,
			'index'       => $new_index,
			'start'       => $start,
			'stop'        => $stop,
			'window'      => $win,
			'log2'        => $log,
			'dataset'     => $dataset,
			'method'      => $method,
			'value'       => $value_type,
		);
		if ($position == 5) {
			$metadata{'relative_position'} = '5prime_end';
		}
		elsif ($position == 3) {
			$metadata{'relative_position'} = '3prime_end';
		}
		else { # midpoint
			$metadata{'relative_position'} = 'center';
		}
		if ($set_strand) {
			$metadata{'strand_implied'} = 1;
		}
		if ($strand_sense =~ /sense/) {
			$metadata{'strand'} = $strand_sense;
		}
		if ($data_database) {
			$metadata{'db'} = $data_database;
		}
		$main_data_ref->{$new_index} = \%metadata;
		
		# set the column header
		$data_table_ref->[0][$new_index] = $new_name;
		
		# update number of columns
		$main_data_ref->{'number_columns'} += 1;
	}
	
	return ($startingpoint, $endingpoint);
}



## Collect the nucleosome occupancy data
sub map_relative_data {
	
	# Add the columns for each window 
	# and calculate the relative starting and ending points
	my ($starting_point, $ending_point) = prepare_window_datasets();
	
	
	
	# Identify columns for feature identification
	my $name = find_column_index($main_data_ref, '^name|id');
	
	my $type = find_column_index($main_data_ref, '^type|class');
	
	my $chromo = find_column_index($main_data_ref, '^chr|seq|ref|ref.?seq');
	
	my $start = find_column_index($main_data_ref, '^start|position');
	
	my $stop = find_column_index($main_data_ref, '^stop|end');
	
	my $strand = find_column_index($main_data_ref, '^strand');
	
	
	
	# Select the appropriate method for data collection
	if (
		defined $name and
		defined $type and 
		not $long_data
	) {
		# mapping point data features using named features
		map_relative_data_for_features(
			$starting_point, $ending_point, $name, $type, $strand);
	}
	
	elsif (
		defined $name and
		defined $type and 
		$long_data
	) {
		# mapping long data features using named features
		map_relative_long_data_for_features($name, $type, $strand);
	}
	
	elsif (
		defined $start and
		defined $stop  and
		defined $chromo and
		not $long_data
	) {
		# mapping point data features using genome segments
		map_relative_data_for_regions(
			$starting_point, $ending_point, $chromo, $start, $stop, $strand);
	}
	
	elsif (
		defined $start and
		defined $stop  and
		defined $chromo and
		$long_data
	) {
		# mapping long data features using genome segments
		map_relative_long_data_for_regions($chromo, $start, $stop, $strand);
	}
	
	else {
		die " Unable to identify columns with feature identifiers!\n" .
			" File must have Name and Type, or Chromo, Start, Stop columns\n";
	}
	
}


sub map_relative_data_for_features {
	
	# Get the feature indices
	my (
		$starting_point, 
		$ending_point, 
		$name_index, 
		$type_index, 
		$strand_index
	) = @_;
	
	
	### Collect the data
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		# collect the region scores
		my %regionscores = get_region_dataset_hash( {
				'db'          => $mdb,
				'ddb'         => $ddb,
				'dataset'     => $dataset,
				'name'        => $data_table_ref->[$row][$name_index],
				'type'        => $data_table_ref->[$row][$type_index],
				'start'       => $starting_point,
				'stop'        => $ending_point,
				'position'    => $position,
				'value'       => $value_type,
				'stranded'    => $strand_sense,
				'set_strand'  => $set_strand ? 
								$data_table_ref->[$row][$strand_index] : undef, 
				'avoid'       => $avoid,
		} );
		
		# record the scores
		record_scores($row, \%regionscores);
		
	}
}



sub map_relative_long_data_for_features {
	
	# Get the feature indices
	my (
		$name_index, 
		$type_index, 
		$strand_index
	) = @_;
	
	
	### Collect the data
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		# Get the feature from the database
		my @features = $mdb->features( 
				-name => $data_table_ref->[$row][$name_index],
				-type => $data_table_ref->[$row][$type_index],
		);
		if (scalar @features > 1) {
			# there should only be one feature found
			# if more, there's redundant or duplicated data in the db
			# warn the user, this should be fixed
			warn " Found more than one " . 
				$data_table_ref->[$row][$type_index] . " features" .  
				" named " . $data_table_ref->[$row][$name_index] . 
				" in the database!\n Using the first feature only!\n";
		}
		elsif (!@features) {
			warn " Found no " . 
				$data_table_ref->[$row][$type_index] . " features" .
				" named " . $data_table_ref->[$row][$name_index] . 
				" in the database!\n";
			
			# record a null values
			for (
				my $column = $startcolumn; 
				$column < $main_data_ref->{'number_columns'}; 
				$column++
			) {
				$data_table_ref->[$row][$column] = '.';
			}
			
			# move on
			next;
		}
		my $feature = shift @features; 
		
		
		# Collect the scores for each window
		collect_long_data_window_scores(
			$row,
			$feature->seq_id,
			$feature->start,
			$feature->end,
			$set_strand ? 
				$data_table_ref->[$row][$strand_index] : $feature->strand
		);
	}
}

sub map_relative_data_for_regions {
	
	# Get the feature indices
	my (
		$starting_point, 
		$ending_point, 
		$chr_index, 
		$start_index, 
		$stop_index, 
		$strand_index
	) = @_;
	
	
	### Collect the data
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		# collect the given coordinates from the data table
		my ($fstart, $fstop, $strand);
		if (
			$data_table_ref->[$row][$start_index] <= 
			$data_table_ref->[$row][$stop_index]
		) {
			# proper orientation
			$fstart = $data_table_ref->[$row][$start_index];
			$fstop  = $data_table_ref->[$row][$stop_index];
			
			# set the strand if not defined
			unless (defined $strand_index) {
				$strand = 1;
			}
		}
		else {
			# not a proper orientation of values
			# assume the user really meant this
			$fstart = $data_table_ref->[$row][$stop_index];
			$fstop  = $data_table_ref->[$row][$start_index];
			
			# set the strand if not defined
			unless (defined $strand_index) {
				$strand = -1;
			}
		}
			
		# determine strand
		if (defined $strand_index) {
			# the strand in the data table could be any one of several 
			# characters denoting strand
			if ($data_table_ref->[$row][$strand_index] =~ m/^[1|f|w|\+]/i) {
				$strand = 1;
			}
			elsif ($data_table_ref->[$row][$strand_index] =~ m/^[r|c|\-]/i) {
				$strand = -1;
			}
			else {
				$strand = 0;
			}
		}
		else {
			$strand = 0 unless defined $strand;
		}
		
		
		
		# calculate new coordinates based on relative adjustments
			# this is a little tricky, because we're working with absolute 
			# coordinates but we want relative coordinates, so we must do 
			# the appropriate conversions
		my ($start, $stop, $region_start);
		
		if ($strand >= 0 and $position == 5) {
			# 5' end of forward strand
			$region_start = $fstart;
			$start = $fstart + $starting_point;
			$stop  = $fstart + $ending_point;
		}
		
		elsif ($strand == -1 and $position == 5) {
			# 5' end of reverse strand
			$region_start = $fstop;
			$start = $fstop - $ending_point;
			$stop  = $fstop - $starting_point;
		}
		
		elsif ($strand >= 0 and $position == 3) {
			# 3' end of forward strand
			$region_start = $fstop;
			$start = $fstop + $starting_point;
			$stop  = $fstop + $ending_point;
		}
		
		elsif ($strand == -1 and $position == 3) {
			# 3' end of reverse strand
			$region_start = $fstart;
			$start = $fstart - $ending_point;
			$stop  = $fstart - $starting_point;
		}
		
		elsif ($position == 4) {
			# midpoint regardless of strand
			$region_start = int( ( ($fstop - $fstart) / 2) + 0.5);
			$start = $region_start + $starting_point;
			$stop  = $region_start + $ending_point;
		}
		
		else {
			# something happened
			die " programming error!? feature " . 
				" at data row $row\n";
		}
		
		# collect the region scores
		my %regionscores = get_region_dataset_hash( {
				'db'          => $ddb,
				'dataset'     => $dataset,
				'chromo'      => $data_table_ref->[$row][$chr_index],
				'start'       => $start,
				'stop'        => $stop,
				'strand'      => $strand,
				'value'       => $value_type,
				'stranded'    => $strand_sense,
		} );
		
		# convert the regions scores back into relative scores
		my %relative_scores;
		foreach my $position (keys %regionscores) {
			$relative_scores{ $position + $starting_point } = 
				$regionscores{$position};
		}
		
		# record the scores
		record_scores($row, \%relative_scores);
		
	}
}



sub map_relative_long_data_for_regions {
	
	# Get the feature indices
	my (
		$chr_index, 
		$start_index, 
		$stop_index, 
		$strand_index
	) = @_;
	
	
	### Collect the data
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		# collect the given coordinates from the data table
		my ($fstart, $fstop, $fstrand);
		if (
			$data_table_ref->[$row][$start_index] <= 
			$data_table_ref->[$row][$stop_index]
		) {
			# proper orientation
			$fstart = $data_table_ref->[$row][$start_index];
			$fstop  = $data_table_ref->[$row][$stop_index];
			
			# set the strand if not defined
			unless (defined $strand_index) {
				$fstrand = 1;
			}
		}
		else {
			# not a proper orientation of values
			# assume the user really meant this
			$fstart = $data_table_ref->[$row][$stop_index];
			$fstop  = $data_table_ref->[$row][$start_index];
			
			# set the strand if not defined
			unless (defined $strand_index) {
				$fstrand = -1;
			}
		}
			
		# determine strand
		if (defined $strand_index) {
			# the strand in the data table could be any one of several 
			# characters denoting strand
			if ($data_table_ref->[$row][$strand_index] =~ m/^[1|f|w|\+]/i) {
				$fstrand = 1;
			}
			elsif ($data_table_ref->[$row][$strand_index] =~ m/^[r|c|\-]/i) {
				$fstrand = -1;
			}
			else {
				$fstrand = 0;
			}
		}
		else {
			$fstrand = 0 unless defined $fstrand;
		}
		
		
		# Collect the scores for each window
		collect_long_data_window_scores(
			$row,
			$data_table_ref->[$row][$chr_index],
			$fstart,
			$fstop,
			$fstrand,
		);
	}
	
}



sub record_scores {
	
	# get the collected raw scores
	my ($row, $regionscores) = @_;
	
	
	# assign the scores to the windows in the region
	for (
		# we will process each window one at a time
		# proceed by the column index for each window
		my $column = $startcolumn; 
		$column < $main_data_ref->{'number_columns'}; 
		$column++
	) {
		# get start and stop
		my $start = $main_data_ref->{$column}{'start'};
		my $stop = $main_data_ref->{$column}{'stop'};
		
		# collect a score at each position in the window
		my @scores;
		for (my $n = $start; $n <= $stop; $n++) {
			# we will walk through the window one bp at a time
			# look for a score associated with the position
			push @scores, $regionscores->{$n} if exists $regionscores->{$n};
		}
		
		# deal with log scores if necessary
		if ($log) {
			@scores = map { 2 ** $_ } @scores;
		}
		
		# calculate the combined score for the window
		my $winscore;
		if (@scores) {
			# we have scores, so calculate a value based on the method
			
			if ($method eq 'mean') {
				$winscore = mean(@scores);
			}
			elsif ($method eq 'median') {
				$winscore = median(@scores);
			}
			elsif ($method eq 'stddev') {
				$winscore = stddevp(@scores);
			}
			elsif ($method eq 'sum') {
				$winscore = sum(@scores);
			}
			elsif ($method eq 'min') {
				$winscore = sum(@scores);
			}
			elsif ($method eq 'max') {
				$winscore = sum(@scores);
			}
			elsif ($method eq 'rpm') {
				$winscore = ( sum(@scores) * 1000000 ) / $rpm_read_sum;
			}
			
			# deal with log2 scores
			if ($log) { 
				# put back in log2 space if necessary
				$winscore = log($winscore) / log(2);
			}
		}
		else {
			# no scores
			# assign a "null" value
			$winscore = '.';
		}
		
		# put the value into the data table
		# we're using a push function instead of explicitly assigning 
		# a position, since the loop is based on relative genomic 
		# position rather than 
		$data_table_ref->[$row][$column] = $winscore;
	}

}



## Collecting long data in windows
sub collect_long_data_window_scores {
	
	# passed row index and coordinates
	my (
		$row,
		$fchromo,
		$fstart,
		$fstop,
		$fstrand
	) = @_;

	# Translate the actual reference start position based on requested 
	# reference position and region strand
	my $reference;
	if ($fstrand >= 0 and $position == 5) {
		# 5' end of forward strand
		$reference = $fstart;
	}
	
	elsif ($fstrand == -1 and $position == 5) {
		# 5' end of reverse strand
		$reference = $fstop;
	}
	
	elsif ($fstrand >= 0 and $position == 3) {
		# 3' end of forward strand
		$reference = $fstop;
	}
	
	elsif ($fstrand == -1 and $position == 3) {
		# 3' end of reverse strand
		$reference = $fstart;
	}
	
	elsif ($position == 4) {
		# midpoint regardless of strand
		$reference = int( ( ($fstop - $fstart) / 2) + 0.5);
	}
	
	else {
		# something happened
		die " programming error!? feature " . 
			" at data row $row\n";
	}
	
	
	# collect the data
	# we will be using the get_chromo_region_score() to collect data
	# for every window 
	for (
		my $column = $startcolumn; 
		$column < $main_data_ref->{'number_columns'}; 
		$column++
	) {
		$data_table_ref->[$row][$column] = get_chromo_region_score( {
			'db'          => $ddb,
			'dataset'     => $dataset,
			'chromo'      => $fchromo,
			'start'       => $reference + $main_data_ref->{$column}{'start'},
			'stop'        => $reference + $main_data_ref->{$column}{'stop'},
			'strand'      => $fstrand,
			'method'      => $method,
			'value'       => $value_type,
			'stranded'    => $strand_sense,
			'log'         => $log,
		} ) || '.';
	}
}






## Interpolate the '.' values with the mean of the neighbors
sub go_interpolate_values {
	
	# determine counts
	my $lastwindow = $main_data_ref->{'number_columns'} - 2; 
		# lastwindow is the index of the second to last column
	
	# walk through each data line and then each window
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		for my $col ($startcolumn..$lastwindow) {
			# walk through the windows of a data row
			# skipping the very first and last windows (columns)
			# we will look for null values
			# if one is found, interpolate from neighbors
			if ($data_table_ref->[$row][$col] eq '.') {
				# we will interpolate the value from the neighbors
				# first, need to check that the neighbors have values
				
				# obtain the neighboring values
				my $before = $data_table_ref->[$row][$col - 1];
				my $after = $data_table_ref->[$row][$col + 1];
				if (
					$before ne '.' and 
					$after ne '.'
				) {
					# neighboring values are not nulls
					# then calculate the interpolated value
					if ($log) { 
						# working with log2 values
						$before = 2 ** $before;
						$after = 2 ** $after;
						my $mean = mean($before, $after);
						$data_table_ref->[$row][$col] = log($mean) / log(2);
					} 
					else { 
						# otherwise calculate straight value
						$data_table_ref->[$row][$col] = mean($before, $after);
					}
				}
			}
			
		}
		
	}
	
}



## Convert null values to proper zero values
sub null_to_zeros {
	# for those methods where we expect a true zero, sum and rpm
	# convert '.' null scores to zero
	
	# this wasn't done before because the null value makes the 
	# interpolation a lot easier without having to worry about zero
	
	# walk through each data line and then each window
	for my $row (1..$main_data_ref->{'last_row'}) {
		
		for (
			my $col = $startcolumn; 
			$col < $main_data_ref->{'number_columns'};
			$col++
		) {
			if ($data_table_ref->[$row][$col] eq '.') {
				$data_table_ref->[$row][$col] = 0;
			}
		}
	}
}



__END__

=head1 NAME

get_relative_data.pl

=head1 SYNOPSIS
 
 get_relative_data.pl --db <database> --feature <name> --out <file> [--options]
 get_relative_data.pl --in <in_filename> --out <out_filename> [--options]
  
  Options:
  --db <name|file.gff3>
  --ddb <name|file.gff3>
  --feature [type, type:source]
  --in <filename> 
  --out <filename>
  --data <dataset_name | filename>
  --method [mean|median|min|max|stddev|sum|rpm]
  --value [score|count|length]
  --win <integer>
  --num <integer>
  --pos [5|3|m]
  --strand [sense|antisense|all]
  --force_strand
  --avoid
  --long
  --(no)sum
  --(no)smooth
  --(no)log
  --gz
  --version
  --help

=head1 OPTIONS

The command line flags and descriptions:

=over 4

=item --db <name | filename>

Specify the name of a BioPerl database from which to obtain the 
annotation, chromosomal information, and/or data. Typically a 
Bio::DB::SeqFeature::Store database schema is used, either from a 
relational database, SQLite file, or a single GFF3 file to be loaded 
into memory. Alternatively, a BigWigSet directory, or a single BigWig, 
BigBed, or Bam file may be specified. 

A database is required for generating new files. When generating a new 
genome interval file, a bigFile or Bam file listed as a data source 
will be adopted as the database. 

For input files, the database name may be obtained from the file 
metadata. A different database may be specified from that listed in 
the metadata when a different source is desired. 

=item --ddb <name | filename>

Optionally specify the name of an alternate data database from which 
the data should be collected, separate from the primary annotation 
database. The same options apply as to the --db option. 

=item --out <filename>

Specify the output file name. Required for new files; otherwise, 
input files will be overwritten unless specified.

=item --in <filename>

Specify an input file containing either a list of database features or 
genomic coordinates for which to map data around. The file should be a 
tab-delimited text file, one row per feature, with columns representing 
feature identifiers, attributes, coordinates, and/or data values. The 
first row should be column headers. Bed files are acceptable, as are 
text files generated with other biotoolbox programs.

=item --feature [type, type:source]

Specify the type of feature to map data around. The feature may be 
listed either as GFF type or GFF type:source. The list 
of features will be automatically generated from the database. 
This is only required when an input file is not specified. 

=item --data <dataset_name | filename>

Specify the name of the data set from which you wish to 
collect data. If not specified, the data set may be chosen
interactively from a presented list. Other
features may be collected, and should be specified using the type 
(GFF type:source), especially when collecting alternative data values. 
Alternatively, the name of a data file may be provided. Supported 
file types include BigWig (.bw), BigBed (.bb), or single-end Bam 
(.bam). The file may be local or remote.

=item --method [mean|median|min|max|stddev|sum|rpm]

Specify the method of combining multiple values within each window. The mean, 
median, minimum, maximum, standard deviation, or sum of the values may be 
reported. The default value is mean for score and length values, or sum for 
count values.

=item --value [score|count|length]

Optionally specify the type of data value to collect from the dataset or 
data file. Three values are accepted: score, count, or length. Note that 
some data sources only support certain types of data values. Wig and 
BigWig files only support score and count; BigBed database features 
support count and length and optionally score; Bam files support basepair 
coverage (score), count (number of alignments), and length. The default 
value type is score. 

=item --win <integer>

Specify the window size. The default is 50 bp.

=item --num <integer>

Specify the number of windows on either side of the feature position 
(total number will be 2 x [num]). The default is 20, or 1 kb on either 
side of the reference position if the default window size is used.

=item --pos [5|3|m]

Indicate the relative position of the feature around which the 
data is mapped. Three values are accepted: "5" indicates the 
5' prime end is used, "3" indicates the 3' end is used, and "m" or "4"
indicates the middle of the feature is used. The default is to 
use the 5' end, or the start position of unstranded features. 

=item --strand [sense|antisense|all]

Specify whether stranded data should be collected for each of the 
datasets. Either sense or antisense (relative to the feature) data 
may be collected. The default value is 'all', indicating all 
data will be collected.

=item --force_strand

For features that are not inherently stranded (strand value of 0)
or that you want to impose a different strand, set this option when
collecting stranded data. This will reassign the specified strand for
each feature regardless of its original orientation. This requires the
presence of a "strand" column in the input data file. This option only
works with input file lists of database features, not defined genomic
regions (e.g. BED files). Default is false.

=item --avoid

Indicate whether features of the same type should be avoided when 
calculating values in a window. Each window is checked for 
overlapping features of the same type; if the window does overlap 
another feature of the same type, no value is reported for the 
window. The default is false (return all values regardless of 
overlap).

=item --long

Indicate that the dataset from which scores are collected are 
long features (counting genomic annotation for example) and not point 
data (microarray data or sequence coverage). Normally long features are 
only recorded at their midpoint, leading to inaccurate representation at 
some windows. This option forces the program to collect data separately 
at each window, rather than once for each file feature or region and 
subsequently assigning scores to windows. Execution times may be 
longer than otherwise. Default is false.

=item --(no)sum

Indicate that the data should be averaged across all features at
each position, suitable for graphing. A separate text file will 
be written with the suffix '_summed' with the averaged data. 
Default is true (sum).

=item --(no)smooth

Indicate that windows without values should (not) be interpolated
from neighboring values. The default is false (nosmooth).

=item --(no)log

Dataset values are (not) in log2 space and should be treated 
accordingly. Output values will be in the same space. The default is 
false (nolog).

=item --(no)gz

Specify whether (or not) the output file should be compressed with gzip.

=item --version

Print the version number.

=item --help

Display this help

=back

=head1 DESCRIPTION

This program will collect data around a relative coordinate of a genomic 
feature or region. The data is collected in a series of windows flanking the 
feature start (5' position for stranded features), end (3' position), or 
the midpoint position. The number and size of windows are specified via 
command line arguments, or the program will default to 20 windows on both 
sides of the relative position (40 total) of 50 bp size, corresponding to 
2 kb total (+/- 1 kb). Windows without a value may be interpolated 
(smoothed) from neigboring values, if available.

The default value that is collected is a dataset score (e.g. microarray 
values). However, other values may be collected, including 'count' or 
'length'. Use the --method argument to collect alternative values.

Stranded data may be collected. If the feature does not have an inherent 
strand, one may be specified to enforce stranded collection or a particular 
orientation. 

When features overlap, or the collection windows of one feature overlaps 
with another feature, then data may be ignored and not collected (--avoid).

The program writes out a tim data formatted text file. It will also 
generate a '*_summed.txt' file, in which each the mean value of all 
features for each window is generated and written as a data row. This 
summed data may be graphed using the biotoolbox script L<graph_profile.pl> 
or merged with other summed data sets for comparison.

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
