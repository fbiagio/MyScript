use Modern::Perl;
use Crypt::CBC;
use Getopt::Std;
use Data::Dumper;

my %opts;
getopts('df:k:',  \%opts);


#print Dumper(\%opts);

if((!defined $opts{'k'})||(!defined $opts{'f'})){
	&syntaxhelp;
}

my $cipher = Crypt::CBC->new( -key    => $opts{"k"},
                             -cipher => 'Blowfish'
                            );
die "the file $opts{'f'} is not existence" unless (-f $opts{'f'});
open(my $fh,"<",$opts{'f'})|| die "error opening file;";

if ($opts{'d'}){
	$cipher->start('decrypting');
	while (read($fh,my $buffer,1024)) {
		print $cipher->decrypt($buffer);
	}
	print $cipher->finish;

}else{
	$cipher->start('encrypting');
	while (read($fh,my $buffer,1024)) {
		print $cipher->crypt($buffer);
	}
	print $cipher->finish;
}

sub syntaxhelp {
 	say "syntax:  perl crypt.pl [-d] -k <key> -f <filename>";
	say " -d decrypt";
	say " -k key to crypt/decrypt file";
	say " -f file to crypt/decrypt file";
	say "syntax error";
	exit 100;

}
