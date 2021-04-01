#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Perl-Module:

# Data::Dumper für Debugging
use Data::Dumper;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;

# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
# Damit das funktioniert, muss /usr/local/share/perl/5.22.1/Catmandu/Importer/SRU.pm modifziert werden (Entferne swr-Elemente), bis Günter Swissbib-SRU fixt
use Catmandu::Importer::SRU;
use Catmandu::Fix::marc_remove as => 'marc_remove';

# Text::CSV Module
use Text::CSV::Encoded;
my $csv = Text::CSV::Encoded->new({ sep_char => ';' });

# Prüfung der Argumente, mit denen das Script ausgeführt wird:
# 1. Argument: CSV-Datei mit BIB-Systemnummern (neunstellig, mit führenden Nullen)
# 2. Argument: Sublibrary-Code des zu prüfenden Bestandes
# 2. Argument: Sublibrary-Code, mit dem verglichen werden soll

die "Argumente: $0 CSV-Dokument mit BIB-Systemnummern des zu prüfenden Bestandes, Sublibrary-Code des zu prüfenden Bestandes, Sublibrary-Code des Bestandes, mit dem verglichen wird \n" unless @ARGV == 3;

my $csvfile = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $library_input = $ARGV[1] or die "Sublibrary-Code muss angegeben werden\n";
my $library_compare = $ARGV[2] or die "Sublibrary-Code muss angegeben werden\n";

# Öffne csv-file und lese Zeile für Zeile ein 
open(my $csvdata, '<', $csvfile) or die "Could not open '$csvfile' $!\n";
while (my $line = <$csvdata>) {
    chomp $line;
    if ($csv->parse($line)) {
        my @fields = $csv->fields();

	# Auslesen der CSV-Spalten: Systemnummer befindet sich in erster Spalte 
 	
	my $sys = $fields[0];

	my $syssru = "IDSBB" . $sys;
	my $sys035 = "(IDSBB)" . $sys;

	my $div = "#";

        # Definition der SRU-Anfrage: Suche nach Systemnummer und Bibliothekscode des zu vergleichenden Bestandes
	
	my $query = "dc.anywhere=$syssru and dc.possessingInstitution=$library_input";

        # Catmandu-Importer für SRU-Abfrage
        my $importer = Catmandu::Importer::SRU->new(
		base => 'http://sru.swissbib.ch/sru/search/ddefaultdb',
		query => $query,
		recordSchema => 'info:srw/schema/1/marcxml-v1.1-light',
		parser => 'marcxml',
        );

        # Gib URL der SRU-Abfrage aus, um Anfrage zu debuggen
        # print $importer->url . "\n";

	my $dublet = 0;

        # Catmandu-Importer geht jeden SRU-Treffer duch (im Idealfall sollte nur jeweils ein Treffer gefunden werden)

        $importer->each(sub {

	    my $data = $_[0];
	    my $correct_record = 0;
	    my $sysnum = $data->{'_id'};

            # Erläuterung MARC-Datenstruktur als Catmandu-Element
            # Der MARC-Datensatz wird von Catmandu als verschachtelte Struktur importiert:
            # $data->{record}: Enthält den gesamten MARC-Datensatz
            # $data->{record}[0]: 1. MARC-Feld im Datensatz 
            # $data->{record}[1]: 2. MARC-Feld im Datensatz 
            # $data->{record}[2]: 3. MARC-Feld im Datensatz etc.
            # $data->{record}[0][0]: Feldnummer (dreistellig) des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][1]: Indikator 1 des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][2]: Indikator 2 des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][3]: Unterfeldcode des 1. Unterfeldes des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][4]: Inhalt des 1. Unterfeldes des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][5]: Unterfeldcode des 2. Unterfeldes des 1. MARC-Feldes im Datensatz 
            # $data->{record}[0][6]: Inhalt des 2. Unterfeldes des 1. MARC-Feldes im Datensatz etc.

            # Entferne LDR-Feld
            marc_remove($data, 'LDR');

            # Entferne alle MARC-Felder ausser Feld 035 (Systemnummer) und 949 (Exemplardaten)
            # Die restlichen Felder brauchen wir nicht, und müssen nicht extra durchsucht werden.
	    for my $field_code ("000" .. "999") {
        	marc_remove($data, $field_code) unless $field_code =~ /035|949/;
            }

            # Gib Antwort von swissbib in Rohform aus, um Antwort zu debuggen
            print Dumper $data . "\n";
	    
            # Lese Anzahl MARC-Felder aus
            my $fields_number = scalar @{$data->{record}};

            # Gehe alle MARC-Felder durch
	    for my $fields (0 .. ($fields_number - 1)) {
                 
                 # Finde Feld 035
		 if ($data->{record}[$fields][0] == '035' ) {
               
                     # Prüfe nochmals, ob die Systemnummer wirklich in Feld 035 vorkommt 
		     if ( $data->{record}[$fields][4] eq $sys035 ) {
		         $correct_record = 1
		     }
		 }
            }

            # Falls es sich um die korrekte Aufnahme handelt, führe Dublettencheck aus
	    if ($correct_record) { 
                
                # Gehe alle MARC-Felder durch
	        for my $fields (0 .. ($fields_number - 1)) {
                    
                    # Finde Feld 949
	    	    if ($data->{record}[$fields][0] == '949' ) {

                        # Falls ein Feld 949 mit dem gesuchten Bibliothekscode vorkommt, setzte $dublet auf wahr
	                if ( $data->{record}[$fields][6] eq $library_compare ) {
			    $dublet = 1;
		        }
		    }
		}
	    }
       });

       # Ausgabe der Resultate
       print $sys; 
       
       if ($dublet) {	    
            print $div . "Dublet mit $library_compare";
       } else {
            print $div . "Keine Dublette";
       }
       print "\n";

   }
}



