#!/usr/bin/perl

use v5.10; 

use strict;
use warnings;
use Data::Dumper;
use DBI;
use Carp; 

my $dbh = DBI->connect(          
	"dbi:SQLite:dbname=results.db", 
	"",                          
	"",                          
	{ RaiseError => 1, AutoCommit => 0},         
) or die $DBI::errstr;


if(!defined $ENV{'GOAL3X_SEASON'}) {
	croak "Missing GOAL3X_SEASON env variable\n";
}

my $season = $ENV{'GOAL3X_SEASON'};

print "Stats for season $season\n";

# Hashref

my @players = ({name => "Carlo"},{name=> "Luca"},{name=> "Riccardo"},{name=>"Mohsen"});
for my $user (@players) {

	giocate($user,$dbh);
	vinte($user, $dbh);
	sconfitte($user, $dbh);
	pareggiate($user, $dbh);
	golfatti($user, $dbh);
	golsubiti($user, $dbh);
	punti($user, $dbh);

	$user->{dr} = $user->{gf} - $user->{gs}; #differenzareti
	
}

## printing

my $head = sprintf "%-10s %4s %4s %4s %4s %4s %4s %4s %4s \n", 
	"Player", "G","V","N","S","GF","GS","+/-","P.ti";

	print $head;
my $head_len = length($head);
for (my $i=0; $i < $head_len; $i++) {
	print "-";
}
print "\n";

my @sorten = sort { $b->{pti} <=> $a->{pti} } @players;

for my $user (@sorten) {
	print_user($user);
}


$dbh->disconnect();

######### ROUTINES

sub giocate
{
	my ($user,$dbh) = @_;
	my $sql = "SELECT count(*) FROM scores WHERE (home like ? OR away like ?) AND season = ?";

	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$user->{name},$season);

	while(my @row = $sth->fetchrow_array()){
		$user->{g} = $row[0];
	}       
	$sth->finish();  

}

sub vinte {
	my ($user,$dbh) = @_;
	my $sql = "SELECT count(*) 
		   FROM scores 
		   WHERE ((home like ? AND home_score > away_score)
		   OR (away like ? AND away_score > home_score)) AND season = ?";

	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$user->{name}, $season);

	while(my @row = $sth->fetchrow_array()){
		$user->{v} = $row[0];
	}       
	$sth->finish();  
}

sub sconfitte {
	my ($user,$dbh) = @_;
	my $sql = "SELECT count(*) 
		   FROM scores 
		   WHERE ((home like ? AND home_score < away_score)
		   OR (away like ? AND away_score < home_score)) AND season = ?";

	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$user->{name},$season);

	while(my @row = $sth->fetchrow_array()){
		$user->{s} = $row[0];
	}       
	$sth->finish();  
}

sub pareggiate{
	my ($user,$dbh) = @_;
	my $sql = "SELECT count(*) 
		   FROM scores 
		   WHERE ((home like ? AND home_score = away_score)
		   OR (away like ? AND away_score = home_score)) AND season = ?";

	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$user->{name},$season);

	while(my @row = $sth->fetchrow_array()){
		$user->{n} = $row[0];
	}       
	$sth->finish();  
}

sub golfatti {
	my ($user,$dbh) = @_;
	my $sql = "SELECT sum(home_score) 
		   FROM scores 
		   WHERE home like ? and season = ?";
   	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$season);

	$user->{gf} = 0;

	while(my @row = $sth->fetchrow_array()){
		if($row[0]) {
			$user->{gf} += $row[0];
		}
	}       
	$sth->finish();  

	my $sql1 = "SELECT sum(away_score)
		   FROM scores
		   WHERE away like ? and season = ?";

	my $sth1 = $dbh->prepare($sql1);

	$sth1->execute($user->{name},$season);

	while(my @row = $sth1->fetchrow_array()){
		if($row[0]) {
			$user->{gf} += $row[0];
		}
	}       
	$sth1->finish();  

}

sub golsubiti {
	my ($user,$dbh) = @_;
	my $sql = "SELECT sum(away_score) 
		   FROM scores 
		   WHERE home like ? and season = ?";
		  
	my $sth = $dbh->prepare($sql);

	$sth->execute($user->{name},$season);

	$user->{gs} = 0;
	while(my @row = $sth->fetchrow_array()){
		if($row[0]) {
			$user->{gs} += $row[0];
		}
	}       
	$sth->finish();

	my $sql1 = "SELECT sum(home_score)
		   FROM scores
		   WHERE away like ? and season = ?";

	my $sth1 = $dbh->prepare($sql1);

	$sth1->execute($user->{name},$season);

	while(my @row = $sth1->fetchrow_array()){
		if($row[0]) {
			$user->{gs} += $row[0];
		}
	}       
	$sth1->finish();

}

sub punti {
	my $user = shift;
	$user->{pti} = $user->{v} * 3 + $user->{n} * 1;
}



sub print_user {
	my $user = shift;
	printf "%-10s %4s %4s %4s %4s %4s %4s %4s %4s \n",
		$user->{name},
		$user->{g},
		$user->{v},
		$user->{n},
		$user->{s},
		$user->{gf},
		$user->{gs},
		$user->{dr},
		$user->{pti}
}
