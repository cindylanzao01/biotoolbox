#!/usr/bin/perl -w

# Test script for Bio::ToolBox::Data 
# working with BigWig data

use strict;
use Test::More;
use FindBin '$Bin';

BEGIN {
	if (eval {require Bio::DB::BigWig; 1}) {
		plan tests => 17;
	}
	else {
		plan skip_all => 'Optional module Bio::DB::BigWig not available';
	}
	$ENV{'BIOTOOLBOX'} = "$Bin/Data/biotoolbox.cfg";
}

use lib "$Bin/../lib";
require_ok 'Bio::ToolBox::Data' or 
	BAIL_OUT "Cannot load Bio::ToolBox::Data";


my $dataset = "$Bin/Data/sample2.bw";

### Open a test file
my $Data = Bio::ToolBox::Data->new(file => "$Bin/Data/sample.bed");
isa_ok($Data, 'Bio::ToolBox::Data', 'BED Data');

# add a database
$Data->database($dataset);
is($Data->database, $dataset, 'get database');
my $db = $Data->open_database;
isa_ok($db, 'Bio::DB::BigWig', 'connected database');



### Initialize row stream
my $stream = $Data->row_stream;
isa_ok($stream, 'Bio::ToolBox::Data::Iterator', 'row stream iterator');

# First row is YAL047C
my $row = $stream->next_row;
is($row->name, 'YAL047C', 'row name');

# try a segment
my $segment = $row->segment;
isa_ok($segment, 'Bio::DB::BigFile::Segment', 'row segment');
is($segment->start, 54989, 'segment start');

# score count sum
my $score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
);
# print "count sum for ", $row->name, " is $score\n";
is($score, 48, 'row sum of count');

# score mean coverage
$score = $row->get_score(
	'db'       => $db,
	'dataset'  => $dataset,
	'value'    => 'score',
	'method'   => 'mean',
);
# print "mean coverage for ", $row->name, " is $score\n";
is(sprintf("%.2f", $score), -0.12, 'row mean score');



### Move to the next row
$row = $stream->next_row;
is($row->start, 57029, 'row start position');
is($row->strand, -1, 'row strand');

# try stranded data collection
$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
);
# print "score count sum for ", $row->name, " is $score\n";
is($score, 7, 'row count sum');

$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'score',
	'method'   => 'median',
);
# print "score median for ", $row->name, " is $score\n";
is(sprintf("%.2f", $score), '0.50', 'row median score');




### Try positioned score index
my %pos2scores = $row->get_position_scores(
	'dataset'  => $dataset,
	'value'    => 'score',
);
is(scalar keys %pos2scores, 7, 'number of positioned scores');
# print "found ", scalar keys %pos2scores, " positions with reads\n";
# foreach (sort {$a <=> $b} keys %pos2scores) {
# 	print "  $_ => $pos2scores{$_}\n";
# }
is(sprintf("%.2f", $pos2scores{8}), '0.50', 'positioned score at 8');
is(sprintf("%.2f", $pos2scores{142}), 0.58, 'positioned score at 142');


# BigWig does not support stranded data collection
# save that for BigWigSet

