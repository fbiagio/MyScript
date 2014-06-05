#!/usr/bin/perl
use strict;

#
#SI ASPETTA ALMENO UN ARGOMENTO
#
print "[numero argomenti $#ARGV]\n";
if ($#ARGV < 0 ) {
print "Syntax: stato.pl [-b | -h | -d | -a | -p] [-q]\n";
print "Options:\n";
print " -b\t Visualizza lo stato delle lan di boot di tutti i nodi del cluster\n";
print " -h\t Visualizza lo stato delle lan di hb di tutti i nodi del cluster\n";
print " -d\t Visualizza lo stato delle lan di dati su tutti i nodi del cluster\n";
print " -a\t Visualizza lo stato di tutte le lan connesse su tutti i nodi del cluster\n";
print " -s\t Visualizza lo stato di tutti i Service Group presenti nel cluster\n";
exit;
}

my @Options;
my @Systems;
my @ServiceGroups;

foreach (@ARGV) {
	my ($trash,$opt)=split('-',$_);
	push(@Options,$opt);
}

#eseguo funzione per recuperare stato nodi del cluster 

foreach (@Options) {
	print "opzioni:[$_]\n";
	#eseguo funzione
}
&DataLoad;
	
exit 0;

sub DataLoad{
	my $maincf="/home/takke/MyScript/main.cf";
	open FILE,"<" ,$maincf or die $!;
 	while (<FILE>) {
		if ($_ =~ m/^\s*(system)\s+(\S+).*/) {push(@Systems,$2);print "[$2]\n";}
		if ($_ =~ m/^\s*(group)\s+(\S+).*/) {push(@ServiceGroups,$2);print "[$2]\n";}
 	}
}

