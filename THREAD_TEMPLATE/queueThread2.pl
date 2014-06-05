#!/usr/bin/perl
use Modern::Perl;
use Data::Dumper;
use threads;
use Thread::Queue;

#######################################
#	MAIN new queueThread2.pl 5giu2014
#######################################

use constant {
	INFO				=> 0,
	DEBUG				=> 0,
	DEBUG_THREAD		=> 0,
	DUMPER				=> 0,
	MAX_RUNNING_THREADS	=> 5
	
};

my @MYTHREAD;

#######################################
# inizializzo le code

my $MYQUEUE = Thread::Queue->new();
my $MYQUEUE_RESULT = Thread::Queue->new();

######################################
say "NUMERO DI THREAD: [" . MAX_RUNNING_THREADS . "]" if(DEBUG);
#
my @items=("A","B","C","D","E");
foreach (@items){
		$MYQUEUE -> enqueue($_);
}

my $RUNNING_THREADS=0;

############ FACCIO PARTIRE TUTII I THREAD ###
say STDOUT "\t+ DEBUG Faccio partire tutti i " . MAX_RUNNING_THREADS . " thread" if(DEBUG);
for my $RUNNING_THREADS (0 .. MAX_RUNNING_THREADS){
	say STDOUT "\t++ DEBUG Faccio partire thread numero $RUNNING_THREADS" if(DEBUG);
	$MYTHREAD[$RUNNING_THREADS]=threads->create({'context' => 'void'},\&myCMD, $RUNNING_THREADS);
}
############ ATTENGO CHE TUTTI I THREAD SIANO IN STATO JOINABLE ###
say STDOUT "\t+ DEBUG Attendo che siano tutti joinabili" if(DEBUG);

for(;;){
	
	my $JOINABLE=0;
	for my $RUNNING_THREADS (0 .. MAX_RUNNING_THREADS){
		if ($MYTHREAD["$RUNNING_THREADS"]->is_joinable()){
			say STDOUT "\t++ DEBUG: il thread [$RUNNING_THREADS] is_joinable" if(DEBUG);
			$JOINABLE++;
		}
	}
	last if($JOINABLE-1 == MAX_RUNNING_THREADS);
	sleep 4;
	
} #loop!
############ EFFETTUO IL JOIN DEI THREAD ###
say STDOUT "\t+ DEBUG Effettuo il join di tutti i thread" if(DEBUG);
for my $RUNNING_THREADS (0 .. MAX_RUNNING_THREADS){
	say STDOUT "\t++ DEBUG join thread numero $RUNNING_THREADS" if(DEBUG);
	$MYTHREAD["$RUNNING_THREADS"]->join();
}
#######################################





#######################################
print "\nPowered by Takke\n";





#######################################
# MY THREADS WORKER
#######################################
sub myCMD{
	my $THREAD_NUMBER=shift;
	my $HAVETODO=1;
	my $item;
	
	say STDOUT "\t\t+\tTHREAD DEBUG[$THREAD_NUMBER] - thread numero [$THREAD_NUMBER] partito" if(DEBUG_THREAD);
	
	while ( $HAVETODO == 1 )  {
		
		
		{#LOCK QUEUE
			lock($MYQUEUE);
			if ($MYQUEUE->pending() != 0){	
				$item=$MYQUEUE->dequeue();
				say STDOUT "\t\t+\tTHREAD DEBUG[$THREAD_NUMBER] - la coda non è vuota, lavoro su $item" if(DEBUG_THREAD);
			}else{	
				say STDOUT "\t\t+\tTHREAD DEBUG[$THREAD_NUMBER] - la coda è vuota" if(DEBUG_THREAD);	
				$HAVETODO=0;
			}
		}#LOCK QUEUE
		
		
		if ($HAVETODO==1){
			say STDOUT "\t\t+\tTHREAD DEBUG[$THREAD_NUMBER] - working on $item" if(DEBUG_THREAD);
			sleep 5 if(DEBUG_THREAD);
			my $result= int(rand(2));
			{#LOCK RESULT QUEUE
				lock($MYQUEUE_RESULT);
				### DO THE JOB
				
				&my_workexec(\$item);
				
				### END THE JOB
				my @result=["test result $item"];
				$MYQUEUE_RESULT -> enqueue(\@result);
			}#LOCK RESULT QUEUE
		}
	}
	return;
	
}

sub my_workexec{
	my $href_server=shift;
	say Dumper($href_server);
	say ${$href_server};
}