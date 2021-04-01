#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

use IO::File;

die "Argumente: $0 Input-Dokument (alephseq)" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

#Zeit auslesen für Header
use Time::Piece;
my $date = localtime;

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);

my $count_person = 0;
my $count_corp = 0;
my $count_congress = 0;
my $count_place = 0;
my $count = 0;

my %record;
my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);
$importer->each(sub {
        
	my $data = $_[0];
	my $sysnum = $data->{'_id'};

	my $f100 = marc_map($data, '100');
	my $f110 = marc_map($data, '110');
	my $f111 = marc_map($data, '111');
	my $f152 = marc_map($data, '152');

	$count += 1;
 	  
	$count_person += 1 if $f100;
	$count_corp += 1 if $f110;
 	$count_congress += 1 if $f111;
  	$count_place += 1 if $f152;
	                     
});

print 'Person: ' . $count_person . "\n";
print 'Körperschaft: ' . $count_corp . "\n";
print 'Kongress: ' . $count_congress . "\n";
print 'Ort: ' . $count_place . "\n";
print '-------------------------------------------' . "\n";
print 'Total: ' . ( $count_person + $count_corp + $count_congress + $count_place) . "\n";
print 'Anzahl Katalogisate: ' . $count . "\n";


exit;


