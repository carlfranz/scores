#!/usr/bin/perl

use strict;
use Carp;
use DBI;
use Data::Dumper;

my $size = scalar @ARGV;

if ($size != 5) {
	croak "Invalid command line\n";
}

sub check_team {
	my ($team) = @_;
	my %replaces = (
	  q{R} => "Riccardo",
	  q{M} => "Mohsen",
	  q{C} => "Carlo",
	  q{L} => "Luca"
	);
	my $ret_val = $replaces{$team};
	       
	if(!$ret_val) { 
		croak "Invalid Parameter $team\n";
	}
	return $ret_val;
}

sub check_score {
	my ($score) = @_;
	$score = $score + 0;
	if($score) {
		return int $score;
	} else {
		croak "Invalid Parameter $score\n";
	}
}

sub check_shift {
	my ($shift) = @_;

	if($shift =~ m/(AM|PM)/i) {
		return uc $shift;
	} else {
		croak "Invalid parameter $shift\n";
	}
}


my $home_team = check_team(uc $ARGV[0]);
my $away_team = check_team(uc $ARGV[1]);
my $home_score = check_score($ARGV[2]);
my $away_score = check_score($ARGV[3]);
my $shift = check_shift($ARGV[4]);

print "Home Team:\t$home_team\n";
print "Away Team:\t$away_team\n";
print "Home Score:\t$home_score\n";
print "Away Score:\t$away_score\n";
print "Shift:\t\t$shift\n";

my $dbh = DBI->connect(          
	"dbi:SQLite:dbname=results.db", 
	"",                          
	"",                          
	{ RaiseError => 1, AutoCommit => 0},         
) or die $DBI::errstr;

my $sth = $dbh->prepare("INSERT INTO scores VALUES(null, ? , ? , ? , ?,  DATE() ,? )");
$sth->bind_param(1, $home_team);
$sth->bind_param(2, $away_team);
$sth->bind_param(3, $home_score);
$sth->bind_param(4, $away_score);
$sth->bind_param(5, $shift);


$sth->execute();

$sth->finish();

print "Continue insert (y/n)?\n";
my $response = <STDIN>;
chomp $response;

if($response eq "y") {
	$dbh->commit();
	print "Done!\n";
} else {
	print "Abort!\n";
}


$dbh->disconnect();
