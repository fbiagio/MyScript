use Modern::Perl;
use JSON;
use Data::Dumper;

my @array=("pippo","pluto","paperino");
my $hash_ref={"A","1","B","2"};
my %myhash=(
	a => 'biagio',
	b=> 'pluto',
	d=> \@array,
	c=> $hash_ref,
);

say Dumper(\%myhash);


my $utf8_encoded_json_text = encode_json \%myhash;
#$perl_hash_or_arrayref;

say "vediamo cosa posso fare...";
say $utf8_encoded_json_text;
