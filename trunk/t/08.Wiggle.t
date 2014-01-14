#!/usr/bin/env perl

# Test script for Bio::ToolBox::Data 
# working with binary wiggle data

use strict;
use Test;
use FindBin '$Bin';

BEGIN {
	if (eval {require Bio::Graphics::Wiggle; 1}) {
		plan tests => 15;
	}
	else {
		plan skip_all => 'Optional module Bio::Graphics not available';
	}
	$ENV{'BIOTOOLBOX'} = "$Bin/Data/biotoolbox.cfg";
}

use lib "$Bin/../lib";
use Bio::ToolBox::Data;


### Prepare the GFF database
my $database = "$Bin/Data/sample2.gff3";
unless (-e $database) {
	open(my $fh, ">" ,$database);
	print $fh <<GFF
##gff-version 3
chrI	SGD	chromosome	1	230218	.	.	.	ID=chrI;dbxref=NCBI:NC_001133;Name=chrI
chrI	tim	sample2	1	230218	.	.	.	Name=sample2;wigfile=$Bin/Data/sample2.wib
GFF
;
	close $fh;
}


### Open a test file
my $Data = Bio::ToolBox::Data->new(file => "$Bin/Data/sample.bed");
ok($Data);

# add a database
$Data->database($database);
ok($Data->database, $database);
my $db = $Data->open_database;
ok($db);



### Initialize row stream
my $stream = $Data->row_stream;

# First row is YAL047C
my $row = $stream->next_row;
ok($row->name, 'YAL047C');

# try a segment
my $segment = $row->segment;
ok($segment);
ok($segment->start, 54989);

# score count sum
my $score = $row->get_score(
	'db'       => $database,
	'dataset'  => 'sample2',
	'value'    => 'count',
	'method'   => 'sum',
);
# print "count sum for ", $row->name, " is $score\n";
ok($score, 49);

# score mean coverage
$score = $row->get_score(
	'db'       => $db,
	'dataset'  => 'sample2',
	'value'    => 'score',
	'method'   => 'mean',
);
# print "mean coverage for ", $row->name, " is $score\n";
ok(sprintf("%.2f", $score), -0.14);




### Move to the next row
$row = $stream->next_row;
ok($row->start, 57029);
ok($row->strand, -1);

# try stranded data collection
$score = $row->get_score(
	'dataset'  => 'sample2',
	'value'    => 'count',
	'method'   => 'sum',
);
# print "score count sum for ", $row->name, " is $score\n";
ok($score, 7);

$score = $row->get_score(
	'dataset'  => 'sample2',
	'value'    => 'score',
	'method'   => 'median',
);
# print "score median for ", $row->name, " is $score\n";
ok(sprintf("%.2f", $score), '0.49');




### Try positioned score index
my %pos2scores = $row->get_position_scores(
	'dataset'  => 'sample2',
	'value'    => 'score',
);
ok(scalar keys %pos2scores, 7);
# print "found ", scalar keys %pos2scores, " positions with reads\n";
# foreach (sort {$a <=> $b} keys %pos2scores) {
# 	print "  $_ => $pos2scores{$_}\n";
# }
ok(sprintf("%.2f", $pos2scores{8}), '0.49');
ok(sprintf("%.2f", $pos2scores{142}), 0.58);


END {
	unlink $database;
}
