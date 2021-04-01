#! /usr/bin/perl

#use warnings;
use strict;
use Text::CSV;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::marc_remove as => 'marc_remove';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_map as => 'marc_map';


die "Argumente: $0 Input Output \n" unless @ARGV == 2;

my($inputfile,$outputfile) = @ARGV;
my $tempfile = './temp.seq';

open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">", $tempfile or die "$0: open $tempfile: $!";

my $ldrpos6;

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

    if ($field =~ /LDR/) {
        $ldrpos6 = substr($content,6,1); 
    }

    if ($field =~ /019/) {
        if ($content =~ /(bisher.*codiert|RekatMedea)/) {
            next NEWLINE;
        } else {
            my $f019a;
            my $f0195;
            for (@subfields) {
                $f019a = substr($_,1) if $_ =~ /^a/;
                $f0195 = substr($_,1) if $_ =~ /^5/;
            }
            $line = $sysnumber . ' 5830  L $$a' . $f019a . ' (' . $f0195 . ')';
            $line =~ s/ \(\)//g;
        }

    }
    
    if ($field =~ /245/) {
        print $line . "\n";
        my $f245a;
        my $f245b;
        my $f245c;
        my $f245h;
        my $f2456;
 
        for (@subfields) {
            $f245a .= '$$' . $_ if $_ =~ /^a/;
            $f245c .= '$$' . $_ if $_ =~ /^c/;
            $f245h .= '$$' . $_ if $_ =~ /^h/;
            $f2456 .= '$$' . $_ if $_ =~ /^6/;
            
            $f245b .= ' : ' . substr($_,1) if $_ =~ /^b/;
            $f245b =~ s/^ : //g;

        }

        $f245b = '$$b' . $f245b if $f245b;
        $line = $sysnumber . ' 2451  L ' . $f245a .  $f245b . $f245c . $f245h . $f2456;
        print $line . "\n";
    }
    
    if ($field =~ /542/) {
        if ($content =~ /\$\$lCC0/ ) {
            $line = $sysnumber . ' 54211 L $$lDie Katalogdaten stehen unter der Lizenz CC0 zur Weiternutzung zur Verfügung' ;
        } elsif ($content =~ /\$\$lCC-BY-NC/ ) {
            $line = $sysnumber . ' 54211 L $$lDie Katalogdaten stehen unter der Lizenz CC-BY zur Weiternutzung zur Verfügung' ;
        } else {
            $line = $sysnumber . ' 54200 L ' . $content;
        }
    }
    
    if ($field =~ /500/) {
        if ($ind1 eq 'C' && $ind2 eq 'A') { 
            $line = $sysnumber . ' 592   L ' . $content;
        } elsif ($ind1 eq 'C' && $ind2 eq 'B') { 
            $line = $sysnumber . ' 592   L ' . $content;
            $line =~ s/\$\$a/\$\$b/g;
        } elsif ($ind1 eq 'C' && $ind2 eq 'C') { 
            $line = $sysnumber . ' 592   L ' . $content;
            $line =~ s/\$\$a/\$\$b/g;
        } elsif ($ind1 eq 'D' && $ind2 eq 'A') { 
            $line = $sysnumber . ' 593   L ' . $content;
        } elsif ($ind1 eq 'D' && $ind2 eq 'B') { 
            $line = $sysnumber . ' 593   L ' . $content;
            $line =~ s/\$\$a/\$\$b/g;
        } elsif ($ind1 eq 'D' && $ind2 eq 'C') { 
            $line = $sysnumber . ' 593   L ' . $content;
            $line =~ s/\$\$a/\$\$c/g;
        } elsif ($ind1 eq 'L' ) { 
            $line = $sysnumber . ' 593   L ' . $content;
            $line =~ s/\$\$a/\$\$d/g;
            $line =~ s/\$\$b/\$\$e/g;
        } elsif ($ind1 eq 'Z' ) { 
            $line = $sysnumber . ' 593   L ' . $content;
            $line =~ s/\$\$a/\$\$e/g;
        } elsif ($ind1 eq 'M' ) { 
            $line = $sysnumber . ' 594   L ' . $content;
        }
    }
    
    if ($field =~ /773/) {
        $line = $sysnumber . ' 7731  L ' . $content;
    }
    
    print $out $line . "\n";
}

close $out or warn "$0: close $tempfile $!";

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $tempfile);
my $exporter = Catmandu::Exporter::MARC::ALEPHSEQ->new(file => $outputfile);

$importer->each(sub {
     my $data = $_[0];
     $data = marc_map($data,'245h','f245h');
     $data = marc_map($data,'LDR','LDR');
     my $ldrpos6 = substr($data->{LDR}, 6, 1);

     $data = marc_map($data,'260a','f260a','join','$$a');
     $data = marc_map($data,'260b','f260b','join','$$b');
     $data = marc_map($data,'260c','f260c','join','$$c');

     $data = marc_remove($data,'260');
     
     $data = marc_remove($data,'245d');
     $data = marc_remove($data,'245i');
     $data = marc_remove($data,'245j');
     $data = marc_remove($data,'245n');
     $data = marc_remove($data,'245p');

     if ($ldrpos6 eq 'a' || $data->{f245h} =~ /Druckschrift/) {
         $data = marc_add($data,'264','ind2','1','a', $data->{f260a}, 'b', $data->{f260b}, 'c', $data->{f260c});
     } else {
         $data = marc_add($data,'264','ind2','0','a', $data->{f260a}, 'b', $data->{f260b}, 'c', $data->{f260c});
     }

     $exporter->add($data);
});

$exporter->commit;
exit;

