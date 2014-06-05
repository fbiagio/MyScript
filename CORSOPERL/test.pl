open($fp, "<", "/etc/passwd");
while (<$fp>){
	my @row=$_;
	foreach (@row){
		print $_;
	}
}
