use Modern::Perl;


open (my $fp,"<", "/home/takke/CORSOPERL/text.txt"); # || die "error $infile $!;

while (<$fp>){
	my @RIGA=split(" ", $_);
	my @REVERSE_RIGA=reverse(@RIGA);	
	foreach (@REVERSE_RIGA){
		print "$_ ";
	}
	print "\n";
	
}
