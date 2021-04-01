#!usr/bin/env perl

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
        $record{$sysnum}{oldsignature} = marc_map($data, '852[E]');
        $record{$sysnum}{title} = marc_map($data, '245');
        $record{$sysnum}{description} = marc_map($data, '300');
        $record{$sysnum}{time} = marc_map($data, '260');
        $record{$sysnum}{level} = marc_map($data, '351c');
        $record{$sysnum}{provenienz} = marc_map($data, '902[6]');

});

foreach (keys %record) {
	if ($record{$_}{provenienz} =~ 'Kartause Basel') {
 		print $record{$_}{signature} . "&&" . $record{$_}{oldsignature} . "&&" . $record{$_}{title} . "&&" . $_ . "\n";	
	}
}



exit


