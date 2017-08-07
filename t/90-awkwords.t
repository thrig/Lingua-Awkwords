#!perl
#
# parser tests. these of course depend on the various modules used by
# the parse not misbehaving

use strict;
use warnings;

use Test::Most;    # plan is down at bottom

use Lingua::Awkwords;

my $la = Lingua::Awkwords->new;

dies_ok { $la->render };

$la->pattern(q{ aaa });

is( $la->render, 'aaa' );

plan tests => 2;
