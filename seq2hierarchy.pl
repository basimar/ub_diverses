#!usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

# Data::Dumper für Debugging
use Data::Dumper;

die "Argumente: $0 Input-Dokument (alephseq) \n" unless @ARGV == 1;

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

# Catmandu-Module
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::Inline::marc_remove qw(:all);
use Catmandu::Fix::Inline::marc_add qw(:all);
use Catmandu::Exporter::MARC;

use List::MoreUtils qw(uniq);


my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $ARGV[0]);

my @sysnum;
my @down; 
my @up; 

my @daughter; 
my @mother; 
my @grandmother; 
my @ggrandmother; 
my @gggrandmother; 
my @ggggrandmother; 
my @gggggrandmother; 
my @ggggggrandmother; 
my @gggggggrandmother; 

$importer->each(sub {
        
	my $data = $_[0];
        my $sysnum = $data->{'_id'};
        push @sysnum, $sysnum;

        my @f490w = marc_map($data, '490w') unless marc_map($data, '490w') eq '';
        my @f773w = marc_map($data, '773w') unless marc_map($data, '773w') eq '';

        my @link = (@f490w , @f773w);

        for (@link) {
            $_ = sprintf( "%-9.9d", $_);
        }

        if ( @link > 0) {
            push @down, $sysnum;
            for (@link) { 
                push @up, $_
            } 
        }
        
        #my %seen;
        #
        #for my $number (@link) {
        #    next unless $seen{$number}++;
        #    print "Duplicate linking field in $sysnum\n";
        #}

        
        
});

@down = uniq(@down);
@up = uniq(@up);

print "Tochteraufnahmen: " . scalar @down . "\n";
print "Mutteraufnahmen: " . scalar @up . "\n";

#for (@up) {
#    print $_;
#    my $sysnum = $_;
#    for (@sysnum) {
#        if ( $_ eq $sysnum ) {
#            push @mother, $_
#        }
#    }
#}

for (@up) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @grandmother, $_
        }
    }
}

print "Grossmutteraufnahmen: " . scalar @grandmother . "\n";

for (@grandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @ggrandmother, $_
        }
    }
}

for (@ggrandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @gggrandmother, $_
        }
    }
}
 
for (@gggrandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @ggggrandmother, $_
        }
    }
}
 
 
for (@ggggrandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @gggggrandmother, $_
        }
    }
}
 
for (@gggggrandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @ggggggrandmother, $_
        }
    }
}
 
for (@ggggggrandmother) {
    my $sysnum = $_;
    for (@down) {
        if ($sysnum eq $_) {
            push @gggggggrandmother, $_
        }
    }
}
 
print "Urgrossmutteraufnahmen: " . scalar @ggrandmother . "\n";
print "Ururgrossmutteraufnahmen: " . scalar @gggrandmother . "\n";
print "Urururgrossmutteraufnahmen: " . scalar @ggggrandmother . "\n";
print "Ururururgrossmutteraufnahmen: " . scalar @gggggrandmother . "\n";
print "Urururururgrossmutteraufnahmen: " . scalar @ggggggrandmother . "\n";
print "Ururururururgrossmutteraufnahmen: " . scalar @gggggggrandmother . "\n";

exit;
