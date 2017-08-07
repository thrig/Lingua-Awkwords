# -*- Perl -*-
#
# Run perldoc(1) on this file for additional documentation.

# TODO ->render in this module then operates on a list of thingies
# and calls render on all of them in turn, thus building the
# resultant string?

# TODO also need means to set A..Z sets that can expand out to e.g. V =>
# [a/e/i/o/u] or whatnot

package Lingua::Awkwords;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

use base qw( Parser::MGC );

sub parse {
    my $self = shift;

}

sub render {
    my $self = shift;

}

sub token_literal {
    my $self = shift;
    $self->expect(q{"});
    my $ret = $self->generic_token( 'literal', qr/[^"]+/,
        sub { Lingua::Awkwords::String->new( string => $_[0] ) } );
    $self->expect(q{"});
    return $ret;
}

# weighting for some previous term, integer in inclusive range 1..128
sub token_weight {
    my $self = shift;
    $self->expect(q{*});
    # P.S. don't do number ranges in regex; this is for 1..128
    $self->generic_token( 'weight', qr/12[0-8]|1[01][0-9]|[1-9][0-9]|[1-9]/ );
}

1;
__END__

=head1 NAME

Lingua::Awkwords - randomly generates words from a given pattern

=head1 SYNOPSIS

  TODO

=head1 DESCRIPTION

TODO

=head1 METHODS

=over 4

=item I<parse>

TODO

=item I<token_literal>

TODO

=item I<token_weight>

TODO

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

L<Lingua::Awkwords::Set>, L<Lingua::Awkwords::String>

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
