#!/usr/bin/perl
use strict; 
use threads;
use threads::shared;
use Thread::Queue;

######################################################################################
#	PERL SCRIPT BASED ON THREAD_TEMPLATE/23102012_queueThread.pl
######################################################################################


#######################################
# VERIFICA ARGOMENTI PASSATI ED HELP
#######################################
# print STDOUT "[numero argomenti $#ARGV]\n";
#if ($#ARGV < 1 ) {
#	print "Syntax: thread.pl -l:lista -s:SCRIPT_FILE -t:[numTHREADS] \n";
#	print "Options:\n";
#	print " -l\t file con la lista dei nodi su cui eseguire lo scipt\n";
#	print " -s\t scipt da eseguire\n";
#	exit 120;
#}
#
#######################################
#	MAIN
#######################################

my %Options;
my @MYTHREAD;
my $DEMONE=1;
my $DEBUG=0;
my $DEBUG_THREAD=0;

#######################################
my $MAX_RUNNING_THREADS=4;
#######################################

if ($DEBUG==1){print STDOUT "DEBUG 1 ATTIVO\n";}
if ($DEBUG==2){print STDOUT "DEBUG 2 ATTIVO - CONTROLLO COSA FANNO I THREAD\n";}
if ($DEBUG==3){print STDOUT "DEBUG 3 ATTIVO\n";}

#foreach (@ARGV) {
#        my ($opt,$todo)=split(':',$_);
#                $Options{$opt}=$todo;
#                }

# my $InFile=$Options{"-l"};
# if (! -e $InFile){
	# print STDOUT "ERROR [$InFile] InFile do not exist\n";
	# exit 121;
# }
# my $ScriptFile=$Options{"-s"};
# if (! -e $ScriptFile){
	# print SDTOUT "ERROR [$ScriptFile] ScriptFile do not exist\n";
	# exit 122;
# }
my $InFile="/home/takke/MyScript/THREAD_TEMPLATE/lista.txt";
#######################################
#inserire codice controllo opzioni
#######################################

#print "INFILE: [$InFile]\nSCRIPT: [$ScriptFile]\n";
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
my $_numOK=$MYQUEUE_RESULT_OK->pending();

my $_numKO=$MYQUEUE_RESULT_KO->pending();

&PrintThreadResult($MYQUEUE_RESULT_OK, "RISULTATI POSITIVI\n");
&PrintThreadResult($MYQUEUE_RESULT_KO, "RISULTATI NEGATIVI\n");
&GeneraHTML($_numOK,$_numKO);

#######################################
print "\nPowered by Takke\n";

#######################################
# FUNZIONI 
#######################################
sub ReadList{
	my $filename= shift;
	my @ARRAY;
	if ($DEBUG  > 0){print STDOUT "\#...LEGGO FILE CON LA LISTA DELLE MACCHINE...\n";}
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


sub GeneraHTML {
	my $XnumOK=shift;
	my $XnumKO=shift;
	open HTMLFILE, ">", "/var/www/html/index.html" or die $!;
	printf HTMLFILE " <html>\n";
	printf HTMLFILE "       <head>                                                                                         \n";
	printf HTMLFILE "         <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>                  \n";
	printf HTMLFILE "         <script type=\"text/javascript\">                                                              \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "           // Load the Visualization API and the piechart package.                                    \n";
	printf HTMLFILE "           google.load(\'visualization\', \'1.0\', {\'packages\':[\'corechart\']});                           \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "           // Set a callback to run when the Google Visualization API is loaded.                      \n";
	printf HTMLFILE "           google.setOnLoadCallback(drawChart);                                                       \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "           // Callback that creates and populates a data table,                                       \n";
	printf HTMLFILE "           // instantiates the pie chart, passes in the data and                                      \n";
	printf HTMLFILE "           // draws it.                                                                               \n";
	printf HTMLFILE "           function drawChart() {                                                                     \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "             // Create the data table.                                                                \n";
	printf HTMLFILE "             var data = new google.visualization.DataTable();                                         \n";
	printf HTMLFILE "             data.addColumn(\'string\', \'Stato\');                                                     \n";
	printf HTMLFILE "             data.addColumn(\'number\', \'numeroXstato\');                                                      \n";
	printf HTMLFILE "             data.addRows([                                                                           \n";
	printf HTMLFILE "               [\'Server OK\', " . ${XnumOK} ."],                                                                      \n";
	printf HTMLFILE "               [\'Server NOK\'," .  ${XnumKO} . "]                                                                       \n";
	printf HTMLFILE "             ]);                                                                                      \n";
	printf HTMLFILE "             // Create the data table.                                                                \n";
	printf HTMLFILE "             var data2 = new google.visualization.DataTable();                                        \n";
	printf HTMLFILE "             data2.addColumn(\'string\', \'Sito\');                                                    \n";
	printf HTMLFILE "             data2.addColumn(\'number\', \'numeroXsito\');                                                     \n";
	printf HTMLFILE "             data2.addRows([                                                                          \n";
	printf HTMLFILE "               [\'Moncalieri\', 3],                                                                      \n";
	printf HTMLFILE "               [\'Settimo\', 1],                                                                         \n";
	printf HTMLFILE "               [\'VM\', 15],                                                                        \n";
	printf HTMLFILE "               [\'CED\', 15],                                                                        \n";
	printf HTMLFILE "               [\'CAMPUS\', 2]                                                                       \n";
	printf HTMLFILE "             ]);                                                                                      \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "             var data3 = new google.visualization.DataTable();                                        \n";
	printf HTMLFILE "             data3.addColumn(\'string\', \'Year\');                                                       \n";
	printf HTMLFILE "             data3.addColumn(\'number\', \'Sales\');                                                      \n";
	printf HTMLFILE "             data3.addColumn(\'number\', \'Expenses\');                                                   \n";
	printf HTMLFILE "             data3.addRows([                                                                          \n";
	printf HTMLFILE "               [\'2004\', 1000, 400],                                                                   \n";
	printf HTMLFILE "               [\'2005\', 1170, 460],                                                                   \n";
	printf HTMLFILE "               [\'2006\',  860, 580],                                                                   \n";
	printf HTMLFILE "               [\'2007\', 1030, 540]                                                                    \n";
	printf HTMLFILE "             ]);                                                                                      \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "             var options = {\'title\':\'Stato sistemi\',                                                                 \n";
	printf HTMLFILE "                            \'width\':600,                                                              \n";
	printf HTMLFILE "                            \'height\':400};                                                            \n";
	printf HTMLFILE "             var options2 = {\'title\':\'GEOGRAPHICAL SITE\',                                                         \n";
	printf HTMLFILE "                            \'width\':400,                                                              \n";
	printf HTMLFILE "                            \'height\':300};                                                            \n";
	printf HTMLFILE "             var options3 = {\'title\':\'Line chart\',                                                    \n";
	printf HTMLFILE "                            \'width\':400,                                                              \n";
	printf HTMLFILE "                            \'height\':300};                                                            \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "             // Instantiate and draw our chart, passing in some options.                              \n";
	printf HTMLFILE "             var chart = new google.visualization.PieChart(document.getElementById(\'chart_div\'));     \n";
	printf HTMLFILE "             chart.draw(data, options);                                                               \n";
	printf HTMLFILE "             var chart2 = new google.visualization.PieChart(document.getElementById(\'chart_div2\'));   \n";
	printf HTMLFILE "             chart2.draw(data2, options2);                                                            \n";
	printf HTMLFILE "             var chart3 = new google.visualization.LineChart(document.getElementById(\'chart_div3\'));  \n";
	printf HTMLFILE "             chart3.draw(data3, options3);                                                            \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "           }                                                                                          \n";
	printf HTMLFILE "         </script>                                                                                    \n";
	printf HTMLFILE "       </head>                                                                                        \n";
	printf HTMLFILE "                                                                                                      \n";
	printf HTMLFILE "       <body>                                                                                         \n";
	printf HTMLFILE "         <!--Divs that will hold the charts-->                                                        \n";
	printf HTMLFILE "         <table>                                                                                      \n";
	printf HTMLFILE "                 <tr>                                                                                 \n";
	printf HTMLFILE "                         <td><div id=\"chart_div\"></div></td>                                          \n";
	printf HTMLFILE "                         <td>                                                                         \n";
	printf HTMLFILE "                         <table> <tr><td><div id=\"chart_div2\"></div></td></tr>                        \n";
	printf HTMLFILE "                                 <tr><td><div id=\"chart_div3\"></div></td></tr>                        \n";
	printf HTMLFILE "                         </table>                                                                     \n";
	printf HTMLFILE "                         </td>                                                                        \n";
	printf HTMLFILE "                 </tr>                                                                                \n";
	printf HTMLFILE "         </table>                                                                                     \n";
	printf HTMLFILE "         </table>                                                                                     \n";
	printf HTMLFILE "       </body>                                                                                        \n";
	printf HTMLFILE "     </html>                                                                                          \n";
	close(HTMLFILE);
}
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
			if ($DEBUG_THREAD >= 0){sleep 1;}
			my $result= int(rand(2));
			if ($result == 1){
				lock($MYQUEUE_RESULT_OK);
				$MYQUEUE_RESULT_OK -> enqueue(${SERVERNAME} . "_" . ${result});
			}else{
				lock($MYQUEUE_RESULT_KO);
				$MYQUEUE_RESULT_KO -> enqueue(${SERVERNAME} . "_" . ${result});
			}	
			if ($DEBUG_THREAD > 0){print STDOUT "\tTHREAD DEBUG[$THREAD_NUMBER] -Stò lavorarndo col [$SERVERNAME]\n";}
		}
	}
	{
		lock($MYFINISH_THREAD);
		$MYFINISH_THREAD -> enqueue($THREAD_NUMBER);
	}
	return;
	
}

#papo eon
#caterin
#