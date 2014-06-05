use Test::More;

BEGIN{
	use_ok("Fantacalcio::Squadre");
}

my $var=Fantacalcio::Squadre->new(Presidente => "nomepresidente");
isa_ok($var, 'Fantacalcio::Squadre');
