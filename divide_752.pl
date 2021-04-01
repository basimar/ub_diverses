#! /usr/bin/perl

use warnings;
use strict;

die "Argumente: $0 Input1 Input2 Output1 Output2\n" unless @ARGV == 4;

my($input1file,$input2file,$outputfile1,$outputfile2) = @ARGV;

open my $in1, "<", $input1file or die "$0: open $input1file: $!";
open my $out1, ">", $outputfile1 or die "$0: open $outputfile1: $!";
open my $out2, ">", $outputfile2 or die "$0: open $outputfile2: $!";

while (my $z1 = <$in1>) {
        my $abn;
        my $sysnumber = (substr $z1 , 0, 9);
        open my $in2, "<", $input2file or die "$0: open $input2file: $!";
        while (my $z2 = <$in2>) {
		if ($sysnumber == (substr $z2 , 0, 9)) {
                   $abn = 1;
		}
	}
        if ($abn) {
            print "ABN: $z1\n";
            print $out1 $z1;
        } else {
            print "Not-ABN: $z1\n";
            print $out2 $z1;
        }
	close $in2;
}

close $out1 or warn "$0: close $outputfile1:: $!";
close $out2 or warn "$0: close $outputfile2:: $!";

