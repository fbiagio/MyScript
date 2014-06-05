#!/usr/bin/perl
use strict; 
use threads;
use threads::shared;
use Thread::Queue;
use Text::ProgressBar::Bar;
use Getopt::Std; #http://search.cpan.org/~rjbs/perl-5.16.3/lib/Getopt/Std.pm#

#######################################
# VERIFICA ARGOMENTI PASSATI ED HELP
#######################################
# print STDOUT "[numero argomenti $#ARGV]\n"
our %Options;
getopts( 'l:s:d:dd:ddd',\%Options); # -q  boolean flags, -l,-s takes an argument
print "numero argomenti: $#ARGV\n";
if ($#ARGV != -1 ) {
	print "Syntax: thread.pl -l:lista -s:SCRIPT_FILE -t:[numTHREADS] \n";
	print "Options:\n";
	print " -l\t file con la lista dei nodi su cui eseguire lo scipt\n";
	print " -s\t scipt da eseguire\n";
	print " -d\t debug\n";
	print " -dd\t verbose debug\n";
	exit 120;
}
#
#######################################
#	MAIN
#######################################


#######################################
my @MYTHREAD;
my $MAX_RUNNING_THREADS=5;
#######################################
my $DEBUG=0;
my $DEBUG_THREAD=0;
if ($DEBUG==1){print STDOUT "DEBUG 1 ATTIVO\n";}
if ($DEBUG==2){print STDOUT "DEBUG 2 ATTIVO - CONTROLLO COSA FANNI I THREAD\n";}
if ($DEBUG==3){print STDOUT "DEBUG 3 ATTIVO\n";}

my $InFile=$Options{"l"};
if (! -e $InFile){
	print STDOUT "ERROR [$InFile] InFile do not exist\n";
	exit 121;
}
my $ScriptFile=$Options{"s"};
if (! -e $ScriptFile){
	print SDTOUT "ERROR [$ScriptFile] ScriptFile do not exist\n";
	exit 122;
}

#######################################
#inserire codice controllo opzioni
#######################################

print "INFILE: [$InFile]\nSCRIPT: [$ScriptFile]\n";
print "NUMERO DI THREAD: [$MAX_RUNNING_THREADS]\n";

my @Systems=&ReadList($InFile);

#######################################
#inizializzo la coda

my $MYQUEUE = Thread::Queue->new();
my $MYQUEUE_RESULT_OK = Thread::Queue->new();
my $MYQUEUE_RESULT_KO = Thread::Queue->new();

foreach (@Systems){
		$MYQUEUE -> enqueue($_);
}

my $TOTSERVER=$MYQUEUE -> pending();
if($DEBUG >=1 ){ print "\nDEBUG1: eseguo il comando su $TOTSERVER server\n";}


my $RUNNING_THREADS=0;

############ FACCIO PARTIRE TUTII I THREAD ###
if ($DEBUG >= 1){	print STDOUT "DEBUG1: Faccio partire tutti i $MAX_RUNNING_THREADS thread\n";}
for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
	if ($DEBUG >= 2){	print STDOUT "   DEBUG2: Faccio partire thread numero $RUNNING_THREADS\n";}
	$MYTHREAD[$RUNNING_THREADS]=threads->create({'context' => 'void'},\&myCMD, $RUNNING_THREADS, $DEBUG_THREAD);
}

############ ATTENGO CHE TUTTI I THREAD SIANO IN STATO JOINABLE ###
my $pbar = Text::ProgressBar->new();
$pbar->start();

my $JOINABLE=0;
while ($JOINABLE != $MAX_RUNNING_THREADS ){
	if ($DEBUG >= 1){	print STDOUT "DEBUG1: Attendo che tutti i thread siano joinabili\n";}
	$JOINABLE=0;
	for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
		if ($MYTHREAD["$RUNNING_THREADS"]->is_joinable()){
			if ($DEBUG >= 2){	print STDOUT "   DEBUG2: il thread [$RUNNING_THREADS] is_joinable\n";}
			$JOINABLE++;
		}
	}
	sleep 2;
	my $TOT_DA_FARE=$MYQUEUE->pending();
	my $TOT_FATTI=$TOTSERVER - $TOT_DA_FARE;
	#print "[$TOT_DA_FARE ][$TOT_FATTI ][$TOTSERVER ]\n"
	my $i=int(100*$TOT_FATTI/$TOTSERVER);
	$pbar->update($i);
}

$pbar->finish;
############ EFFETTUO IL JOIN DEI THREAD ###
if ($DEBUG >= 1){	print STDOUT "DEBUG1: Effettuo il join di tutti i thread\n";}
for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
	if ($DEBUG >= 2){	print STDOUT "   DEBUG2: Effettuo il join del thread [$RUNNING_THREADS]\n";}
	$MYTHREAD["$RUNNING_THREADS"]->join();
}

#######################################
&PrintThreadResult($MYQUEUE_RESULT_OK, "RISULTATI POSITIVI\n");
&PrintThreadResult($MYQUEUE_RESULT_KO, "RISULTATI NEGATIVI\n");
#######################################
print "\nPowered by Takke\n";



#######################################
# FUNZIONI 
#######################################
sub ReadList{
	my $filename= shift;
	my @ARRAY;
	print STDOUT "\#...LEGGO FILE CON LA LISTA DELLE MACCHINE...\n";
	open INFILE , "<", "$filename" or die "ERROR impossibile aprire file con lista server [$filename]\n";
	while (<INFILE>){
		s/\n//g;
		s/\r//g;
		s/ //g;
		if($_ =~ /s+/){push(@ARRAY,$_);}
	}
	close INFILE;
	return @ARRAY;
} #FINE FUNZIONE LEGGI FILE

sub PrintThreadResult {
	my $TEMPQUEUE=shift;
	my $text=shift;
	print STDOUT "#########################################\n";
	print STDOUT "$text";
	while ($TEMPQUEUE -> pending){
		print "[" . $TEMPQUEUE -> dequeue . "]\n";
	}
} #FINE FUNZIONE STAMPA RISULTATI THREAD

#######################################
# My THREADS CMD
#######################################
sub myCMD{
	my $THREAD_NUMBER=shift;
	my $DEBUG_THREAD=shift;
	my $SERVERNAME;
	my $HAVETODO=1;
	
	if ($DEBUG_THREAD >= 1){ print "\tTHREAD DEBUG[$THREAD_NUMBER] - thread numero [$THREAD_NUMBER] partito \n";}
	
	while ( $HAVETODO == 1 )  {
		{#LOCK QUEUE
		lock($MYQUEUE);
		if ($MYQUEUE->pending() != 0){
			if ($DEBUG_THREAD >= 1){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] - la coda non è vuota, estraggo $SERVERNAME\n";}	
			$SERVERNAME=$MYQUEUE->dequeue();
		}else{	
			if ($DEBUG_THREAD >= 1 ){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] - la coda è vuota, non ho più nulla da fare\n";}	
			$HAVETODO=0;
		}
		}#LOCK QUEUE
		
		if ($HAVETODO==1){
			sleep 1;
			if ($DEBUG_THREAD >= 1){sleep 5;}
			my $result= int(rand(2));
			if ($result == 1){
				lock($MYQUEUE_RESULT_OK);
				$MYQUEUE_RESULT_OK -> enqueue(${SERVERNAME} . "_" . ${result});
			}else{
				lock($MYQUEUE_RESULT_KO);
				$MYQUEUE_RESULT_KO -> enqueue(${SERVERNAME} . "_" . ${result});
			}	
			if ($DEBUG_THREAD >= 1){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] -Stò lavorare col [$SERVERNAME]\n";}
		}
	}
	return;
	
}
