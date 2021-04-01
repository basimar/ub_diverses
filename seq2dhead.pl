#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (alephseq)\n" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC;
use Catmandu::Fix::Inline::marc_add qw(:all);
use Catmandu::Fix::marc_remove as => 'marc_remove';

my $importer1 = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

$importer1->each(sub {

    my $data = $_[0];
    my $sysnum = $data->{'_id'};

    my $f1001 = marc_map($data, '1001');
    my $f1101 = marc_map($data, '1101');
    my $f1111 = marc_map($data, '1111');
    
    my $f1004 = marc_map($data, '1004');
    my $f1104 = marc_map($data, '1104');
    my $f1114 = marc_map($data, '1114');

    my $f100 = $f1001 . $f1004 ;
    my $f110 = $f1101 . $f1104 ;
    my $f111 = $f1111 . $f1114 ;

    my @f7001 = marc_map($data, '7001');
    my @f7101 = marc_map($data, '7101');
    my @f7111 = marc_map($data, '7111');
    
    my @f7004 = marc_map($data, '7004');
    my @f7104 = marc_map($data, '7104');
    my @f7114 = marc_map($data, '7114');

    my @f700;
    my @f710;
    my @f711;

    foreach my $i (1 .. @f7001 -1) {
        $f700[$i] = $f7001[$i] . $f7004[$i] 
    }
    
    foreach my $i (1 .. @f7101 -1) {
        $f710[$i] = $f7101[$i] . $f7104[$i]
    }
    
    foreach my $i (1 .. @f7111 -1) {
        $f711[$i] = $f7111[$i] . $f7114[$i]
    }

    my %seen_per;
    my %seen_kor;
    my %seen_kon;

    # Check for duplicate GND-Number

    #foreach my $string_per (@f7001) {
    #    next if $string_per eq "";
    #    print "$sysnum $string_per is duplicated person with 100.\n" if $string_per eq $f1001;
    #    next unless $seen_per{$string_per}++;
    #    print "$sysnum $string_per is duplicated person.\n";
    #} 
    #foreach my $string_kor (@f7101) {
    #    next if $string_kor eq "";
    #    print "$sysnum $string_kor is duplicated cooperation with 110.\n" if $string_kor eq $f1101;
    #    next unless $seen_kor{$string_kor}++;
    #    print "$sysnum $string_kor is duplicated cooperation.\n";
    #} 
    #foreach my $string_kon (@f7111) {
    #    next if $string_kon eq "";
    #    print "$sysnum $string_kon is duplicated congress with 111.\n" if $string_kon eq $f1111;
    #    next unless $seen_kon{$string_kon}++;
    #    print "$sysnum $string_kon is duplicated congress.\n";
    #} 
    
    # Check for duplicate GND-Number + relator-code

    foreach my $string_per (@f700) {
        next if $string_per eq "";
        print "$sysnum $string_per is duplicated person with 100.\n" if $string_per eq $f100;
        next unless $seen_per{$string_per}++;
        print "$sysnum $string_per is duplicated person.\n";
    } 
    foreach my $string_kor (@f710) {
        next if $string_kor eq "";
        print "$sysnum $string_kor is duplicated cooperation with 110.\n" if $string_kor eq $f110;
        next unless $seen_kor{$string_kor}++;
        print "$sysnum $string_kor is duplicated cooperation.\n";
    } 
    foreach my $string_kon (@f711) {
        next if $string_kon eq "";
        print "$sysnum $string_kon is duplicated congress with 111.\n" if $string_kon eq $f111;
        next unless $seen_kon{$string_kon}++;
        print "$sysnum $string_kon is duplicated congress.\n";
    } 
    
});

# Adaption of the marc_map function of the Catmandu Projekt
# If a repeated field is present, Catmandu only extracts the subfields into an array if they exist.
# This causes a problem if we later want to combine different subfields with the isbd sub.
# 1st field 700b   -> marc_map(700b) will create an array with 1 element, marc_map(700a) will do nothing
# 2nd field 700ab  -> marc_map(700b) will add a second element to the array, marc_map(700a) will create an array with one element
# If we now want to combine subfields a and b, we will combine subfield a of the second field with subfield b of the first
# Solution (i.e. hack): Create an empty aray element even if no subfield is found.

sub marc_map {
    my ( $data, $marc_path, %opts ) = @_;

    return unless exists $data->{'record'};

    my $record = $data->{'record'};

    unless ( defined $record && ref $record eq 'ARRAY' ) {
        return wantarray ? () : undef;
    }

    my $split     = $opts{'-split'};
    my $join_char = $opts{'-join'} // '';
    my $pluck     = $opts{'-pluck'};
    my $attrs     = {};

    if ( $marc_path =~
        /(\S{3})(\[(.)?,?(.)?\])?([_a-z0-9^]+)?(\/(\d+)(-(\d+))?)?/ )
    {
        $attrs->{field}          = $1;
        $attrs->{ind1}           = $3;
        $attrs->{ind2}           = $4;
        $attrs->{subfield_regex} = defined $5 ? "[$5]" : "[a-z0-9_]";
        $attrs->{from}           = $7;
        $attrs->{to}             = $9;
    }
    else {
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
            for ( my $i = $start ; $i < @$var ; $i += 2 ) {
                push @{ $_h->{ $var->[$i] } }, $var->[ $i + 1 ];
            }
            for my $c ( split( '', $attrs->{subfield_regex} ) ) {
                push @v, @{ $_h->{$c} } if exists $_h->{$c};
            }
        }
        else {
            my $found = "false";
            for ( my $i = $start ; $i < @$var ; $i += 2 ) {
                if ( $var->[$i] =~ /$attrs->{subfield_regex}/ ) {
                    push( @v, $var->[ $i + 1 ] );
                    $found = "true";
                }
            }
            if ( $found eq "false" ) {
                # !!! The following line was changes from Catmandu. Pushes an empty string, if no subfield is found
                push( @v, "" );
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

        if ( $var->[0] =~ /LDR|00./ ) {
            $v = $add_subfields->( $var, 3 );
        }
        elsif ( defined $var->[5] && $var->[5] eq '_' ) {
            $v = $add_subfields->( $var, 5 );
        }
        else {
            $v = $add_subfields->( $var, 3 );
        }

        if (@$v) {
            if ( !$split ) {
                $v = join $join_char, @$v;

                if ( defined( my $off = $attrs->{from} ) ) {
                    my $len =
                      defined $attrs->{to} ? $attrs->{to} - $off + 1 : 1;
                    $v = substr( $v, $off, $len );
                }
            }
        }

        push( @vals, $v
          )   #if ( (ref $v eq 'ARRAY' && @$v) || (ref $v eq '' && length $v ));
    }

    if (wantarray) {
        return @vals;
    }
    elsif ( @vals > 0 ) {
        return join $join_char, @vals;
    }
    else {
        return undef;
    }
}

exit;
