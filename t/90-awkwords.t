#!perl
#
# and finally the main module itself

use strict;
use warnings;

use Test::Most;    # plan is down at bottom

my $deeply = \&eq_or_diff;

use Lingua::Awkwords;

my $la = Lingua::Awkwords->new;

dies_ok { $la->render };
dies_ok { $la->walk };

$la->pattern(q{ aaa });
is( $la->render, 'aaa' );

$la = Lingua::Awkwords->new( pattern => q{ V/catC } );
my @findings;
$la->walk(
    sub {
        my $self = shift;
        push @findings, ref $self;
    }
);

$deeply->(
    [ map { s/Lingua::Awkwords:://r } @findings ],
    # TODO ListOf with a single choice could be replaced with that
    # single choice, to simplify the tree
    #   /     LHS    V          RHS    "cat"  C
    [qw{OneOf ListOf Subpattern ListOf String Subpattern}]
);

plan tests => 4;
