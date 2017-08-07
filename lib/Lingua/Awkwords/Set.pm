# -*- Perl -*-
#
# set of choices of which one (with possible weights) will be picked via
# ->render

package Lingua::Awkwords::Set;

use strict;
use warnings;
use Math::Random::Discrete;
use Moo;
use namespace::clean;

our $VERSION = '0.01';

has items => (
    is      => 'rwp',
    default => sub { [] },
    trigger => sub {
        $_[0]->clear_picker;
    },
);
has picker => ( is => 'lazy', clearer => 1 );

sub add { push @{ $_[0]->_set_items }, @_ }

sub render {
    my $self = shift;

    my $items = $self->_set_items;
    # what is [] supposed to do? it's a mandatory nothing so I guess
    # generate an empty string (one might instead throw an error if such
    # do-nothings are illegal for some reason...)
    if ( !defined $items or @$items == 0 ) {
        return '';
    }

    my $picker = $self->picker;
    if ( !defined $picker ) {
        # TODO need weights from... somewhere. embedded in each item, or
        # stored in the list of items perhaps as [weight,ref] pairs?
        # weights and then values
        $picker = Math::Random::Discrete->new( [ (1) x @$items ], $items );
        $self->_set_picker($picker);
    }

    $picker->rand->render;
}

1;
__END__

=head1 NAME

Lingua::Awkwords::Set - choices for awkwords

=head1 SYNOPSIS

This module is typically automagically used via L<Lingua::Awkwords>.

=head1 DESCRIPTION

This module implements choices for a particular awkwords string; in
brief, these are either C<[a/b/c]> or C<(a/b/c)> blocks where the second
also offers an implicit empty string result, while the first only
generates either an C<a>, C<b>, or a C<c>.

=head1 ATTRIBUTES

=over 4

=item I<items>

This is where the choices are stored.

=back

=head1 METHODS

=over 4

=item I<add>

Adds the given items to the list of choices stored in B<items>.

=item I<new>

Constructor.

=item I<render>

Picks a random choice and in turn calls B<render> on that, or, if there
are no choices returns the empty string.

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

L<Lingua::Awkwords>, L<Lingua::Awkwords::String>

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
