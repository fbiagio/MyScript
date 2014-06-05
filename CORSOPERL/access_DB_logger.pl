#!/usr/bin/perl

use DBI;
use Data::Dumper;
use Modern::Perl;
#use Log::Log4perl qw(:easy);


Log::Log4perl::init_and_watch('./log4perl.conf',10);
my $logger = Log::Log4perl->get_logger();
use constant {
    DEBUGTAKKE=>0,
    };

my %PPID;
my %GPPID;

my $dbi_dns='dbi:Pg:dbname=flipper;port=5432';
my $dbh = DBI->connect($dbi_dns, 'fer', '');

unless ($dbh) {
       die("Non raggiungo il db o non riesco ad aprirlo");
}

my $sth = $dbh->prepare("SELECT id_sup_item, id from items order by id_sup_item, id");

#my $rv = $sth->execute();
if ($sth->execute() ) {
  
    while (my $hash_ref = $sth->fetchrow_hashref) {
      $PPID{$hash_ref->{id}}=0+(0+$hash_ref->{id_sup_item});
    }
}

if(DEBUGTAKKE){say Dumper(\%PPID);}
#exit 1;
for my $key (keys %PPID) {
	my $value=$PPID{"$key"};
	my $antenato;
	print "PID  [ $key ]";
	if ($value == 0){
		$antenato=$value;
		$logger->debug("DEBUG_", $key, $antenato);
	}else{
		$antenato=&genera_tabella($value);
		$logger->info("INFO_", $key, $antenato);
	}
	say $antenato;
	$GPPID{$key}=$value;
}

if(DEBUGTAKKE){say Dumper(\%GPPID);}


#my $sth2 = $dbh->prepare("INSERT INTO takke (id, gpid) VALUES(?,?)");
#for my $key (keys %GPPID) {
#	$sth2->execute($key,$GPPID{$key});
#}
#$dbh->commit or die $dbh->errstr;

sub genera_tabella{
	my $V=shift;
	#print "  ($V)";
	if ($PPID{$V} == 0){
		 #sono alla fine
		 #say "fine ricorsione ... sono all'antenato $V- $PPID{$V}";
		 return "$V";
		 
	}else{	
		&genera_tabella($PPID{$V});
	}	
}


__END__

                                        Table "public.items"
      Column      |            Type             |                     Modifiers                      
------------------+-----------------------------+----------------------------------------------------
 id               | integer                     | not null default nextval('files_id_seq'::regclass)
 nome             | text                        | not null
 descrizione      | text                        | not null
 creazione        | date                        | default now()
 autore           | integer                     | 
 crediti          | integer                     | 
 riferimenti      | text                        | 
 livello_security | integer                     | not null default 0
 bozza            | boolean                     | default false
 last_update      | timestamp without time zone | 
 id_sup_item      | integer                     | 
Indexes:
    "items_pkey" PRIMARY KEY, btree (id)
    "items_nome_key" UNIQUE CONSTRAINT, btree (nome)
Foreign-key constraints:
    "items_autore_fkey" FOREIGN KEY (autore) REFERENCES users(id)
    "items_id_sup_item_fkey" FOREIGN KEY (id_sup_item) REFERENCES items(id) ON UPDATE CASCADE
Referenced by:
    TABLE "item_comment" CONSTRAINT "item_comment_id_item_fkey" FOREIGN KEY (id_item) REFERENCES items(id)
    TABLE "item_item" CONSTRAINT "item_item_id_item_from_fkey" FOREIGN KEY (id_item_from) REFERENCES items(id) ON UPDATE CASCADE
    TABLE "item_item" CONSTRAINT "item_item_id_item_to_fkey" FOREIGN KEY (id_item_to) REFERENCES items(id) ON UPDATE CASCADE
    TABLE "item_pathway" CONSTRAINT "item_pathway_id_item_fkey" FOREIGN KEY (id_item) REFERENCES items(id)
    TABLE "item_patient" CONSTRAINT "item_patient_id_item_fkey" FOREIGN KEY (id_item) REFERENCES items(id)
    TABLE "items" CONSTRAINT "items_id_sup_item_fkey" FOREIGN KEY (id_sup_item) REFERENCES items(id) ON UPDATE CASCADE
    TABLE "rule_item" CONSTRAINT "rule_item_id_item_fkey" FOREIGN KEY (id_item) REFERENCES items(id)
Triggers:
    modified BEFORE UPDATE ON items FOR EACH ROW EXECUTE PROCEDURE just_updated()
Inherits: files


