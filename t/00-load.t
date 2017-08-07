#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 3;

BEGIN {
    use_ok('Lingua::Awkwords')         || print "Bail out!\n";
    use_ok('Lingua::Awkwords::Set')    || print "Bail out!\n";
    use_ok('Lingua::Awkwords::String') || print "Bail out!\n";
}

diag("Testing Lingua::Awkwords $Lingua::Awkwords::VERSION, Perl $], $^X");
