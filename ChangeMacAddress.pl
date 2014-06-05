#!/usr/bin/perl

use strict;

if ($#ARGV != 0) {
	print "usage: ChangeMacAddress.pl  <interface>\n";
	exit 3;
}


print "Programma per modificare il proprio mac address\n";

my $new_macaddress=randMac();
#my $new_macaddress="AA:VV:DD:CC:SS:AA";
my $interface=$ARGV[0];
print "Interface\t[$interface]\n";
print "MacAddress\t[$new_macaddress]\n";

my @commands=();

push(@commands, "ifconfig $ARGV[0] down");
push(@commands, "ifconfig $ARGV[0] hw ether $new_macaddress");
push(@commands, "ifconfig $ARGV[0] up");

foreach my $command (@commands){
	open CMD, "${command}|" or die "Error running command $!\n";
	my @command_output=<CMD>;
	close CMD;
	my $return_code= $?;
	print "eseguo comando:\t[$command][$return_code]\n";
}

exit 0;

sub randMac{
	my $range = 190;
	my $MacAddress;
	my $random_number;
	#hex
	#my $hexstring = sprintf("%x",$new_macaddress);
	$MacAddress = sprintf("%x",int(rand($range))+40);
	$MacAddress = "00";
	for(my $i=0;$i<5;$i++){
  		$random_number = sprintf("%x",int(rand($range))+10);	
		$MacAddress="$MacAddress" . ":" . "$random_number";
	}
	return $MacAddress;
	#return $random_number;
}

