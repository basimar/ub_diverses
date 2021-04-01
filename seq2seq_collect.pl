#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (alephseq), \n" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::Inline::marc_add qw(:all);

#use lib '/home/basil/catmandu/seq2marcxml/';
#use XML_bmt;

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

my @place;

$importer->each(sub {
        
	my $data = $_[0];
        my $sysnum = $data->{'_id'};

        my $f008 = marc_map($data, '008');
        my $year;
        if (substr($f008,7,4) =~ /^\d+?$/) {
             $year = substr($f008,7,4);
        } else {
             $year = 40000;
        }
        my $f852a = marc_map($data, '852[  ]a');
        my $f852b = marc_map($data, '852[  ]b');
        my $f852p = marc_map($data, '852[  ]p');
             
        
        if (($f852a =~ /Basel UB/) && ($f852b =~ /Handschriften/)) {
                if ($f852p =~ /^(A|B|C|D|E|F|K|L|M|N|O|R|AN|P\.Bas\.|AR\sII|AR\sIII)(\s|$)/) {
                    unless ($f852p =~ /^(C\sVIa|C\sVIb|L\sIa|L\sIb|A\slambda)(\s|$)/) {
                        print $sysnum . ' 909   L $$fcollect_this handschrift' . "\n";
                        if ($f852p =~ /^(AR\sII|AR\sIII)(\s|$)/) {
                            print  $sysnum . ' 909   L $$fhide_this ubarchiv' . "\n";
                        }
                    }
                }
                if ($f852p =~ /^(Autogr|Autogr\sallg|Bernoulli|Brüderlin|BurckhardtC|BurckhardtR|Geigy-Hagenbach|Gelzer|Menzel|SarasinCH|SarasinF|Schulthess|Stickelberger|Stumm|G|G2|L\sIa)(\s|$)/) {
                    print  $sysnum . ' 909   L $$fcollect_this sammlung' . "\n";
                }
                if ($f852p =~ /^(Archiv|Archiv\sBernoulli|ChrG|SMG|SPG|UB|C\sVIa|C\sVIb|H\sVI|L\sIb|NL|)(\s|$)/) {
                    print $sysnum . ' 909   L $$fcollect_this archivgut' . "\n";
                }             
        }
        if ($f852a =~ /Bern Gosteli-Archiv/) {
                if ($f852b =~ /Biografische Notizen/) {
                    print $sysnum . ' 909   L $$fcollect_this sammlung' . "\n";
                }
                if ($f852p =~ /^AGoF/) {
                    print $sysnum . ' 909   L $$fcollect_this archivgut' . "\n";
                }
        } 
        if ($f852a =~ /Luzern ZHB/) {
                if (($f852p =~ /^Msc/) || ($f852p =~ /^P/)) {
                    print $sysnum . ' 909   L $$fcollect_this handschrift' . "\n";
                }
        }
        if ($f852a =~ /St. Gallen KB Vadiana/) {
                if (($f852p =~ /^VadSlg/) && ($year < 1500)) {
                    print $sysnum . ' 909   L $$fcollect_this handschrift' . "\n";
                }
        }
        if ($f852a =~ /St. Gallen Stiftsbibliothek/) {
                print $sysnum . ' 909   L $$fcollect_this handschrift' . "\n";
        }
   
});




