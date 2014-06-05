#!/usr/bin/perl

use strict;
use warnings;

open INFILE , "<" ,  "$ARGV[0]" or die $!;

#[/readlogs/HP-UX/SYSTEM/DB/SDBSTT07/spimi/logs][-ro,bg,soft,tcp,retrans=2][SDBSTT07:/spimi/logs]

while (<INFILE>){
	my ($dir, $options,$share)=split(/\s+/);
	#print "[$dir][$options][$share]\n";
	my @new_dir=split('/',$dir);
	my @new_share=split(/:/,$share);
	$new_share[1] =~ s/\//_/g;
	print "/" . $new_dir[1] . "/" . $new_dir[2] . "/" .$new_dir[3] . "/" .$new_dir[4] . "/"  . $new_share[0] . "/" . $new_share[1] . "\t $options\t $share\n";
	}
