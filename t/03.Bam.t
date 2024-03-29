#!/usr/bin/perl -w

# Test script for Bio::ToolBox::Data 
# working with Bam data

use strict;
use Test::More;
use File::Spec;
use FindBin '$Bin';

BEGIN {
	if (eval {require Bio::DB::Sam; 1}) {
		plan tests => 33;
	}
	else {
		plan skip_all => 'Optional module Bio::DB::Sam not available';
	}
	$ENV{'BIOTOOLBOX'} = File::Spec->catfile($Bin, "Data", "biotoolbox.cfg");
}

use lib File::Spec->catfile($Bin, "..", "lib");
require_ok 'Bio::ToolBox::Data' or 
	BAIL_OUT "Cannot load Bio::ToolBox::Data";
use_ok( 'Bio::ToolBox::db_helper', 'check_dataset_for_rpm_support', 'get_chromosome_list' );


my $dataset = File::Spec->catfile($Bin, "Data", "sample1.bam");

### Open a test file
my $infile = File::Spec->catfile($Bin, "Data", "sample.bed");
my $Data = Bio::ToolBox::Data->new(file => $infile);
isa_ok($Data, 'Bio::ToolBox::Data', 'BED Data');

# add a database
$Data->database($dataset);
is($Data->database, $dataset, 'get database');
my $db = $Data->open_database;
isa_ok($db, 'Bio::DB::Sam', 'connected database');

# check chromosomes
my @chromos = get_chromosome_list($db);
is(scalar @chromos, 1, 'number of chromosomes');
is($chromos[0][0], 'chrI', 'name of first chromosome');
is($chromos[0][1], 230208, 'length of first chromosome');

# check total mapped alignments
my $total = check_dataset_for_rpm_support($dataset);
is($total, 1414, "number of mapped alignments in bam");

### Initialize row stream
my $stream = $Data->row_stream;
isa_ok($stream, 'Bio::ToolBox::Data::Iterator', 'row stream iterator');

# First row is YAL047C
my $row = $stream->next_row;
is($row->name, 'YAL047C', 'row name');

# try a segment
my $segment = $row->segment;
isa_ok($segment, 'Bio::DB::Sam::Segment', 'row segment');
is($segment->start, 54989, 'segment start');

# read count sum
my $score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
);
# print "count sum for ", $row->name, " is $score\n";
is($score, 453, 'row sum of read count score');

# mean coverage
$score = $row->get_score(
	'db'       => $db,
	'dataset'  => $dataset,
	'value'    => 'score',
	'method'   => 'mean',
);
# print "mean coverage for ", $row->name, " is $score\n";
is(sprintf("%.2f", $score), 16.33, 'row mean coverage');

# read precise count sum
$score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'pcount',
	'method'   => 'sum',
);
# print "count sum for ", $row->name, " is $score\n";
is($score, 414, 'row sum of read precise count score');

# read length mean
$score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'length',
	'method'   => 'median',
);
# print "count sum for ", $row->name, " is $score\n";
is($score, 73, 'median of read length');

# read count rpm
$score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'rpm',
);
# print "count sum for ", $row->name, " is $score\n";
is(int($score), 320367, 'read count as rpm');

# read count rpkm
$score = $row->get_score(
	'db'       => $dataset,
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'rpkm',
);
# print "count sum for ", $row->name, " is $score\n";
is(int($score), 171411, 'read count as rpkm');



### Move to the next row
$row = $stream->next_row;
is($row->start, 57029, 'row start position');
is($row->strand, -1, 'row strand');

# try stranded data collection
$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
	'stranded' => 'all',
);
# print "all read count sum for ", $row->name, " is $score\n";
is($score, 183, 'row sum of count score for all strands');

$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
	'stranded' => 'sense',
);
# print "sense read count sum for ", $row->name, " is $score\n";
is($score, 86, 'row sum of count score for sense strand');

$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'count',
	'method'   => 'sum',
	'stranded' => 'antisense',
);
# print "antisense read count sum for ", $row->name, " is $score\n";
is($score, 97, 'row sum of count score for antisense strand');

$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'score',
	'method'   => 'mean',
	'stranded' => 'sense',
);
# print "sense mean coverage for ", $row->name, " is $score\n";
is(sprintf("%.2f", $score), 29.38, 'row mean coverage for sense strand');

$score = $row->get_score(
	'dataset'  => $dataset,
	'value'    => 'score',
	'method'   => 'mean',
	'stranded' => 'antisense',
);
# print "antisense mean coverage for ", $row->name, " is $score\n";
is(sprintf("%.2f", $score), 29.38, 'row mean coverage for sense strand');



### Move to third row
# test row positioned score using bam file
$row = $stream->next_row;
is($row->name, 'YAL044W-A', 'row name');

my %pos2scores = $row->get_position_scores(
	'dataset'  => $dataset,
	'value'    => 'count',
);
is(scalar keys %pos2scores, 110, 'number of positioned scores');
# print "found ", scalar keys %pos2scores, " positions with reads\n";
# foreach (sort {$a <=> $b} keys %pos2scores) {
# 	print "  $_ => $pos2scores{$_}\n";
# }
is($pos2scores{1}, 1, 'positioned score at 1');
is($pos2scores{20}, 2, 'positioned score at 20');

%pos2scores = $row->get_position_scores(
	'dataset'  => $dataset,
	'value'    => 'count',
	'absolute' => 1,
	'stranded' => 'antisense',
);
# print "found ", scalar keys %pos2scores, " positions with reads\n";
# foreach (sort {$a <=> $b} keys %pos2scores) {
# 	print "  $_ => $pos2scores{$_}\n";
# }
is(scalar keys %pos2scores, 63, 'number of positioned scores');
is($pos2scores{57556}, 2, 'positioned score at 57556');
is($pos2scores{57840}, 1, 'positioned score at 57840');
