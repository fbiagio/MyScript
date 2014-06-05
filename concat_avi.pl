#!/usr/bin/perl

#concat avi versione 1.0.0.1

use strict;
if ($#ARGV < 2) {
	print "usage: concat_avi.pl <FILE1> <FILE2> ... <FILEN> <OUTFILE>\n";
	exit 3;
}

my $outfile = $ARGV[$#ARGV];
my @infile="";

for (my $i=0; $i < $#ARGV; $i++){
	push(@infile,'"'.$ARGV[$i].'"');
}

print "Programma per concatenare avi file\n";
print "INFILE [@infile]\n";
print "OUTFILE [$outfile]\n\n";

my $mencoder="/usr/bin/mencoder";
my $command="$mencoder -oac copy -ovc copy -forceidx @infile -o $outfile 1>&2";
print "eseguo comando:\n[$command]\n";
#my $exec=`$command`;

open CMD, "${command}|" or die "Error running command $!\n";
	my @command_output=<CMD>;
	close CMD;
	my $return_code= $?;

print "Comando Eseguito, ReturCode [$return_code]\n";

print "RIEPILOGO DIMENSIONI:\nINFILE:\n";
my $LS=`ls -Falh @infile`;	
print "$LS\n";
$LS=`ls -Falh $outfile`;
print "OUTFILE:\n$outfile";
