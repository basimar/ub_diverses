#! /usr/bin/perl

use warnings;
use strict;

die "Argumente: $0 Beginn Ende Library\n" unless @ARGV == 3;

my $begin = $ARGV[0];
my $end = $ARGV[1];

my $library = $ARGV[2];

for my $i ($begin .. $end) {
      $i = sprintf("%09d",$i);
      print "$i" . "$library\n";
}



