#!perl

use strict;
use warnings;

use Test::Most;    # plan is down at bottom

my $deeply = \&eq_or_diff;

use Lingua::Awkwords::Subpattern;

# KLUGE this test could fail if rand() biased enough to skip one or more
# of the default vowels
my $picker = Lingua::Awkwords::Subpattern->new( pattern => 'V' );
my @vowels = map { $picker->render } 1 .. 30;
my %uniq;
@uniq{@vowels} = ();
$deeply->( \%uniq, { a => undef, i => undef, u => undef } );

# these must be key => arrayref pairs; update_pattern is more flexible
isa_ok( Lingua::Awkwords::Subpattern->set_patterns( X => ['a'] ),
    'Lingua::Awkwords::Subpattern' );

$picker = Lingua::Awkwords::Subpattern->new( pattern => 'X' );
is( $picker->render, 'a' );

# ref form
isa_ok( Lingua::Awkwords::Subpattern->update_pattern( X => ['b'] ),
    'Lingua::Awkwords::Subpattern' );
is( $picker->render, 'b' );

# list form
isa_ok( Lingua::Awkwords::Subpattern->update_pattern( X => 'c' ),
    'Lingua::Awkwords::Subpattern' );
is( $picker->render, 'c' );

# this is certainly not a new or dare I say Neo test...
dies_ok { $picker->pattern('there is no spoon') };

ok( Lingua::Awkwords::Subpattern->is_pattern('X') );
ok( !Lingua::Awkwords::Subpattern->is_pattern('there is no spoon') );

plan tests => 10;
