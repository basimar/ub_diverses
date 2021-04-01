#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

use IO::File;

die "Argumente: $0 Input-Dokument (alephseq)" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

#Zeit auslesen für Header
use Time::Piece;
my $date = localtime;

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
# Marc-Map ausgeschaltet, da modifiziertes SUB direkt im Skript
# use Catmandu::Fix::Inline::marc_map qw(:all);

my $output = IO::File->new(">$ARGV[1]");


my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);
$importer->each(sub {
        
	my $data = $_[0];
	my $sysnum = $data->{'_id'};

        my $oldnum = marc_map($data, '090a');	

        my $author100a = marc_map($data, '100a');
	my $author100d = marc_map($data, '100d');

        my $nachlass =  marc_map($data, '830');

        my @language = marc_map($data, '546a');
        my @entstehung = marc_map($data, '593a');
        my @literatur = marc_map($data, '581a');
	
	my $signature = marc_map($data, '852[ ]d');
        my $institution = marc_map($data, '852[ ]b');
        my @link = marc_map($data, '856u');
        
        my @adressee901a = marc_map($data, '901[9 ]a');
	my @adressee901b = marc_map($data, '901[9 ]b');
	my @adressee901c = marc_map($data, '901[9 ]c');
	my @adressee901d = marc_map($data, '901[9 ]d');

	my @korrespondent = marc_map($data, '903a');
        
        my $bernoulli = marc_map($data, '909f');
	
	if ($bernoulli =~ "bernoulli") {
	#if ($nuennullsechs =~ "Briefe") {
		
		my @adressee901;
		my $adressee901_max = maxarray(\@adressee901a, \@adressee901b, \@adressee901c, \@adressee901d);
		for my $i (0 .. ($adressee901_max)-1) {
			if (hasvalue($adressee901a[$i])) {
				$adressee901[$i] = $adressee901a[$i]
			}
			if (hasvalue($adressee901b[$i])) {
				$adressee901[$i] = $adressee901[$i] . " " . $adressee901b[$i]
			}
			if (hasvalue($adressee901c[$i])) {
				$adressee901[$i] = $adressee901[$i] . " " . $adressee901c[$i]
			}
			if (hasvalue($adressee901d[$i])) {
				$adressee901[$i] = $adressee901[$i] . ' <' . $adressee901d[$i] . '>'
			}
		}

		my $author = $author100a;
		if (hasvalue($author100d)) {
				$author .= ' (' . $author100d . ')'
			}

		print $nachlass . "¬";
                foreach (@korrespondent) {print "€" . $_};
		print "¬";
                print $author . "¬";
		foreach (@entstehung) {print "€" . $_};
		print "¬";
		foreach (@language) {print "€" . $_};
		print "¬";
		foreach (@literatur) {print "€" . $_};
		print "¬";
		foreach (@link) {print "€" . $_};
		print "¬";
		print 'http://aleph.unibas.ch/F/?local_base=DSV05&con_lng=GER&func=find-b&find_code=SYS&request=' . $sysnum . "¬";
		print "¬";
		print $institution;
		print "¬";
		print $signature;
		print "¬";
		print $sysnum;
		print "¬";
		print $oldnum;
		print "\n";
	}
});

sub marc_map {
    my ($data,$marc_path,%opts) = @_;
 
    return unless exists $data->{'record'};
 
    my $record = $data->{'record'};
 
    unless (defined $record && ref $record eq 'ARRAY') {
        return wantarray ? () : undef;
    }
 
    my $split     = $opts{'-split'};
    my $join_char = $opts{'-join'} // '';
    my $pluck     = $opts{'-pluck'};
    my $attrs     = {};
 
    if ($marc_path =~ /(\S{3})(\[(.)?,?(.)?\])?([_a-z0-9^]+)?(\/(\d+)(-(\d+))?)?/) {
        $attrs->{field}          = $1;
        $attrs->{ind1}           = $3;
        $attrs->{ind2}           = $4;
        $attrs->{subfield_regex} = defined $5 ? "[$5]" : "[a-z0-9_]";
        $attrs->{from}           = $7;
        $attrs->{to}             = $9;
    } else {
        return wantarray ? () : undef;
    }
 
    $attrs->{field_regex} = $attrs->{field};
    $attrs->{field_regex} =~ s/\*/./g;
 
    my $add_subfields = sub {
        my $var   = shift;
        my $start = shift;
 
        my @v = ();
 
        if ($pluck) {
            # Treat the subfield_regex as a hash index
            my $_h = {};
            for (my $i = $start; $i < @$var; $i += 2) {
                push @{ $_h->{ $var->[$i] } } , $var->[$i + 1];
            }
            for my $c (split('',$attrs->{subfield_regex})) {
                push @v , @{ $_h->{$c} } if exists $_h->{$c};
            }
        }
        else {
            my $found = "false";
            for (my $i = $start; $i < @$var; $i += 2) {
                if ($var->[$i] =~ /$attrs->{subfield_regex}/) {
                    push(@v, $var->[$i + 1]);
                    $found = "true";
                }
            }
            if ($found eq "false") {
               push(@v, "");
            }
        }
 
        return \@v;
    };
 
    my @vals = ();
 
    for my $var (@$record) {
        next if $var->[0] !~ /$attrs->{field_regex}/;
        next if defined $attrs->{ind1} && $var->[1] ne $attrs->{ind1};
        next if defined $attrs->{ind2} && $var->[2] ne $attrs->{ind2};
 
        my $v;
 
        if ($var->[0] =~ /LDR|00./) {
                $v = $add_subfields->($var,3);
        }
        elsif (defined $var->[5] && $var->[5] eq '_') {
                $v = $add_subfields->($var,5);
        }
        else {
                $v = $add_subfields->($var,3);
        }
 
        if (@$v) {
                if (!$split) {
                        $v = join $join_char, @$v;
 
                        if (defined(my $off = $attrs->{from})) {
                                my $len = defined $attrs->{to} ? $attrs->{to} - $off + 1 : 1;
                                $v = substr($v,$off,$len);
                        }
                }
        }
 
        push (@vals,$v) ;#if ( (ref $v eq 'ARRAY' && @$v) || (ref $v eq '' && length $v ));
    }
 
    if (wantarray) {
        return @vals;
    }
    elsif (@vals > 0) {
        return join $join_char , @vals;
    }
    else {
        return undef;
    }
}

sub maxarray{
    my $max;
    foreach my $i (0 .. (@_ - 1)) {
         $max = scalar @{$_[$i]} if scalar @{$_[$i]} > $max ;
    }
    return $max;
}

sub hasvalue{
    my $i = 1 if defined $_[0] && $_[0] ne "";
    return $i;  
}

exit


