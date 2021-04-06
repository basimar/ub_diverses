#! /usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

# Skript verlangt eine Aleph-Sequential Datei mit 019-Feldern, sowie pro IZ ein Textfile mit den Anzupassen Inhalten von Feld 019 $a
# Autor: Basil Marti (basil.marti@unbas.ch)

# 2017.09.17: Uploaded to ub-catmandu /bmt 

die "Argumente: $0 Input (019-Felder), Output\n" unless @ARGV == 2;

my($inputfile,$outputfile) = @ARGV;


open(my $ube,'<:encoding(UTF-8)', 'UBE.txt') or die "Error opening UBE-Input $!";
open(my $ubs,'<:encoding(UTF-8)', 'UBS.txt') or die "Error opening UBS-Input $!";
open(my $rbe,'<:encoding(UTF-8)', 'RBE.txt') or die "Error opening RBE-Input $!";
open(my $zbs,'<:encoding(UTF-8)', 'ZBS.txt') or die "Error opening ZBS-Input $!";
open(my $del,'<:encoding(UTF-8)', 'DEL.txt') or die "Error opening DEL-Input $!";
open(my $ubsube,'<:encoding(UTF-8)', 'UBS-UBE.txt') or die "Error opening UBS-UBE-Input $!";

chomp(my @ube_lines = <$ube>);
chomp(my @ubs_lines = <$ubs>);
chomp(my @rbe_lines = <$rbe>);
chomp(my @zbs_lines = <$zbs>);
chomp(my @del_lines = <$del>);
chomp(my @ubsube_lines = <$ubsube>);

my %ube = map {$_ => 1} @ube_lines;
my %ubs = map {$_ => 1} @ubs_lines;
my %rbe = map {$_ => 1} @rbe_lines;
my %zbs = map {$_ => 1} @zbs_lines;
my %del = map {$_ => 1} @del_lines;
my %ubsube = map {$_ => 1} @ubsube_lines;

close $ube;
close $ubs;
close $rbe;
close $zbs;
close $del;
close $ubsube;

#print Dumper(@ube_lines); 

open(my $in,'<:encoding(UTF-8)', $inputfile) or die "Error opening $inputfile: $!";
open(my $out,'>:encoding(UTF-8)', $outputfile) or die "Error opening $outputfile: $!";

while (my $z = <$in>) {
    chomp($z);

    if ($z =~ /^..........019/ && $z =~ /\$\$5/ ) {
        $z =~ /(\$\$a.*?)(\$\$|$)/;
        my $sfa = $1;
        if (defined $ube{$sfa}) {
            #$z =~ s/\$\$5/\$\$5IZ UBE\//;
            #print $z . "\n";
        } elsif (defined $ubs{$sfa}) {
            #$z =~ s/\$\$5/\$\$5IZ UBS\//;
            #print $z . "\n";
        } elsif (defined $rbe{$sfa}) {
            #$z =~ s/\$\$5/\$\$5IZ RBE\//;
            #print $z . "\n";
        } elsif (defined $zbs{$sfa}) {
            #$z =~ s/\$\$5/\$\$5IZ ZBS\//;
            #print $z . "\n";
        } elsif (defined $del{$sfa}) {
            next;
        } elsif (defined $ubsube{$sfa}) {
            #$z =~ s/\$\$5/\$\$5IZ UBE-UBS\//;
            #print $z . "\n";
        }
    }

    print $out $z . "\n"
}

close $out or warn "$0: close $outputfile:: $!";

