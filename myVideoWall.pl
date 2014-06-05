#!/usr/bin/perl

use Modern::Perl;
use threads;
use threads::shared;
use Thread::Queue;
use File::Find;
use Data::Dumper;
#use Array::Shuffle qw(shuffle_array);
use List::Util qw(shuffle);;
#######################################
# VERIFICA ARGOMENTI PASSATI ED HELP
#######################################

#######################################
#	MAIN based on 23102012_queueThread.pl
#######################################
#######################################
use constant{
	DEBUG=>1,
	DEBUG2=>0,
	DEBUG_THREAD=>0
};


say STDOUT "\tDEBUG  ATTIVO" if (DEBUG);
say STDOUT "\t\tDEBUG 2 ATTIVO - CONTROLLO COSA FANNI I THREAD\n" if (DEBUG_THREAD);


my @DIM=('0%:0%','100%:100%','100%:0%','0%:100%');
my $width =  2;
my $height =  2;

my $dims = `xdpyinfo | grep dimensions | awk '{print \$2}' | sed 's/x/ /'`;
my ($xres, $yres) = split / /, $dims;

my @files;



say STDOUT "Find Video" if (DEBUG);
my @FILMS_PATH;
my %listafilm_inpath;
my $myDir; 
foreach (@ARGV){
	say "directory [$_]";
	$myDir=$_;
	my $arr_ref=[];
	my $hash_ref={};
	$listafilm_inpath{$myDir}=$hash_ref;
	$listafilm_inpath{$myDir}->{ListaFilms}=$arr_ref;
	$listafilm_inpath{$myDir}->{queue_ref}=Thread::Queue->new();
	say "finding....";
	find({wanted => \&searchSUB, no_chdir => 1},$_);
}


say Dumper(\%listafilm_inpath);
say STDOUT "Radomize video array" if (DEBUG);



say STDOUT "Randomize video";
my @FILMQUEUE;
foreach (@ARGV){
	$myDir=$_;
	foreach (shuffle @{$listafilm_inpath{$myDir}{ListaFilms}}){
		say "$_";
		$listafilm_inpath{$myDir}{queue_ref}->enqueue($_);
	}
	
}

say Dumper(\%listafilm_inpath);


#######################################
my @MYTHREAD;
my $MAX_RUNNING_THREADS=$width * $height ;


say STDOUT "NUMERO DI THREAD: [$MAX_RUNNING_THREADS]" if (DEBUG);

#######################################
#inizializzo la coda


my $RUNNING_THREADS=0;
	
	
############ FACCIO PARTIRE TUTII I THREAD ###

say STDOUT "DEBUG1: Faccio partire tutti i $MAX_RUNNING_THREADS thread" if (DEBUG);
for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
	say STDOUT "\tDEBUG2: Faccio partire thread numero $RUNNING_THREADS" if (DEBUG2);
	$MYTHREAD[$RUNNING_THREADS]=threads->create({'context' => 'void'},\&myCMD, $RUNNING_THREADS);
}

############ ATTENGO CHE TUTTI I THREAD SIANO IN STATO JOINABLE ###

my $JOINABLE=0;
while ($JOINABLE != $MAX_RUNNING_THREADS ){
	#say STDOUT "\tDEBUG1: Attendo che tutti i thread siano joinabili" if (DEBUG);
	$JOINABLE=0;
	for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
		if ($MYTHREAD["$RUNNING_THREADS"]->is_joinable()){
			#say STDOUT "\t\tDEBUG2: il thread [$RUNNING_THREADS] is_joinable" if (DEBUG2);
			$JOINABLE++;
		}
	}
	sleep 100;
}

############ EFFETTUO IL JOIN DEI THREAD ###
say STDOUT "\tDEBUG1: Effettuo il join di tutti i thread" if (DEBUG);
for(my $RUNNING_THREADS=0; $RUNNING_THREADS < $MAX_RUNNING_THREADS; $RUNNING_THREADS++) {
	say STDOUT "\t\tDEBUG2: Effettuo il join del thread [$RUNNING_THREADS]" if (DEBUG2);
	$MYTHREAD["$RUNNING_THREADS"]->join();
}

#######################################
print "\nPowered by Takke\n";



#######################################
# FUNZIONI 
#######################################





sub myCMD{
	#######################################
	# My THREADS CMD
	#######################################
	my $THREAD_NUMBER=shift;
	my $CARD_ARRAY=shift;
	my $HAVETODO=1;
	my $index = $THREAD_NUMBER;
	my $screenw=$xres/2;
	my $screenh=$yres/2;
	
	say STDOUT "\t\tTHREAD DEBUG[$THREAD_NUMBER] - thread numero [$THREAD_NUMBER] partito" if (DEBUG_THREAD);
	while ( $HAVETODO == 1 )  {
		foreach(@ARGV){
			my $fm;
		  	#LOCK QUEUE
		  	{
			lock($listafilm_inpath{$_}{queue_ref});
			
			if ($listafilm_inpath{$_}{queue_ref}->pending() != 0){
				say STDOUT "\t\tTHREAD DEBUG[$THREAD_NUMBER] - la coda non è vuota, estraggo da $_" if (DEBUG_THREAD);
				$fm=$listafilm_inpath{$_}{queue_ref}->dequeue_nb();
				$listafilm_inpath{$_}{queue_ref}->enqueue($fm);
			}
			}#LOCK QUEUE
				my $display = $ENV{'DISPLAY'};
				my $randtime=int rand(3600);
				my $randtime2=int rand(6)+1;
				#my $ll=`ffmpeg -i $fm 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,//`;# | awk '{ split($1, A, ":"); print 3600*A[1] + 60*A[2] + A[3] }'`;
				#chomp($ll);
				#01:13:43.26
				#(my $h,my $m, my $s)=split(/:/,$ll);
				#my $lll=((($h*60)+$m)*60);
				#my $randtime=int rand($lll);
				say STDOUT "[ $THREAD_NUMBER ] $fm [\$ll] -- Start [$randtime] End after [$randtime2]";
				#`mplayer -zoom -noborder -ss $randtime -endpos 00:$randtime2:00  -vo x11 -geometry $DIM[$index] -y $screenh -x $screenw \'$fm\' 2>&1`;
				`mplayer -zoom -noborder   -vo x11 -geometry $DIM[$index] -y $screenh -x $screenw \'$fm\' 2>&1`;
								
				
		  
		}
	}
	return;	
}

sub searchSUB{
	if ($_  =~  m/flv|VOB|asf|avi|mp4|mpg|rmvb|mkv|wmw/i) {
		#say STDOUT "film : $_" if(DEBUG);
		push(@{$listafilm_inpath{$myDir}->{ListaFilms}},$_);	
	}		
}
