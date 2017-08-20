# -*- Perl -*-
#
# randomly generates outputs from a given pattern

package Lingua::Awkwords;

use strict;
use warnings;

use Lingua::Awkwords::Parser;
use Moo;
use namespace::clean;

our $VERSION = '0.01';

has pattern => (
    is      => 'rw',
    trigger => sub {
        my ( $self, $pat ) = @_;
        $self->_set_tree( Lingua::Awkwords::Parser->new->from_string($pat) );
    },
);
has tree => ( is => 'rwp' );

########################################################################
#
# though this be madness, yet there is a METHOD in't

sub render {
    my $self = shift;
    my $tree = $self->tree;
    die "no pattern supplied" if !defined $tree;
    return $tree->render;
}

1;
__END__

=head1 NAME

Lingua::Awkwords - randomly generates outputs from a given pattern

=head1 SYNOPSIS

  use feature qw(say);
  use Lingua::Awkwords;
  use Lingua::Awkwords::Subpattern;

  # V is a pre-defined subpattern, ^ filters out aa from the list
  # of two vowels that the two VV generate
  my $la = Lingua::Awkwords->new( pattern => q{ [VV]^aa } );

  say $la->render for 1..10;

  # define our own C, V
  Lingua::Awkwords::Subpattern->set_patterns(
      C => [qw/j k l m n p s t w/],
      V => [qw/a e i o u/],
  );
  # and a pattern somewhat suitable for Toki Pona...
  $la->pattern(q{
      [a/*2]
      (CV*5)^ji^ti^wo^wu
      (CV*2)^ji^ti^wo^wu
      [CV/*2]^ji^ti^wo^wu
      [n/*5]
  }

  say $la->render for 1..10;

=head1 DESCRIPTION

This is a Perl implementation of

http://akana.conlang.org/tools/awkwords/

though is not an exact replica of that parser;

http://akana.conlang.org/tools/awkwords/help.html

details the format that this code is based on. Briefly,

=head2 SYNTAX

=over 4

=item I<[]> or I<()>

Denote a unit or group; they are identical except that C<(a)> is
equivalent to C<[a/]>--that is, it represents the possibility of
generating the empty string in addition to any other terms supplied.

Units can be nested recursively. There is an implicit unit at the top
level of the I<pattern>.

=item I</>

Introduces a choice within a unit; without this C<[Vx]> would generate
whatever C<V> represents (a list of vowels by default) followed by the
letter C<x> while C<[V/x]> by contrast generates only a vowel I<or> the
letter C<x>.

=item I<*>

The asterisk followed by an integer in the range C<1..128> inclusive
weights the current term of the alternation, if any. That is, while
C<[a/]> generates each term with equal probability, C<[a/*2]> would
generate the empty string at twice the probability of the letter C<a>.

=item I<^>

The caret introduces a filter that must follow a unit (there is an
implicit unit at the top level of a I<pattern>). An example would be
C<[VV]^aa> or the equivalent C<VV^aa> that (by default) generates two
vowels, but replaces C<aa> with the empty string. More than one filter
may be specified.

=item I<A-Z>

Capital ASCII letters denote subpatterns; several of these are set by
default. See L<Lingua::Awkwords::Subpattern> for how to customize them.
C<V> for example is by default equivalent to the more verbose C<[a/i/u]>.

=item I<">

Use double quotes to denote a quoted string; this prevents other
characters (besides C<"> itself) from being interpreted as some non-
string value.

=item I<anything-else>

Anything else not otherwise accounted for above is treated as part of a
string, so C<["abc"/abc]> generates either the string C<abc> or the
string C<abc>, as this is two ways of saying the same thing.

=back

=head1 ATTRIBUTES

=over 4

=item I<pattern>

Awkword pattern. Without this supplied any call to B<render> will throw
an exception.

=item I<tree>

Where the parse tree is stored.

=back

=head1 METHODS

=over 4

=item I<new>

Constructor. Typically this should be passed a I<pattern> argument.

=item I<render>

Returns a string render of the awkword I<pattern>. This may be the empty
string if filters have removed all the text.

=back

=head1 BUGS

=head2 Reporting Bugs

Please report any bugs or feature requests to
C<bug-lingua-awkwords at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-Awkwords>.

Patches might best be applied towards:

L<https://github.com/thrig/Lingua-Awkwords>

=head2 Known Issues

There are various incompatibilities with the original version of the
code; these are detailed in the parser module as they concern how e.g.
weights are parsed.

=head1 SEE ALSO

L<Lingua::Awkwords::Parser>

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
