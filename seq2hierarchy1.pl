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
use Catmandu::Fix::Inline::marc_remove qw(:all);
use Catmandu::Fix::Inline::marc_add qw(:all);
use Catmandu::Exporter::MARC;

use List::MoreUtils qw(uniq);


my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

my @down; 
my @up; 

my @daughter; 
my @mother; 

open(my $fh_down, '>:encoding(UTF-8)', 'down.txt') or die "Could not open file 'down.txt'";
open(my $fh_up, '>:encoding(UTF-8)', 'up.txt') or die "Could not open file 'up.txt'";


$importer->each(sub {
        
	my $data = $_[0];
        my $sysnum = $data->{'_id'};

        my @f490w = marc_map($data, '490w') unless marc_map($data, '490w') eq '';
        my @f773w = marc_map($data, '773w') unless marc_map($data, '773w') eq '';

        my @link = (@f490w , @f773w);

        for (@link) {
            $_ = sprintf( "%-9.9d", $_);
        }

        if ( @link > 0) {
            print $fh_down $sysnum . "\n";
            for (@link) { 
                print $fh_up $_ . "\n";
            } 
        }
        
        #my %seen;
        #
        #for my $number (@link) {
        #    next unless $seen{$number}++;
        #    print "Duplicate linking field in $sysnum\n";
        #}

        
        
});

close $fh_down;
close $fh_up;

exit;
