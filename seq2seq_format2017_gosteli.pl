#! /usr/bin/perl

use warnings;
use strict;

die "Argumente: $0 Input Output 245 Output 246 \n" unless @ARGV == 3;

my($inputfile,$outputfile, $outputfile2) = @ARGV;

open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $out245, ">", $outputfile or die "$0: open $outputfile: $!";
open my $out246, ">", $outputfile2 or die "$0: open $outputfile2: $!";

NEWLINE: while (<$in>) {
    my $sysnumber = (substr $_ , 0, 9);
    my $line = $_;
    my $field = (substr $line, 10, 3);
    my $ind1 = (substr $line, 13, 1);
    my $ind2 = (substr $line, 14, 1);
    my $content = (substr $line, 18);
    chomp $line;
    chomp $content;

    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    if ($field =~ /245/) {
        my $newcontent;
        my $newline;
        for (@subfields) { 
            $newcontent .= $_ if $_ =~ /^a/; 
            
            if ( $_ =~ /^d/ ) {
                $newline .= $sysnumber . ' 246   L $$iNamensvariante$$a' . substr($_,1) . "\n"
            }
        }
       
        $line = $sysnumber . ' 245   L $$' . $newcontent;
       
        print $out245 $line . "\n";
        print $out246 $newline;
    }
    
}

close $out245 or warn "$0: close $outputfile $!";
close $out246 or warn "$0: close $outputfile2 $!";

exit;

