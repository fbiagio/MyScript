#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Fantacalcio::RisultatiPartite' ) || print "Bail out!\n";
}

diag( "Testing Fantacalcio::RisultatiPartite $Fantacalcio::RisultatiPartite::VERSION, Perl $], $^X" );
