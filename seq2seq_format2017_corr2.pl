#! /usr/bin/perl

use warnings;
use strict;
use Text::CSV;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::marc_add as => 'marc_add';


my @bernoullichange = (
    '000227937',
    '000233863',
    '000265385',
    '000234476',
    '000270599',
    '000278517',
    '000287406',
    '000283342',
);

die "Argumente: $0 Input\n" unless @ARGV == 1;

my($inputfile) = @ARGV;
my $outfile_add = './dsv05_490_add.seq';
my $outfile_del = './dsv05_490_del.seq';

open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $out1, ">", $outfile_add or die "$0: open $outfile_add: $!";
open my $out2, ">", $outfile_del or die "$0: open $outfile_del: $!";

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

    if ($field =~ /490/) {
        my $f490a;
        my $f490i;
        my $f490v;
        my $f490w;

        foreach (@subfields) {
            if (substr($_,0,1) eq 'a')  {
                $f490a = substr($_,1)
            }
            if (substr($_,0,1) eq 'i')  {
                $f490i = substr($_,1)
            }
            if (substr($_,0,1) eq 'v')  {
                $f490v = substr($_,1)
            }
            if (substr($_,0,1) eq 'w')  {
                $f490w = substr($_,1)
            }
        }

        $f490w = sprintf("%09d", $f490w);

        foreach (@bernoullichange) {
            if ($_ =~ /$f490w/ ) {
		print $out2 $line . "\n";
                $line = $sysnumber . ' 773 A L $$g' . $f490v . '$$j' . $f490i . '$$t' . $f490a . '$$w' . $f490w;
                print $out1 $line . "\n";
            }
        }
    }

}

close $out1 or warn "$0: close $outfile_add $!";
close $out2 or warn "$0: close $outfile_del $!";


