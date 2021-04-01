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
# Marc-Map ausgeschaltet, da modifiziertes SUB direkt im Skript
# use Catmandu::Fix::Inline::marc_map qw(:all);

my $output = IO::File->new(">$ARGV[1]");


my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);
$importer->each(sub {
        
	my $data = $_[0];
	my $sysnum = $data->{'_id'};

	my $nuennullsechs = marc_map($data, '906a');
	my $signature = marc_map($data, '852[ ]d');
        my $institution = marc_map($data, '852[ ]b');
        my $person100a = marc_map($data, '100a');
        my $person100b = marc_map($data, '100b');
        my $person100c = marc_map($data, '100c');
        my $person100d = marc_map($data, '100d');
        my @person700a = marc_map($data, '700a');
	my @person700b = marc_map($data, '700b');
	my @person700c = marc_map($data, '700c');
	my @person700d = marc_map($data, '700d');
	my @person710a = marc_map($data, '710a');
	my @person710b = marc_map($data, '710b');
	my @person710c = marc_map($data, '710c');
	my @person710d = marc_map($data, '710d');
	my $umfang = marc_map($data, '300a');
	my $beilagen = marc_map($data, '300e');
	my $bemerkung = marc_map($data, '856z');
	my $multi = marc_map($data, '856u');
	my @creationa = marc_map($data, '260a');
	my $creationc = marc_map($data, '260c');
	my $languages041 = marc_map($data, '041a');
	my $field008= marc_map($data, '008');
	my $language008 = substr($field008, 35, 3);
	my @adressee901a = marc_map($data, '901[9 ]a');
	my @adressee901b = marc_map($data, '901[9 ]b');
	my @adressee901c = marc_map($data, '901[9 ]c');
	my @adressee901d = marc_map($data, '901[9 ]d');
	my @adressee902a = marc_map($data, '902[9 ]a');
	my @adressee902b = marc_map($data, '902[9 ]b');
 	my @origination = marc_map($data, '752d');
	my @grad655 = marc_map($data, '655a');
	my $grad250 = marc_map($data, '250a');
	my $grad300 = marc_map($data, '300b');
	my @entstehung = marc_map($data, '593a');
	my @inhalta = marc_map($data, '520a');
	my @inhaltb = marc_map($data, '520b');
  	
	if (($nuennullsechs =~ "Briefe") && (($person100a eq "Rotmund, Johann Caspar") || (grep(/Rotmund, Johann Caspar/ , @adressee901a)) )) {
	#if ($nuennullsechs =~ "Briefe") {
		my $grad;
		foreach (@grad655) {
			if ($_ eq "Autograph") {
				$grad = "Autograph";
				last
			}
		}

		unless (defined($grad)) {
			$grad = $grad250
		}

		unless (defined($grad)) {
			$grad = $grad300
		}


        	my $person100;
        	if (hasvalue($person100a)) {
			$person100 = $person100a
		}
		if (hasvalue($person100b)) {
			$person100 = $person100 . " " . $person100b
		}
		if (hasvalue($person100c)) {
			$person100 = $person100 . " " . $person100c
		}
		if (hasvalue($person100d)) {
			$person100 = $person100 . ' <' . $person100d . '>'
		}

        
		my @person700;
		my $person700_max = maxarray(\@person700a, \@person700b, \@person700c, \@person700d);
		for my $i (0 .. ($person700_max)-1) {
			if (hasvalue($person700a[$i])) {
				$person700[$i] = $person700a[$i]
			}
			if (hasvalue($person700b[$i])) {
				$person700[$i] = $person700[$i] . " " . $person700b[$i]
			}
			if (hasvalue($person700c[$i])) {
				$person700[$i] = $person700[$i] . " " . $person700c[$i]
			}
			if (hasvalue($person700d[$i])) {
				$person700[$i] = $person700[$i] . ' <' . $person700d[$i] . '>'
			}
		}

		my @person710;
		my $person710_max = maxarray(\@person710a, \@person710b, \@person710c, \@person710d);
		for my $i (0 .. ($person710_max)-1) {
			if (hasvalue($person710a[$i])) {
				$person710[$i] = $person710a[$i]
			}
			if (hasvalue($person710b[$i])) {
				$person710[$i] = $person710[$i] . " " . $person710b[$i]
			}
			if (hasvalue($person710c[$i])) {
				$person710[$i] = $person710[$i] . " " . $person710c[$i]
			}
			if (hasvalue($person710d[$i])) {
				$person710[$i] = $person710[$i] . ' <' . $person710d[$i] . '>'
			}
		}

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
			if (hasvalue($person710d[$i])) {
				$adressee901[$i] = $adressee901[$i] . ' <' . $adressee901d[$i] . '>'
			}
		}

		my @adressee902;
		my $adressee902_max = maxarray(\@adressee902a, \@adressee902b);
		for my $i (0 .. ($adressee902_max)-1) {
			if (hasvalue($adressee902a[$i])) {
				$adressee902[$i] = $adressee902a[$i]
			}
			if (hasvalue($adressee902b[$i])) {
				$adressee902[$i] = $adressee902[$i] . ". " . $adressee902b[$i]
			}
		}

		my @inhalt;
		my $inhalt_max = maxarray(\@inhalta, \@inhaltb);
		for my $i (0 .. ($inhalt_max)-1) {
			if (hasvalue($inhalta[$i])) {
				$inhalt[$i] = $inhalta[$i]
			}
			if (hasvalue($inhaltb[$i])) {
				$inhalt[$i] = $inhalt[$i] . ". " . $inhaltb[$i]
			}
		}
        
		my $umfangbeilagen;
		if (hasvalue($umfang)) {
			$umfangbeilagen = $umfang
		}
		if (hasvalue($beilagen)) {
			$umfangbeilagen = $umfangbeilagen . ' + ' . $beilagen
		}

		my $languages;
		if (defined($languages041)) {
			my @languages041 = $languages041 =~ m/(...)/g;
		        $languages = $languages041[0];
			shift @languages041;
			foreach (@languages041) {
				$languages .= '€' . $_
			}
		} else {
			$languages = $language008;
		}

		print $institution . "¬" . $signature . "¬" . $person100 . "¬" . shift(@person700);
		foreach (@person700) {print "€" . $_}
		print "¬" . shift(@person710); 
	       	foreach (@person710) {print "€" . $_}
		print "¬" . $umfangbeilagen . "¬" . $bemerkung . "¬" . $multi . "¬";
		print 'http://aleph.unibas.ch/F/?local_base=DSV05&con_lng=GER&func=find-b&find_code=SYS&request=' . $sysnum . "¬";
		print "¬" . shift(@creationa);
		foreach (@creationa) {print "€" . $_};
		print "¬" . $creationc . "¬" . $languages, "¬" . shift(@adressee901);
		foreach (@adressee901) {print "€" . $_}
		print "¬" . shift(@adressee902); 
		foreach (@adressee902) {print "€" . $_}
		print "¬" . shift(@origination);
		foreach (@origination) {print "€" . $_};
		print "¬" . $grad . "¬" . shift(@entstehung);
		foreach (@entstehung) {print "€" . $_};
		print "¬" . shift(@inhalt);
		foreach (@inhalt) {print "€" . $_};
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


