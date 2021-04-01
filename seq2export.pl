#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

use IO::File;

die "Argumente: $0 Input-Dokument (alephseq), Output Dokument\n" unless @ARGV == 2;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

#Zeit auslesen für Header
use Time::Piece;
my $date = localtime;

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);

my $output = IO::File->new(">$ARGV[1]");

my %record;
my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);
$importer->each(sub {
        
	my $data = $_[0];
	my $sysnum = $data->{'_id'};

        $record{$sysnum}{signature} = marc_map($data, '852[ ]');
        $record{$sysnum}{title} = marc_map($data, '245');
        $record{$sysnum}{description} = marc_map($data, '300');
        $record{$sysnum}{time} = marc_map($data, '260');
        $record{$sysnum}{level} = marc_map($data, '351c');

});

foreach (keys %record) {
	if ($record{$_}{signature} =~ 'CH SWA (HS (70|90|94|100|101|104|105|122|(17 |17$)|190|191|201|202|203|225|227|238|265|266|267|341|399)|PA (503|518))') {
 		print $record{$_}{signature} . "&&" . $record{$_}{title} . "&&" . $record{$_}{description} . "&&" . $record{$_}{time} . "&&" . $record{$_}{level} . "&&" . $_ . "\n";	
	}
}



exit


