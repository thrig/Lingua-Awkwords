#!perl

use Test::Most;    # plan is down at bottom

use Lingua::Awkwords::Set;

my $set = Lingua::Awkwords::Set->new;
isa_ok( $set, 'Lingua::Awkwords::Set' );

plan tests => 1;
