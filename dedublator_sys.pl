#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 CSV-Dokument mit BIB-Systemnummern des zu prüfenden Bestandes, Sublibrary-Code des zu prüfenden Bestandes, Sublibrary-Code des Bestandes, mit dem verglichen wird \n" unless @ARGV == 3;

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

# Text::CSV Module
use Text::CSV::Encoded;


my $csv = Text::CSV::Encoded->new({ sep_char => ';' });
 
my $csvfile = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $library = $ARGV[1] or die "Sublibrary-Code muss angegeben werden\n";
my $library2 = $ARGV[2] or die "Sublibrary-Code muss angegeben werden\n";

# Öffne csv-file und lese zeile für zeile ein 
open(my $csvdata, '<', $csvfile) or die "Could not open '$csvfile' $!\n";
while (my $line = <$csvdata>) {
    chomp $line;
    if ($csv->parse($line)) {
        my @fields = $csv->fields();

	#auslesen der csv-spalten
 	
	my $sys = $fields[0];

	my $syssru = "IDSBB" . $sys;
	my $sys035 = "(IDSBB)" . $sys;

	my $div = "#";

	
	my $query = "dc.anywhere=$syssru and dc.possessingInstitution=$library";

        # Catmandu-Importer für SRU-Abfrage
        my $importer = Catmandu::Importer::SRU->new(
		base => 'http://sru.swissbib.ch/sru/search/ddefaultdb',
		query => $query,
		recordSchema => 'info:srw/schema/1/marcxml-v1.1-light',
		parser => 'marcxml',
        );

	#print $importer->url . "\n";


	my $dublet = 0;
	my $true = 0;

        $importer->each(sub {


	    my $data = $_[0];

	    #my $sysnum = $data->{'_id'};
            marc_remove($data, 'LDR');
	    
	    for my $j ("000" .. "999") {
        	marc_remove($data, $j) unless $j =~ /035|949/;
            }
	    

	    for my $k (0 .. 10000) {
		 if ($data->{record}[$k][0] == '035' ) {
		     if ( $data->{record}[$k][4] eq $sys035 ) {
		         $true = 1
		     }
		 }
            }

	    if ($true) { 
	        for my $l (0 .. 10000) {
	    	    if ($data->{record}[$l][0] == '949' ) {
	                if ( $data->{record}[$l][6] eq $library2 ) {
			    $dublet = 1;
		        }
		    }
		}
	    }
       });
	    
       print $sys; 
       
       if ($dublet == 1) {	    
            print $div . "Dublet mit $library2";
       } elsif (!$true)  {
            print $div . "Exemplar nicht gefunden";
       } else {
            print $div . "Keine Dublette";
       }
       print "\n";

   }
}



