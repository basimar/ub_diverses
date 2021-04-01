#! /usr/bin/perl

use warnings;
use strict;
use Text::CSV;
use utf8;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::marc_add as => 'marc_add';


die "Argumente: $0 Input Bernoulli-csv\n" unless @ARGV == 3;

my($inputfile,$outputfile,$bernoullicsv) = @ARGV;

my $csv = Text::CSV->new({ sep_char => ',' });

open(my $csvdata, '<:encoding(utf8)', $bernoullicsv) or die "Could not open '$bernoullicsv' $!\n";
my @b001;
my %b773t;
my %b773g;
my %b773j;
my %b773w;

while (my $line = <$csvdata>) {
    chomp $line;

    if ($csv->parse($line)) {

        my @fields = $csv->fields();
        my $sys = $fields[0];
        push @b001, $sys;
        $b773w{$sys} = $fields[1];
        $b773t{$sys} = $fields[2];
        $b773g{$sys} = $fields[3];
        $b773j{$sys} = $fields[4];
    } else {
        warn "Line could not be parsed: $line\n";
    }
}



open my $in, "<:encoding(utf8)", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">:encoding(utf8)", $outputfile or die "$0: open $outputfile: $!";

NEWLINE: while (<$in>) {
    my $sysnumber = (substr $_ , 0, 9);
    my $line = $_;
    my $field = (substr $line, 10, 3);

    my $new773;
    
    if ($field =~ /LDR/) {
        foreach my $sys (@b001) {
            if ($sys == $sysnumber) {
                $new773 = $sysnumber . ' 773 A L $$g' . $b773g{$sys} . '$$j' . $b773j{$sys} . '$$t' . $b773t{$sys} . '$$w' . $b773w{$sys} . "\n";
                print $out $new773 . "\n";
            }
        }
    }
}



