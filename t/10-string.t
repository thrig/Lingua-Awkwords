#!perl

use Test::More;    # plan is down at bottom

use Lingua::Awkwords::String;

my $str = Lingua::Awkwords::String->new( string => 'asdf' );
isa_ok( $str, 'Lingua::Awkwords::String' );
is( $str->render, 'asdf' );

plan tests => 2;
