BEGIN {push @INC, './lib/'}
use Modern::Perl;
use Fantacalcio::Squadre;
use Fantacalcio::Giocatore;
#CARICO STRUTTURA DATI
open(my $fh,"<","./elencoSquadre.csv") || die "error opening file $!";
my %ElencoSquadre;
while (<$fh>){
	my @csv=split(/;/);
	$ElencoSquadre{"$csv[0]"} = Fantacalcio::Squadre->new(Presidente => $csv[0], Nome => $csv[1] , DisponibilitaEconomica => $csv[2] ); 
}
close($fh);

open(my $fh_giocatori,"<","./elencoGiocatori.csv") || die "error opening file $!";
my %ElencoGiocatori;
my $ID=1;
while (<$fh_giocatori>){
	my @csv=split(/;/);
	$ElencoGiocatori{"$csv[0]"} = Fantacalcio::Giocatore->new(IDgiocatore=>$ID, NomeCognome=>$csv[0],ValoreCartellino=>$csv[1],Ruolo=>$csv[2]);
	$ID++;
}
close($fh_giocatori);

say "===================================================";
say "chiedo a ciascun PRESIDENTE di presentarsi";

for my $key (keys %ElencoSquadre){
	say "Si presenti $key";
	$ElencoSquadre{$key}->info();
}
say "===================================================";
say "chiedo a ciascun GIOCATORE di presentarsi";

for my $key (keys %ElencoGiocatori){
	say "Si presenti $key";
	$ElencoGiocatori{$key}->info();
}
##################################
##################################
#inserisco i portieri
##################################
$ElencoSquadre{"Biagio"}->add_portiere("mioprimoportiere");
$ElencoSquadre{"Biagio"}->add_portiere("miosecondoportiere");

say "chiedo a Biagio di elencare la lista dei portieri";

$ElencoSquadre{"Biagio"}->say_portieri();

