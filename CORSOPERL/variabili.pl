use Modern::Perl;
use constant {
	DGB => 1,
	DDD => 3
	
};

#variabili e tipi
use constant {
    DEBUG=>0,
    };

my $string="ciao";
my @array=("a" .. "f"); #PARENTESI TONDE
my %hash1=('red',0x00f,'blue',0x0f0,'green',0xf00); #PARENTESI TONDE
my %hash2=(
                 red   => 0x00f,
                 blue  => 0x0f0,
                 green => 0xf00,
                 test => ["R","G","B"],
   ); 

if(DEBUG){}
#l'idirizzo di memoria per le seguenti strutture si ricava
my $ref_string=\$string;
my $ref_array=\@array;
my $ref_hash=\%hash2;


#oppure
#
my $ref_hashnew = {foo=>'bar', baz=>'quux'};
my $ref_arraynew = [ 0 .. 5 ];

say $ref_arraynew;
say $ref_hashnew;

say "$ref_string; $ref_array; $ref_hash";

# per passare nuovamente da riferimento a dati
my $new_string=${$ref_string};
my @new_array=@{$ref_array};
my %new_hash=%{$ref_hash};

#say $new_string;
#say $string;
say "------------";
#say \@new_array;
say $new_hash{"test"}->[1]; #STAMPA: "G"
#oppure usando il ref 
say $$ref_hash{"test"}->[1];
#say %hash1=>[red];


sub MyGetConf {
	my $ref_hash=shift;
	my $conf_file="./GetConf.cfg";
	open(my $mycfg, "<", $conf_file) or die "ERROR: unable to open conf file $!\n";
	
	while (<$mycfg>){
		#SN_SUPERDOME;SRD_NAME;server1,server2,server3,...,serverN;PROFILI1,...,PROFILIN
		say $_;
		if(/^(\w+);(\w+);(\S+);(\S+)/){
			say "[$1][$2][$3][$4]";
			my %single_opt=(
					sn => "$1",
					srdname => "$2",
					srv_list => "$3",
					prof_list => "$4",
				);
			$ref_hash->{"$1"} = \%single_opt;
			
			#push(@opts,\%single_opt);	
		}
	}
	close($mycfg);
	return($ref_hash);
}


