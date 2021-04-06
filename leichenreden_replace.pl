#! /usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

# Skript verlangt eine Aleph-Sequential Datei mit den anzupassenden Katalogisaten, sowie eine Konkordanz altes Feld neues Feld
# Autor: Basil Marti (basil.marti@unbas.ch)


die "Argumente: $0 Input (019-Felder), Input (Konkordanz), Output\n" unless @ARGV == 3;

my($inputfile,$concordance,$outputfile) = @ARGV;

my %con;

open(my $con,'<:encoding(UTF-8)', $concordance) or die "Error opening $concordance $!";

while (my $con_line = <$con>) {
    chomp $con_line;
    my @con_array = split /\|/, $con_line;
    my $con_key = shift @con_array;
    $con{$con_key} = shift @con_array;
}

close $con;

print Dumper(%con); 

open(my $in,'<:encoding(UTF-8)', $inputfile) or die "Error opening $inputfile: $!";
open(my $out,'>:encoding(UTF-8)', $outputfile) or die "Error opening $outputfile: $!";

while (my $z = <$in>) {
    chomp($z);

    if ($con{$z}) {
        print $out $con{$z} . "\n";
        print $con{$z} . "\n";
    } else {
        print $out $z . "\n";
        #print $z . "\n";
    }
}

close $out or warn "$0: close $outputfile:: $!";

