#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 CSV-Dokument mit ISBN-Nummern \n" unless @ARGV == 1;

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

# Öffne csv-file und lese zeile für zeile ein 
open(my $csvdata, '<', $csvfile) or die "Could not open '$csvfile' $!\n";
while (my $line = <$csvdata>) {
    chomp $line;
    if ($csv->parse($line)) {
        my @fields = $csv->fields();

	#auslesen der csv-spalten
	
	my $isbn = $fields[0];

	my $marc;
	my $div = "#";
	
	my $query = "dc.identifier=$isbn";

        my $exporter = Catmandu->exporter('MARC', file => \$marc, type => 'ALEPHSEQ' );

        # Catmandu-Importer für SRU-Abfrage
        my $importer = Catmandu::Importer::SRU->new(
		base => 'http://sru.swissbib.ch/sru/search/ddefaultdb',
		query => $query,
		recordSchema => 'info:srw/schema/1/marcxml-v1.1-light',
		parser => 'marcxml',
        );

	#print $importer->url . "\n";


	my $dublet = 0;
	my $library_kurier;
	my $library_bern;

	my $f072;
	my $f082;

        $importer->each(sub {

	    my $data = $_[0];
	    
	    #my $sysnum = $data->{'_id'};
            marc_remove($data, 'LDR');
	    
	    for my $j ("000" .. "999") {
        	marc_remove($data, $j) unless $j =~ /949|912|082/;
            }
	    

	    for my $k (0 .. 10000) {
		 if ($data->{record}[$k][0] == '949' ) {
	             if ( $data->{record}[$k][6] =~ /B400|B404|B410|B500|B415|B452|B465|B517/ ) {
			$library_kurier = $library_kurier . " " . $data->{record}[$k][6];
			$dublet = 1;
		     } elsif ($data->{record}[$k][6] =~ /^B[0-9]{3}$/ ) {
			$library_bern = $library_bern . " " . $data->{record}[$k][6];
			$dublet = 1;
		     } else {
			$data->{record}[$k] = [];
		     }
		 } elsif ($data->{record}[$k][0] == '912') {
		     if ( $data->{record}[$k][6] =~ /SzZuIDS BS\/BE/ ) {
			 $f072 = $f072 . " " .  $data->{record}[$k][4];
		     }
		 } elsif ($data->{record}[$k][0] == '082') {
			 $f082 = $f082 . " " .  $data->{record}[$k][4];
		 }

            }
       });
       $f072 = substr($f072,1);
       $f082 = substr($f082,1);
	    
       print $isbn . $div; 
       
       if ($dublet) {	    
            #$exporter->add($data);
            #$exporter->commit;
            print $div . $library_kurier . $div;
            print $library_bern . $div;
		#print $marc . "\n";
       } else {
            print "nicht im IDS Bern" . $div . $div . $div ;
       }
       print $f072 . $div . $f082 . "\n";

   }
}

#my $testfile = $ARGV[2]; 
#my $outfile = $ARGV[3]; 
#open(my $test, '>:encoding(UTF-8)', $testfile) or die "Could not open file '$testfile' $!";
#open(my $output, '>:encoding(UTF-8)', $outfile) or die "Could not open file '$outfile' $!";

#my $seqfile = $ARGV[1];
#open(my $seqdata, '<:encoding(UTF-8)', $seqfile) or die "Could not open '$seqfile' $!\n";
#
#while (my $line = <$seqdata>) {
#chomp $line;
##print substr($line,0,9) . "\n";
#my $testok = 0;
#my $outputok = 0;
#my $outputline;
#
#for my $i (0..$n) {
#if (substr($line,0,9) == $sys{$i}) {
#
#if (substr($line,10,3) eq $num{$i}) {
#$testok = 1; 
#
#if (($line =~ /\$\$a$name{$i}/ ) && ($line =~ /$life{$i}/) && ($marc{$i} ne ""))  {
#
#$outputok = 1; 
#$outputline = "$marc{$i}";
#$check{$i} = 1;
#
#if ($line =~ /\$\$e(.*)\$\$4(.*)(\$\$|$)/) {
#$outputline .= "\$\$e$1\$\$4$2"
#} elsif ($line =~ /\$\$4(.*)\$\$e(.*)(\$\$|$)/) {
#$outputline .= "\$\$e$2\$\$4$1"
#}
#} 
#}
#}
#}
#print $test "$line\n" if $testok;
#
#if ($outputok) {
#print $output "$outputline\n";
#} elsif ($testok) {
#print $output "$line\n";
#}
#}
#
#for my $k (0..$n) {
#unless ($check{$k}) {
#print $marc{$k} . ":  " . $gnd{$k} . " - " . $sys{$k} . " - " . $num{$k} . " - " . $name{$k} . " - " . $life{$k} . "\n";
#}
#}
#
#close $output;



