#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (alephseq) \n" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::Inline::marc_add qw(:all);

#use lib '/home/basil/catmandu/seq2marcxml/';
#use XML_bmt;

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

my @place;

$importer->each(sub {
        
	my $data = $_[0];
        my $sysnum = $data->{'_id'};

        my $f909f = marc_map($data, '909f');
        my $f852 = marc_map($data, '852');
        
        if (($f909f =~ /bernoulli/) && (not defined $f852 )) {
                print $sysnum . ' 852   L $$bKein Standort bekannt' . "\n";
                print $sysnum . ' 506   L $$aExistenz des Briefes aus anderer Quelle bekannt' . "\n";  
        }
});




