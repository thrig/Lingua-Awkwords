# -*- Perl -*-
#
# subpatterns are named A-Z and offer short-hand notation for e.g. V =>
# a/e/i/o/u (or whatever) for vowels. these patterns can be changed
# without a reparse of the pattern

package Lingua::Awkwords::Subpattern;

use strict;
use warnings;
use Moo;
use namespace::clean;

our $VERSION = '0.01';

# these defaults set from what the online version does at
# http://akana.conlang.org/tools/awkwords/
my %patterns = (
    C => [qw/p t k s m n/],
    N => [qw/m n/],
    V => [qw/a i u/],
);

has pattern => (
    is  => 'rw',
    isa => sub {
        die "subpattern $_[0] does not exist" unless exists $patterns{ $_[0] };
    },
);

########################################################################
#
# METHODS

sub is_pattern {
    my (undef, $what) = @_;
    return exists $patterns{$what};
}

sub render {
    my ($self) = @_;

    my $sp = $self->pattern // die "subpattern not set";
    die "subpattern $sp does not exist" unless exists $patterns{$sp};

    # do not need Math::Random::Discrete here as the weights are always
    # equal; for weighted instead write that unit out manually via
    # [a*2/e/i/o/u] or such
    return @{ $patterns{$sp} }[ rand @{ $patterns{$sp} } ] // '';
}

sub set_patterns {
    my $class_or_self = shift;
    %patterns = @_;
    return $class_or_self;
}

sub update_pattern {
    my $class_or_self = shift;
    my $pattern       = shift;

    die "update needs a pattern and a list of values\n" unless @_;

    # NOTE that list-versus-arrayref are different in that a copy is
    # made of the list, while the arrayref is passed as-is; this allows
    # the caller to fiddle around with the arrayref without in turn
    # needing to make new update_pattern calls for each change.
    $patterns{$pattern} =
      ( defined $_[0] and ref $_[0] eq 'ARRAY' ) ? $_[0] : [@_];

    return $class_or_self;
}

1;
__END__

=head1 NAME

Lingua::Awkwords::Subpattern - implements named subpatterns

=head1 SYNOPSIS

This module is typically automagically used via L<Lingua::Awkwords>.

=head1 DESCRIPTION

Subpatterns are named (with the ASCII letters C<A-Z>) elements of
an awkwords pattern that expand out to some list of choices
equally weighted. That is,

  V

can be a shorthand notation for

  [a/e/i/o/u]

See the source code for what patterns are defined by default, or use
B<set_patterns> or B<update_pattern> first to change the values.

=head1 ATTRIBUTES

=over 4

=item I<pattern>

The pattern this object represents. Mandatory. Typically should be an
ASCII letter in the C<A-Z> range and typically should be set via the
B<new> method.

=back

=head1 METHODS

=over 4

=item I<is_pattern> I<pattern>

Returns a boolean indicating whether I<pattern> is an existing
pattern or not.

=item I<new>

Constructor. A I<pattern> should ideally be supplied. Will blow up if
the I<pattern> does not exist in the global patterns list.

  Lingua::Awkwords::Subpattern->new( pattern => 'V' )

=item I<render>

Returns a random item from the list of choices for the I<pattern>
that was hopefully set by some previous call. Blows up if I<pattern>
was not set.

=item I<set_patterns> I<list-of-patterns-and-choices>

Allows the choices for multiple patterns to be set in a single call.
These changes are global to a process. For example for the Toki Pona
language one might set C<C> for consonants and C<V> for vowels via

  Lingua::Awkwords::Subpattern->set_patterns(
      C => [qw/j k l m n p s t w/],
      V => [qw/a e i o u/],
  );

=item I<update_pattern> I<pattern> I<choices>

Updates the choices for the given I<pattern>. This happens globally in a
process; all instances will see the change in future B<render> calls.

Note that array references are treated differently than lists of values;

  my $nnmm = [qw/n m/];
  Lingua::Awkwords::Subpattern->update_pattern( N => $nnmm );

allows the array reference C<$nnmm> to be changed by the caller (thus
affecting future B<render> calls for that I<pattern>), while

  Lingua::Awkwords::Subpattern->update_pattern( N => @$nnmm );

does not allow the caller to then change anything as instead a copy of
the list of choices has been made.

=back

=head1 BUGS

=head2 Reporting Bugs

Please report any bugs or feature requests to
C<bug-lingua-awkwords at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-Awkwords>.

Patches might best be applied towards:

L<https://github.com/thrig/Lingua-Awkwords>

=head2 Known Issues

None at this time.

=head1 SEE ALSO

L<Lingua::Awkwords>, L<Lingua::Awkwords::Parser>

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
