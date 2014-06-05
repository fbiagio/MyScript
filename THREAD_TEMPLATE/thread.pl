#!/usr/bin/perl
use strict; 
use threads;
use threads::shared;


#######################################
# VERIFICA ARGOMENTI PASSATI ED HELP
#######################################
# print STDOUT "[numero argomenti $#ARGV]\n";
# if ($#ARGV < 1 ) {
# print "Syntax: thread.pl -l:lista -s:SCRIPT_FILE -t:[numTHREADS] \n";
# print "Options:\n";
# print " -l\t file con la lista dei nodi su cui eseguire lo scipt\n";
# print " -s\t scipt da eseguire\n";
# exit;
# }

#######################################
#	MAIN
#######################################

my %Options;
my %MYTHREAD;
my $DEBUG=3;

if ($DEBUG==1){print STDOUT "DEBUG 1 ATTIVO\n";}
if ($DEBUG==2){print STDOUT "DEBUG 2 ATTIVO\n";}
if ($DEBUG==3){print STDOUT "DEBUG 3 ATTIVO\n";}

foreach (@ARGV) {
        my ($opt,$todo)=split(':',$_);
                $Options{$opt}=$todo;
                }

my $InFile=$Options{"-l"};
my $ScriptFile=$Options{"-s"};

#######################################
#inserire codice controllo opzioni
#######################################

print "INFILE: [$InFile]\nSCRIPT: [$ScriptFile]\n";
if($DEBUG>0){$InFile="/home/takke/MyScript/THREAD_TEMPLATE/lista.txt";}
my @Systems=&ReadList($InFile);


#######################################
my $MAX_RUNNING_THREADS=3;
#######################################
my $RUNNING_THREADS=0;
my @StartingThreads;
my @isStoppableThreads;
my @FinishThreads;
my %ThreadResult;

@StartingThreads=@Systems;
while (scalar(@StartingThreads) != 0) { 
	if ($RUNNING_THREADS <= $MAX_RUNNING_THREADS-1){
		my $sys=shift(@StartingThreads);
		push(@isStoppableThreads,$sys);
		if ($DEBUG==3){
			print STDOUT "\nDEBUG 3: Creo nuovo thread [$sys]\n";
			print STDOUT "DEBUG 3: Starting\t:[@StartingThreads]\n";
			print STDOUT "DEBUG 3: isStoppable\t:[@isStoppableThreads]\n";
			print STDOUT "DEBUG 3: Finish\t\t:[@FinishThreads]\n";
		}
		$MYTHREAD{"$sys"}=threads->create({'context' => 'list'},\&myCMD,$sys);
		$RUNNING_THREADS++;
	}else{
		if ($DEBUG==3){ print STDOUT "DEBUG 3 non ho più thread liberi\n";}
		while (scalar(@isStoppableThreads) != 0) {
			my $find;
			my $sys=shift(@isStoppableThreads);
			if ($DEBUG==3){ print STDOUT "DEBUG 3 controllo thread [$sys]\n"; }
			if ($MYTHREAD{"$sys"}->is_joinable()){
				$RUNNING_THREADS--;
				$ThreadResult{"$sys"}=@MYTHREAD{"$sys"} ->join();
				$find=1;
				push(@FinishThreads,$sys);
			}else{
				push(@isStoppableThreads,$sys);
			}
			last if ($find);
		}
	}
}



if ($DEBUG==3){print STDOUT "\n\nDEBUG3 Chiudo ultimi threads:\n @isStoppableThreads\n";}
while (scalar(@isStoppableThreads) != 0) { 
	#print STDOUT "attendo gli ultimi thread\n @isStoppableThreads \n";
	my $MAX=scalar(@isStoppableThreads);
	for (my $i=0; $i < $MAX; $i++){
		#print STDOUT "controllo [$i][$StoppingThreads[$i]]\n";
		if (($MYTHREAD{"$isStoppableThreads[$i]"} =~ /\S+/)&&($MYTHREAD{"$isStoppableThreads[$i]"}->is_joinable())){
                                $RUNNING_THREADS--;
                                $ThreadResult{"$isStoppableThreads[$i]"}= @MYTHREAD{"$isStoppableThreads[$i]"} ->join();
                                delete @isStoppableThreads[$i];
		}
	}

}
#######################################
print STDOUT "Spampo risultati threads\n";
foreach (@Systems){
	#$MYTHREAD{$_}->getarray();
	my @var=$ThreadResult{"$_"};
	print STDOUT "$_ \t @var\n";
}
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

#######################################
# My THREADS CMD
#######################################
sub myCMD{
	my $SERVERNAME=shift;
	#sleep 1; 
	my $results="evviva " . $SERVERNAME;
	return ($results);
}
