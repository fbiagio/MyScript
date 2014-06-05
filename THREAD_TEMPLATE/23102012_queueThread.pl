#!/usr/bin/perl
use strict; 
use threads;
use threads::shared;
use Thread::Queue;


#######################################
# VERIFICA ARGOMENTI PASSATI ED HELP
#######################################
# print STDOUT "[numero argomenti $#ARGV]\n";
if ($#ARGV < 1 ) {
	print "Syntax: thread.pl -l:lista -s:SCRIPT_FILE -t:[numTHREADS] \n";
	print "Options:\n";
	print " -l\t file con la lista dei nodi su cui eseguire lo scipt\n";
	print " -s\t scipt da eseguire\n";
	exit 120;
}
#
#######################################
#	MAIN
#######################################

my %Options;
my @MYTHREAD;
my $DEMONE=1;
my $DEBUG=3;
my $DEBUG_THREAD=0;

#######################################
my $MAX_RUNNING_THREADS=4;
#######################################

if ($DEBUG==1){print STDOUT "DEBUG 1 ATTIVO\n";}
if ($DEBUG==2){print STDOUT "DEBUG 2 ATTIVO - CONTROLLO COSA FANNI I THREAD\n";}
if ($DEBUG==3){print STDOUT "DEBUG 3 ATTIVO\n";}

foreach (@ARGV) {
        my ($opt,$todo)=split(':',$_);
                $Options{$opt}=$todo;
                }

my $InFile=$Options{"-l"};
if (! -e $InFile){
	print STDOUT "ERROR [$InFile] InFile do not exist\n";
	exit 121;
}
my $ScriptFile=$Options{"-s"};
if (! -e $ScriptFile){
	print SDTOUT "ERROR [$ScriptFile] ScriptFile do not exist\n";
	exit 122;
}

#######################################
#inserire codice controllo opzioni
#######################################

print "INFILE: [$InFile]\nSCRIPT: [$ScriptFile]\n";
if($DEBUG>0){$InFile="/home/takke/MyScript/THREAD_TEMPLATE/lista.txt";}
my @Systems=&ReadList($InFile);

#######################################
#inizializzo la coda

my $MYQUEUE = Thread::Queue->new();
my $MYFINISH_THREAD = Thread::Queue->new();
my $MYQUEUE_RESULT_OK = Thread::Queue->new();
my $MYQUEUE_RESULT_KO = Thread::Queue->new();

foreach (@Systems){
		$MYQUEUE -> enqueue($_);
}

if($DEBUG>0){ my $num=$MYQUEUE -> pending(); print "\nDEBUG: eseguo il comando su $num server\n";}


my $RUNNING_THREADS=0;

### FACCIO PARTIRE I THREAD ###
while ($RUNNING_THREADS < $MAX_RUNNING_THREADS) {
	if ($DEBUG >= 1){	print STDOUT "DEBUG: Faccio partire thread numero $RUNNING_THREADS\n";}
	$MYTHREAD[$RUNNING_THREADS]=threads->create({'context' => 'void'},\&myCMD, $RUNNING_THREADS, $DEBUG_THREAD);
	$RUNNING_THREADS++;
	if ($DEBUG >= 1){	print STDOUT "DEBUG: partire thread numero $RUNNING_THREADS su $MAX_RUNNING_THREADS \n";}
}



############ ATTENGO CHE TUTTI I THREAD ABBIANO CONCLUSO IL LORO LAVORO ### VERIFICO NUMERO ELEMENTI CODA
while ($MYFINISH_THREAD->pending != $MAX_RUNNING_THREADS){
		if ($DEBUG >= 3){ print STDOUT "DEBUG: Attendo che MYFINISH_THREAD [" . $MYFINISH_THREAD-> pending . "] sia uguale a [$MAX_RUNNING_THREADS]\n";}
		sleep 1;
}

while ($MYFINISH_THREAD->pending){
	my $THREADJOINNUM=$MYFINISH_THREAD-> dequeue;
	if ($DEBUG >= 3){ print STDOUT "toldo dalla coda il thread numero [$THREADJOINNUM]\n";}
	if ($MYTHREAD["$THREADJOINNUM"]->is_joinable()){
		if ($DEBUG >= 3){ print STDOUT "il thread [$THREADJOINNUM] is joinable\n";}
		$MYTHREAD["$THREADJOINNUM"]->join();
	}	
	
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
	while (<INFILE>) {
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
	
	if ($DEBUG_THREAD > 0){ print "\tTHREAD DEBUG[$THREAD_NUMBER] - Il thread numero [$THREAD_NUMBER] partito \n";}
	
	while ( $HAVETODO == 1 )  {
		{#LOCK QUEUE
		lock($MYQUEUE);
		if ($MYQUEUE->pending() != 0){
			if ($DEBUG_THREAD > 0){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] - la coda non è vuota, estraggo $SERVERNAME\n";}	
			$SERVERNAME=$MYQUEUE->dequeue();
		}else{	
			if ($DEBUG_THREAD > 0 ){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] - la coda è vuota, non ho più nulla da fare\n";}	
			$HAVETODO=0;
		}
		}#LOCK QUEUE
		
		if ($HAVETODO==1){
			if ($DEBUG_THREAD >= 0){sleep 3;}
			my $result= int(rand(2));
			if ($result == 1){
				lock($MYQUEUE_RESULT_OK);
				$MYQUEUE_RESULT_OK -> enqueue(${SERVERNAME} . "_" . ${result});
			}else{
				lock($MYQUEUE_RESULT_KO);
				$MYQUEUE_RESULT_KO -> enqueue(${SERVERNAME} . "_" . ${result});
			}	
			print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] -Stò lavorare col [$SERVERNAME]\n";			
		}
	}
	{
		lock($MYFINISH_THREAD);
		$MYFINISH_THREAD -> enqueue($THREAD_NUMBER);
	}
	return;
	
}

