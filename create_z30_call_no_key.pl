#! /usr/bin/perl

use warnings;
use strict;

die "Argumente: $0 Input Output\n" unless @ARGV == 2;

my($inputfile,$outputfile) = @ARGV;

open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">", $outputfile or die "$0: open $outputfile: $!";

while (<$in>) {
    my $line = $_;
    chomp $line;
    my @columns = split /;/, $line;
    my $sig = $columns[1];
    my $sigkey = lc $sig;

    $sigkey =~ s/ : / /g;
    $sigkey =~ s/:/ /g;
    
    $sigkey =~ s/ \/ / /g;
    $sigkey =~ s/\// /g;
    
    $sigkey =~ s/\./ /g;
    
    $sigkey =~ s/_/ /g;
    $sigkey =~ s/-/ /g;
    
    $sigkey =~ s/\(/ /g;
    $sigkey =~ s/\)/ /g;

    $sigkey =~ s/(?<= )([0-9]{6} )/0$1/g;
    $sigkey =~ s/(?<= )([0-9]{5} )/00$1/g;
    $sigkey =~ s/(?<= )([0-9]{4} )/000$1/g;
    $sigkey =~ s/(?<= )([0-9]{3} )/0000$1/g;
    $sigkey =~ s/(?<= )([0-9]{2} )/00000$1/g;
    $sigkey =~ s/(?<= )([0-9]{1} )/000000$1/g;
    
    $sigkey =~ s/(?<= )([0-9]{5}[a-z] )/00$1/g;
    $sigkey =~ s/(?<= )([0-9]{4}[a-z] )/000$1/g;
    $sigkey =~ s/(?<= )([0-9]{3}[a-z] )/0000$1/g;
    $sigkey =~ s/(?<= )([0-9]{2}[a-z] )/00000$1/g;
    $sigkey =~ s/(?<= )([0-9]{1}[a-z] )/000000$1/g;
    
    $sigkey =~ s/(?<= )([a-z])([0-9]{2} )/${1}00000$2/g;
    $sigkey =~ s/(?<= )([a-z])([0-9]{1} )/${1}000000$2/g;
    
    $sigkey =~ s/ ([0-9]{6})$/ 0$1/g;
    $sigkey =~ s/ ([0-9]{5})$/ 00$1/g;
    $sigkey =~ s/ ([0-9]{4})$/ 000$1/g;
    $sigkey =~ s/ ([0-9]{3})$/ 0000$1/g;
    $sigkey =~ s/ ([0-9]{2})$/ 00000$1/g;
    $sigkey =~ s/ ([0-9]{1})$/ 000000$1/g;
    
    $sigkey =~ s/ ([0-9]{5}[a-z])$/ 00$1/g;
    $sigkey =~ s/ ([0-9]{4}[a-z])$/ 000$1/g;
    $sigkey =~ s/ ([0-9]{3}[a-z])$/ 0000$1/g;
    $sigkey =~ s/ ([0-9]{2}[a-z])$/ 00000$1/g;
    $sigkey =~ s/ ([0-9]{1}[a-z])$/ 000000$1/g;
    
    $sigkey =~ s/ ([a-z])([0-9]{2}$)/ ${1}00000$2/g;
    $sigkey =~ s/ ([a-z])([0-9]{1}$)/ ${1}000000$2/g;
    
    $sigkey =~ s/  / /g;

    print $line . ";" . $sigkey . "\n";
    print $out $line . ";" . $sigkey . "\n";
}

close $out or warn "$0: close $outputfile:: $!";

