#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (alephseq) \n" unless @ARGV == 0;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::SRU;
use Catmandu::Exporter::MARC;
use Catmandu::Fix::marc_map as => 'marc_map';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_remove as => 'marc_remove';

#use lib '/home/basil/catmandu/seq2marcxml/';
#use XML_bmt;

my $importer = Catmandu::Importer::SRU->new(
	  base => 'http://swb.bsz-bw.de/sru/DB=2.1/username=/password=/',
	  query => 'pica.nid="118634771"',
	  recordSchema => 'marcxml' ,
	  recordPacking => 'xml' ,
	  parser => 'marcxml',
	);

my $exporter = Catmandu->exporter('MARC', file => "test.seq", type => 'ALEPHSEQ' );

$importer->each(sub {
        
	my $data = $_[0];

	#print Dumper($data) . "\n";
	
	my $sysnum = $data->{'_id'};

	for my $i ("000" .. "999") {
            marc_remove($data, $i) unless $i =~ /1[01][01]/;
	    marc_remove($data, 'LDR');
        }

	$exporter->add($data);

});
	    
$exporter->commit;



