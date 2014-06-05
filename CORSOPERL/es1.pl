use FindBin;
use lib "$FindBin::Bin/lib";

use Modern::Perl;
use biagio;

my $RAGGIO=$ARGV[0];

exit 1 if($RAGGIO < 0);

my $CIRCONFERENZA=biagio::calcola_circ($RAGGIO);
#my $CIRCONFERENZA=biagio::PIGREGO * $RAGGIO * $RAGGIO ;

printf STDOUT ("il raggio del cerchio : [ %f ] \n", $CIRCONFERENZA);
