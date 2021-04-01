#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 CSV-Dokument dsv05.seq Output zum Ladenn \n" unless @ARGV == 3;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Achtung: Sicherstellen das Standard SRU-Modul von Catmandu verwendet wird. Auf ub-catmandu ist zum Teil eine angepasste version von Catmandu::Importer:SRU aktiv!
# die den Zugriff auf die SRU-Schnittstelle von swissbib ermöglichst. Nachschauen unter /usr/local/share/perl/5.22.1/Catmandu/Importer, ob das richtige pm-Modul  !
# eingesetzt wird.                                                                                                                                                 !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


use Catmandu::Importer::SRU;
use Catmandu::Exporter::MARC;
use Catmandu::Fix::marc_map as => 'marc_map';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_remove as => 'marc_remove';

# Text::CSV Module
use Text::CSV::Encoded;

my $csv = Text::CSV::Encoded->new({ sep_char => ',' });
 
my $csvfile = $ARGV[0] or die "Need to get CSV file on the command line\n";

# Hashes zum Einlesen der CSV-Datei ($n = Zeilenummer als Hashkey)
my $n = 0;
my %marc_old;
my %marc_new;
my %gnd;

# Hash zum Einlesen der SRU Normdaten (GND-Nummer als Hashkey)
my %gnd_store;

# Öffne csv-file und lese zeile für zeile ein 
open(my $csvdata, '<', $csvfile) or die "Could not open '$csvfile' $!\n";
while (my $line = <$csvdata>) {
    chomp $line;
    if ($csv->parse($line)) {
        my @fields = $csv->fields();

	# Auslesen der csv-spalten

        my $marc_old = $fields[1];
        my $gnd = $fields[2];
	my $gnd_short = $fields[2];
        $gnd_short =~ s/\(DE-588\)//g;

        # Einlesen der csv-Spalten in Hash

        $marc_old{$n} = $marc_old;
        $gnd{$n} = $gnd;

        my $marc_gnd;
        my $marc_new;

        if (defined $gnd_store{$gnd}) {

            $marc_gnd = $gnd_store{$gnd};

        } else {

            my $query = "pica.nid=$gnd_short";

            my $exporter = Catmandu->exporter('MARC', file => \$marc_gnd, type => 'ALEPHSEQ' );

            # Catmandu-Importer für SRU-Abfrage
            my $importer = Catmandu::Importer::SRU->new(
                # Die Datenbank 2.104 enthält nur die GND-Daten
                base => 'http://swb.bsz-bw.de/sru/DB=2.104/username=/password=/',
                query => $query,
                recordSchema => 'marcxml' ,
                recordPacking => 'xml' ,
                parser => 'marcxml',
            );
   
            # Verarbeitung der MARC-Daten 
            $importer->each(sub {

                my $data = $_[0];
                
                marc_remove($data, 'LDR');
                for my $j ("000" .. "999") {
                    marc_remove($data, $j) unless $j =~ /1[01][01]/;
                }

                $exporter->add($data);
                $exporter->commit;
            });
          
            chomp $marc_gnd;

            # 1. Aleph Sequential Linie mit FMT entfernen
            $marc_gnd =~ s/^(?:.*\n)//;
            $gnd_store{$gnd} = $marc_gnd;

       }

       unless ($marc_gnd eq "") {
           if ($marc_old =~ /^6/) {
                $marc_new = '6' . substr($marc_gnd,11,3) . "7" . substr($marc_gnd,15) . '$$1' .  $gnd .  '$$2gnd';
           } else {
                $marc_new = substr($marc_old,0,1) . substr($marc_gnd,11) . '$$1' . $gnd;
           }

       
           if ($marc_old =~ /\$\$e(.*)\$\$4(.*)(\$\$|$)/) {
               $marc_new .= "\$\$e$1\$\$4$2"
           } elsif ($line =~ /\$\$4(.*)\$\$e(.*)(\$\$|$)/) {
               $marc_new .= "\$\$e$2\$\$4$1"
           }

           $marc_new{$n} = $marc_new;
       } else {
           print "not found: $marc_old\n";
       }
       
       $n ++;

    } else {
        warn "Line could not be parsed: $line\n";
    }
}

my $seqfile = $ARGV[1];
open(my $seqdata, '<:encoding(UTF-8)', $seqfile) or die "Could not open '$seqfile' $!\n";

my $outfile = $ARGV[2]; 
open(my $output, '>:encoding(UTF-8)', $outfile) or die "Could not open file '$outfile' $!";

while (my $line = <$seqdata>) {
   my $sys = substr($line,0,9);
   my $field = substr($line,10);
   chomp $field;

   my $found;

   for my $i (0..$n) {
       if ( $field eq $marc_old{$i} ) {
            $found = 1;
            print $output $sys . ' ' . $marc_new{$i} . "\n";
       }
   }

   print $output $line unless $found;
}

close $output;



