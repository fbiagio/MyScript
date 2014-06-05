package biagio;

use constant{
	PIGREGO=>3.14 , 
};




sub myreverse{
	my @ROW=@_;
        return reverse(@ROW);
}

sub calcola_circ{
	my $RAGGIO=shift;
	my $CIRCONFERENZA=PIGREGO * $RAGGIO * $RAGGIO ;
	return $CIRCONFERENZA;
}

1; #VALORE NECESSARIO PER INCLUD EDELLA LIBRERIA

