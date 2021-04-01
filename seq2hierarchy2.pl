#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (dsv01-alephseq), Input-Dokument (Systemnummern)  \n" unless @ARGV == 2;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::Inline::marc_remove qw(:all);
use Catmandu::Fix::Inline::marc_add qw(:all);
use Catmandu::Exporter::MARC;

use List::MoreUtils qw(uniq);

$| = 1;

my @input_sys;

my $filename = $ARGV[1];
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
 
while (my $row = <$fh>) {
  chomp $row;
  push @input_sys, $row;
}


my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

$importer->each(sub {
        
	my $data = $_[0];
        my $sysnum = $data->{'_id'};

        for (@input_sys) {
            if ($_ eq $sysnum) {

                my @f490w = marc_map($data, '490w') unless marc_map($data, '490w') eq '';
                my @f773w = marc_map($data, '773w') unless marc_map($data, '773w') eq '';

                my @link = (@f490w , @f773w);

                for (@link) {
                    $_ = sprintf( "%-9.9d", $_);
                }

                if ( @link > 0) {
                    for (@link) { 
                        print $_ . "\n";
                    } 
                }
            }
        }
        
});

exit;
