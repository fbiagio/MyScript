use Modern::Perl;
use strict;


use threads::shared;
use Thread::Queue;

my $timeout=60;
my $MYQUEUE = Thread::Queue->new();


#open(my $infile,"<", "./auth.log.0") ||  die "error openinig file";
open(my $infile,"-|", "tail -n 45000 -f ./auth.log.0") ||  die "error openinig file";

#faccio partire il thread che legge il file e inserisce nella cosa IP da sbloccare dopo 60 secondi
threads->create({'context' => 'void'},\&myTHREAD);

while(1) {
	my $removeIP=$MYQUEUE->dequeue();
	&sbloccaIP($removeIP);
	sleep 60;
}



sub myTHREAD{
	while ((<$infile>)){
		#Nov 22 06:39:12 u1 sshd[59958]: twist 199.255.13.60 to /bin/echo "You are not welcome to use sshd from 199.255.13.60."
		#if (/You are not welcome to use sshd from (\S*)\.\"/){
		if (/You are not welcome to use sshd from (\d+\.\d+\.\d+\.\d+)\.\"/){
			lock($MYQUEUE);
			say "\tLEGGO $1";
			$MYQUEUE->enqueue($1);
			&bloccaIP($1);
		}
	}
	close($infile);
}


sub bloccaIP{
	my $IP=shift;
	### ipfw add deny from 196.168.2.1 to any
	my $lock_cmd="ipfw add deny from " . $IP . "to any";
	print STDOUT "\t>>> Eseguo aggiunta $IP in BlackLIST\n";
}

sub sbloccaIP{
	my $IP=shift;
	### ipfw add deny from 196.168.2.1 to any
	my $unlock_cmd="ipfw add allow from " . $IP . "to any";
	print STDOUT ">>> Eseguo rimozione  $IP in BlackLIST\n";
}
