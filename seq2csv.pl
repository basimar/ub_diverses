#!/usr/bin/perl -w

#use strict;
use utf8;

die "Argumente: $0 Input (Aleph-Sequential), Output (csv) \n" unless @ARGV == 2;
 
my($inputfile,$outputfile) = @ARGV;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
#
# Damit das funktioniert, muss /usr/local/share/perl/5.22.1/Catmandu/Importer/SRU.pm modifziert werden (Entferne swr-Elemente), bis Günter Swissbib-SRU fixt

use Catmandu::Importer::SRU;
use Catmandu::Exporter::MARC;
use Catmandu::Fix::marc_map as => 'marc_map';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_remove as => 'marc_remove';

open my $in, '<:encoding(UTF-8)', $inputfile or die "$0: open $inputfile: $!";


print "Start: ", `date +'%d.%m.%Y %H:%M:%S'`,"\n";
 
# Zeilenweises Einlesen von Aleph Sequential und Generierung der beiden Hashes

my %f008;
my %f019;
my %f072;
my %f084;
my %f100;
my %f700;
my %f245;
my %f264;
my %f300;
my %f336;
my %f337;
my %f338;
my %f500;
my %f520;
my %f520_ind;

my @sys;

while (<$in>) {
    my $line = $_;
    chomp $line;
    my $sys = substr($line, 0, 9); 
    my $tag = substr($line, 10, 3);
    my $ind = substr($line, 13, 2);

    push @sys, $sys;

    my $field = substr($line, 18);

    my @subfields = split(/\$\$/, $field);
    shift @subfields;
    
    if ($tag =~ /008/) {
        $f008{$sys} = substr($line, 25,4);
    } elsif ($tag =~ /019/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f019{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^5/) {
                $f019{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /072/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f072{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /084/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f084{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /100/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f100{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /700/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f700{$sys} .= substr($_,1) . "zerschnipseln ";
            }
        }
    } elsif ($tag =~ /245/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f245{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^b/) {
                $f245{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /264/ && $ind =~ / 1/) {
        for (@subfields) {
            if ($_ =~ /^c/) { 
                $f264{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /300/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f300{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /336/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f336{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^b/) {
                $f336{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^2/) {
                $f336{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /337/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f337{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^b/) {
                $f337{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^2/) {
                $f337{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /338/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f338{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^b/) {
                $f338{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^2/) {
                $f338{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /500/) {
        for (@subfields) {
            if ($_ =~ /^a/) { 
                $f500{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^5/) {
                $f500{$sys} .= substr($_,1) . " ";
            } elsif ($_ =~ /^6/) {
                $f500{$sys} .= substr($_,1) . " ";
            }
        }
    } elsif ($tag =~ /520/) {
        $f520_ind{$sys} .= $ind . " ";
        for (@subfields) {
            $f520{$sys} .= substr($_,1) . " ";
        }
        $f520{$sys} .= "ŋ";
    }
};

my @unique_sys = do { my %seen; grep { !$seen{$_}++ } @sys };
    
open(my $output, '>:encoding(UTF-8)', $outputfile) or die "Could not open file '$outputfile' $!";

for (@unique_sys) {

    my $libcode;

    my $syssru = "IDSBB" . $_;
    my $sys035 = "(IDSBB)" . $_;
    my $query = "dc.anywhere=$syssru";

    # Catmandu-Importer für SRU-Abfrage
    my $importer = Catmandu::Importer::SRU->new(
        base => 'http://sru.swissbib.ch/sru/search/bbdb',
        query => $query,
        recordSchema => 'info:srw/schema/1/marcxml-v1.1-light',
        parser => 'marcxml',
    );

    my $true = 0;

    $importer->each(sub {

        my $data = $_[0];

        marc_remove($data, 'LDR');

        for my $j ("000" .. "999") {
            marc_remove($data, $j) unless $j =~ /035|949|852/;
        }

        my $no_fields = scalar @{$data->{record}};

        for my $k (0 .. ($no_fields-1)) {
           if ($data->{record}[$k][0] == '035' ) {
               if ( $data->{record}[$k][4] eq $sys035 ) {
                    $true = 1
               }
           }
        }

        if ($true) {
            for my $l (0 .. ($no_fields-1)) {
                if ($data->{record}[$l][0] == '949' && $data->{record}[$l][4] eq 'IDSBB' ) {
                    print $data->{record}[$l][4] . " ";
                    print $data->{record}[$l][6] . "\n";
                    $libcode .=  $data->{record}[$l][6] . " "; 
                } elsif ($data->{record}[$l][0] == '852' && $data->{record}[$l][4] eq 'IDSBB' ) {
                    $libcode .=  $data->{record}[$l][6] . " "; 
                }
            }
        }
    });


    print $output $_ . "ŋ";
    print $output $libcode . "ŋ";
    print $output $f008{$_} . "ŋ";
    print $output $f019{$_} . "ŋ";
    print $output $f072{$_} . "ŋ";
    print $output $f084{$_} . "ŋ";
    print $output $f100{$_} . "ŋ";
    $f700{$_} =~ s/zerschnipseln.*$//g;
    print $output $f700{$_} . "ŋ";
    print $output $f245{$_} . "ŋ";
    print $output $f264{$_} . "ŋ";
    print $output $f300{$_} . "ŋ";
    print $output $f336{$_} . "ŋ";
    print $output $f337{$_} . "ŋ";
    print $output $f338{$_} . "ŋ";
    print $output $f500{$_} , "ŋ";
    $f520{$_} =~ s/ŋ$//g;
    print $output $f520_ind{$_} . "ŋ";
    print $output $f520{$_} . "ŋ";
    print $output "\n";

}

exit;
