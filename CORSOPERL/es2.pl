use FindBin;
use lib "$FindBin::Bin/lib";

use Modern::Perl;
use biagio;

open (my $fp,"<", "./text.txt"); # || die "error $infile $!;


## oppure @file = <$fp>;
while (<$fp>){
	my @RIGA=split(" ", $_);
	#my @REVERSE_RIGA=reverse(@RIGA);	
	my @REVERSE_RIGA=biagio::myreverse(@RIGA);
	foreach (@REVERSE_RIGA){
		print "$_ ";
	}
	print "\n";
	
}

