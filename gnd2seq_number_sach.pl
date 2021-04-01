#!usr/bin/env perl

use strict;
#use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Aleph-Sequential-Dokument mit GND-Felder output \n" unless @ARGV == 2;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::SRU;
use Catmandu::Exporter::MARC;
use Catmandu::Fix::marc_map as => 'marc_map';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_remove as => 'marc_remove';

# Text::CSV Module
use Text::CSV::Encoded;

my $csv = Text::CSV::Encoded->new({ sep_char => ';' });
 
my $seqfile = $ARGV[0] or die "Need to get SEQ file on the command line\n";

# Hashes zum der GND-Nummern, Hash-Values sind arrays mit DSV01-Systemnummern)
my %gnd;
my %field;
my $count;

# Öffne csv-file und lese zeile für zeile ein 
open(my $seq, '<', $seqfile) or die "Could not open '$seqfile' $!\n";

while (my $line = <$seq>) {
    chomp $line;
    my $sys = substr($line, 0, 9);
    my $tag = substr($line, 10, 5);
    my $ind1 = substr($tag, 3, 1);
    my $ind2 = substr($tag, 4, 1);
    my $subfields = substr($line, 18);
    my $gnd;

    my $output = substr($line,10);

    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    for (@subfields) {
        my $subfield_code = substr $_, 0, 1;
        my $subfield = substr $_, 1;
        if ($subfield_code eq '1') {
            $gnd = $subfield;
        }
    }
    if ($gnd =~ /DE-588/) {
        push @{$gnd{$gnd}}, $sys;
        $field{$gnd} = $output;
    } else {
        print "Keine GND-Nummer in $sys\n"
    }
}

my $output = $ARGV[1];
open(my $out, '>:utf8', $output) or die "Could not open file '$output' $!";


for (keys %gnd) {

    #sleep (1);

    $count++;
    print $count . "\n";
    print $count . "\n" if ( $count % 1000 == 0); 

    my $gnd_number = $_;
    my $gnd_short = $_;
    $gnd_short =~ s/\(DE-588\)//g;

    my $query = "pica.nid=gnd$gnd_short";

    my $marc;

    my $exporter = Catmandu->exporter('MARC', file => \$marc, type => 'ALEPHSEQ' );

    # Catmandu-Importer für SRU-Abfrage
    my $importer = Catmandu::Importer::SRU->new(
       base => 'http://swb.bsz-bw.de/sru/DB=2.104/username=/password=/',
       query => $query,
       recordSchema => 'marcxml' ,
       recordPacking => 'xml' ,
       parser => 'marcxml',
    );

    # Verarbeitung der MARC-Daten 
    $importer->each(sub {
        my $data = $_[0];
        my $sysnum = $data->{'_id'};
        marc_remove($data, 'LDR');
        marc_remove($data, 'FMT');

        for my $j ("000" .. "999") {
            marc_remove($data, $j) unless $j =~ /079/;
        }
        $exporter->add($data);
        $exporter->commit;
    });

    chomp $marc;

    my $sys = substr($marc, 0, 9);
    my $tag = substr($marc, 10, 5);
    my $ind1 = substr($tag, 3, 1);
    my $ind2 = substr($tag, 4, 1);
    my $subfields = substr($marc, 18);
    my $gnd;

    my @subfields = split(/\$\$/, $marc);
    shift @subfields;

    my $teilbestand_not_s = 1;
    my $gnd_not_found = 1;


    for (@subfields) {
        my $subfield_code = substr $_, 0, 1;
        my $subfield = substr $_, 1;
        if ($subfield_code eq 'q') {
                $gnd_not_found = 0;
            if ($subfield eq 's') {
                $teilbestand_not_s = 0;
            }
        }
    }

    my @sysnumbers = @{$gnd{$gnd_number}};
 
    if ($gnd_not_found ) {
        print $out $gnd_number . " Verknüpfter GND-Satz existiert nicht: " . $field{$gnd_number} . " / " .  join(" : ", @sysnumbers) . "\n" 
    } elsif ($teilbestand_not_s) {
        print $out $gnd_number . " Nicht zugelassen für Sacherschliessung: " . $field{$gnd_number} . " / " .  join(" : ", @sysnumbers) . "\n" 
    }
}





