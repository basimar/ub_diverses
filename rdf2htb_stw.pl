#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

#use IO::File;

die "Argumente: $0 Input Output Dokument\n" unless @ARGV == 2;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

#Zeit auslesen für Header
use Time::Piece;
my $date = localtime;

# Catmandu-Module
use Catmandu::Importer::RDF;
use RDF::aREF;
use Catmandu::Fix::aref_query as => 'my_query';
# Marc-Map ausgeschaltet, da modifiziertes SUB direkt im Skript
# use Catmandu::Fix::Inline::marc_map qw(:all);

#my $output = IO::File->new(">$ARGV[1]");


my %rdf = %{Catmandu::Importer::RDF->new( file => $ARGV[0], type => "ttl" )->first};


for my $record (keys %rdf) {
	if(ref($rdf{$record}{skos_broader}) eq 'ARRAY'){
		for (@{$rdf{$record}{skos_broader}}) {
			if (/thsys\/n/) {
				print_pref_label($record);
				add_children($record);
			}
		}
	} else {
		if ($rdf{$record}{skos_broader} =~ /thsys\/n/) {
			print_pref_label($record);
			add_children($record);	
		}
	}

}


sub print_pref_label {
	for (@{$rdf{$_[0]}{skos_prefLabel}}) {
		if (/\@de/) {
			my $label = $_;
			$label =~ s/\@de//g;
			print $label;
			print "\n";
		}
	}
}

sub add_children {

for my $record (keys %rdf) {
	if(ref($rdf{$record}{skos_broader}) eq 'ARRAY'){
		for (@{$rdf{$record}{skos_broader}}) {
			#print "Testarray\n";
			#print $_ . "\n";
			#print $_[0] . "\n";
			if ($_ =~ /$_[0]/) {
				print "SUB ";
				print_pref_label($record);
				add_children($record);
			}
		}
	} else {
		#print "Teststring\n";
		if ($rdf{$record}{skos_broader} =~ /$_[0]/) {
			
			print "SUB ";
			print_pref_label($record);
			add_children($record);
		}
	}
}}





	#for (@{$rdf{$record}{skos_prefLabel}}) {
	#	if (/\@de/) {
	#		my $prefLabel = $_;
	#		$prefLabel =~ s/\@de//g;
	#		print $prefLabel;
	#		print "\n";
	#	}
	#}
#}

#$rdf->each(sub {
#print "Test\n";        
#});




exit


