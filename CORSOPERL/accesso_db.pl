#!/usr/bin/perl

use DBI;
use Data::Dumper;
use Modern::Perl;

use constant {
    PER_RIGA=>0,
    TUTTO=>0,
    BINDING=>1,
    };

my $dbi_dns='dbi:Pg:dbname=flipper;port=5432';

my $dbh = DBI->connect($dbi_dns, 'fer', '');

unless ($dbh) {
       die("Non raggiungo il db o non riesco ad aprirlo");
}

my $sth = $dbh->prepare("SELECT id_sup_item, id, autore, nome from items order by id_sup_item, id");

#my $rv = $sth->execute();
if ($sth->execute() ) {
  
  
  if (PER_RIGA) {
    #    for (1..$sth->rows) { ... }
    
    while (my $hash_ref = $sth->fetchrow_hashref) {
      #      print Dumper($hash_ref);
      say sprintf "%d\t%d:  %d  %s" , (defined $hash_ref->{id_sup_item} ? $hash_ref->{id_sup_item} : 0),  $hash_ref->{id}, $hash_ref->{autore}, $hash_ref->{nome};
      #      say "$hash_ref->{id_sup_item}  $hash_ref->{id} $hash_ref->{autore}  $hash_ref->{nome}";
    }
  }
  if (TUTTO) {
    my $hr = $sth->fetchall_hashref('id');
    for my $k (keys %$hr) {
      my $record = $hr->{$k};
      print Dumper($record);
      say $record->{id}, ": ", $record->{nome};
    }
  }
  if (BINDING) {
    my ($parent, $id, $autore, $nome);
    my $rc = $sth->bind_columns(\$parent, \$id, \$autore, \$nome);
    while ($sth->fetch) {
      say $parent, $id, $autore, $nome;
    }
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

