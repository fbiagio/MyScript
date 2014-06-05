#!/usr/bin/perl
 
use List::Util 'shuffle';
use strict;
 
my $infile=$ARGV[0];
 
open(INFILE,"<",$infile) or die "cannot open $infile: $!";
 
my @deck;
 
while (<INFILE>){
     if($_ =~ m/^[1-9].*/){
        my ($num , $card)=split( /\W+/,$_,2 );
        chomp($card);
        #print "[$num][$card]\n";
        for (my $i=0; $i<$num; $i++){
                        push(@deck,$card);
        }       
     }
}
close(INFILE);
  


my @shuffled = shuffle(@deck);
my $numcards=$#shuffled+1;

print "number of cards: [ $numcards]\n";

my $initial_cards=7;

&drow_initial_hand($initial_cards);


while (<STDIN>){
        chomp;
        my $line=$_;
        if ($#shuffled==0){
                print "YOU LOSE YOU DRAW ALL YOUR DECK!!! TRY AGAIN";
                print "YOU LOSE YOU DRAW ALL YOUR DECK!!! TRY AGAIN";
        }elsif($line =~ /^[d|D]/){
                print "Drow a Card\n";
        }elsif($line =~ /^[m|M]/){
                print "-->Mulligan\n";
                $initial_cards--;
                @shuffled = shuffle(@deck);
                print "Mulligan with $initial_cards\n"
                &drow_initial_hand($initial_cards);
         }
                print_commandlist()
}  

 

sub drow_initial_hand(){
        my $initial_cards=shift;
        print "--- Drow $initial_cards --- \n";
        for (my $i=0;$i<$initial_cards;$i++){
                my $drow=shift(@shuffled);
                print " $drow\n";   
        }
}

sub print_commandlist(){
        print " #command line: [d] -> Drow cards ; [m] -> Mulligan; [s]-> Statistic\n";
}
