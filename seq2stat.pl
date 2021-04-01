#!/usr/bin/perl -w

use strict;
use utf8;

die "Argumente: $0 Input (Aleph-Sequential) \n" unless @ARGV == 1;
 
my($inputfile) = @ARGV;
my $outputfields = './fields.txt';
my $outputsubfields = './subfields.txt';

open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $outf, ">", $outputfields or die "$0: open $outputfields $!";
open my $outsf, ">", $outputsubfields or die "$0: open $outputsubfields $!";

my %tag_counter = ();
my %sf_counter = ();

print "Start: ", `date +'%d.%m.%Y %H:%M:%S'`,"\n";
 
# Zeilenweises Einlesen von Aleph Sequential und Generierung der beiden Hashes

my $tag_ind;

while (<$in>) {
    my $line = $_;
    chomp $line;
    $tag_ind = substr($line, 10, 5);
    my $field = substr($line, 18);

    $tag_counter{$tag_ind}++;

    my @subfields = split(/\$\$/, $field);
    shift @subfields;

    unless (@subfields) {
       $sf_counter{$tag_ind}{"void"}++;
    }

    foreach my $sf (@subfields) {
       my $sf_code = substr($sf, 0, 1);
       $sf_counter{$tag_ind}{$sf_code}++;
    }
}

#Auszaehlung Felder und Unterfelder

foreach $tag_ind (sort keys %tag_counter) {
   my $sf;

   print $outf "$tag_ind:  $tag_counter{$tag_ind} \n";

   print $outsf "$tag_ind\n";
   foreach $sf (sort keys %{$sf_counter{$tag_ind}}) {
      print $outsf " $sf:       $sf_counter{$tag_ind}{$sf}\n";
   }
}

close $outsf or warn "$0: close $outputfields $!";
close $outf or warn "$0: close $outputsubfields $!";

print "Ende: ", `date +'%d.%m.%Y %H:%M:%S'`,"\n";

exit;
