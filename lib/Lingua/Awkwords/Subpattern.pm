# -*- Perl -*-
#
# subpatterns are named A-Z and offer short-hand notation for e.g. V =>
# a/e/i/o/u (or whatever) for vowels. these patterns can be changed
# without a reparse of the pattern

package Lingua::Awkwords::Subpattern;

use strict;
use warnings;
use Carp qw(confess croak);
use Moo;
use namespace::clean;

our $VERSION = '0.02';

# these defaults set from what the online version does at
# http://akana.conlang.org/tools/awkwords/
#
# NOTE that set_patterns clobbers these
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
    my ( undef, $what ) = @_;
    return exists $patterns{$what};
}

sub render {
    my ($self) = @_;

    my $sp = $self->pattern // die "subpattern not set";
    confess "subpattern $sp does not exist" unless exists $patterns{$sp};

    my $type = ref $patterns{$sp};
    my $ret;

    # this complication allows for subpatterns to point at other parse
    # trees instead of just simple terminal strings (yes, you could
    # create loops where a ->render points to itself (don't do that))
    #
    # NOTE walk sub must be kept in sync with this logic
    if ( !$type ) {
        $ret = $patterns{$sp};
    } else {
        if ( $type eq 'ARRAY' ) {
            # do not need Math::Random::Discrete here as the weights are
            # always equal; for weighted instead write that unit out
            # manually via [a*2/e/i/o/u] or such
            $ret = @{ $patterns{$sp} }[ rand @{ $patterns{$sp} } ] // '';
        } elsif ( $patterns{$sp}->can('render') ) {
            $ret = $patterns{$sp}->render;
        } else {
            # this will most likely be from a set_patterns call done
            # somewhere else in the code; the backtrace should help find
            # the first ->render call and then one can look before that
            # for set_patterns (or possibly update_pattern) calls
            confess "subpattern $sp points to unknown type";
        }
        $ret = $ret->recurse if ref $ret;
    }

    return $ret;
}

sub set_patterns {
    my $class_or_self = shift;
    # TODO error checking here may be beneficial if callers are in the
    # habit of passing in data that blows up on ->render or ->walk
    %patterns = @_;
    return $class_or_self;
}

sub update_pattern {
    my $class_or_self = shift;
    my $pattern       = shift;

    # TODO more error checking here may be beneficial if callers are in
    # the habit of passing in data that blows up on ->render
    croak "update needs a pattern and a list of values\n" unless @_;
    croak "value must be defined" if !defined $_[0];

    # NOTE that list-versus-a-single-arrayref are different in that a
    # copy is made of the list, while the arrayref is passed as-is; this
    # allows the caller to fiddle around with the arrayref without in
    # turn needing to make new update_pattern calls for each change.
    # this may or may not be a good idea
    $patterns{$pattern} = @_ == 1 ? $_[0] : [@_];

    return $class_or_self;
}

sub walk {
    my ( $self, $callback ) = @_;

    my $sp = $self->pattern // die "subpattern not set";
    confess "subpattern $sp does not exist" unless exists $patterns{$sp};

    $callback->($self);

    # NOTE this logic should be kept in sync with render sub
    my $type = ref $patterns{$sp};
    if ( ref $type ) {
        if ( $type eq 'ARRAY' ) {
            for my $term (@{ $patterns{$sp} }) {
                $term->walk if ref $term;
            }
        } elsif ( $patterns{$sp}->can('walk') ) {
            $patterns{$sp}->walk;
        } else {
            confess "unknown type in pattern $sp";
        }
    }
    return;
}

1;
__END__

=head1 NAME

Lingua::Awkwords::Subpattern - implements named subpatterns

=head1 SYNOPSIS

  use feature qw(say);
  use Lingua::Awkwords;
  use Lingua::Awkwords::Subpattern;

  Lingua::Awkwords::Subpattern->set_patterns(
      C => [qw/p t k s m n/],
      N => [qw/m n/],
      V => [qw/a i u/],
  );

  my $triphthong = Lingua::Awkwords->new( pattern => q{ VVV } );
  say $triphthong->render;

=head1 DESCRIPTION

Subpatterns are named (with the ASCII letters C<A-Z>) elements of an
awkwords pattern that expand out to some list of choices equally
weighted. That is, C<V> in a I<pattern> can be a shorthand notation for

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

=item B<is_pattern> I<pattern>

Returns a boolean indicating whether I<pattern> is an existing
pattern or not.

=item B<new>

Constructor. A I<pattern> should ideally be supplied. Will blow up if
the I<pattern> does not exist in the global patterns list.

  Lingua::Awkwords::Subpattern->new( pattern => 'V' )

=item B<render>

Returns a random item from the list of choices for the I<pattern>
that was hopefully set by some previous call. Blows up if I<pattern>
was not set.

=item B<set_patterns> I<list-of-patterns-and-choices>

Resets I<all> the choices for multiple patterns. These changes are
global to a process. For example for the Toki Pona language one might
set C<C> for consonants and C<V> for vowels via

  Lingua::Awkwords::Subpattern->set_patterns(
      C => [qw/j k l m n p s t w/],
      V => [qw/a e i o u/],
  );

Choices can either be simple string values or objects capable of having
B<render> called on them. L<Lingua::Awkwords/COMPLICATIONS> has an
example of the later form.

=item B<update_pattern> I<pattern> I<choices>

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

=item B<walk> I<callback>

Calls the I<callback> function with itself as the argument, then
tries to find anything the I<pattern> points to that can have B<walk>
called on it and calls that.

=back

=head1 BUGS

=head2 Reporting Bugs

Please report any bugs or feature requests to
C<bug-lingua-awkwords at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-Awkwords>.

Patches might best be applied towards:

L<https://github.com/thrig/Lingua-Awkwords>

=head2 Known Issues

There can only be 26 named subpatterns and these are global to the
process. It may be beneficial to (optionally?) make them instance
specific somehow.

=head1 SEE ALSO

L<Lingua::Awkwords>, L<Lingua::Awkwords::Parser>

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
