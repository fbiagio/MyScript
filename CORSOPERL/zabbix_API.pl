#!/usr/bin/perl

use Modern::Perl;
use JSON::RPC::Client;
use JSON;
use Data::Dumper;

# Authenticate yourself
my $client = new JSON::RPC::Client;
my $url = 'http:///sglvmp52/zabbix/api_jsonrpc.php';
my $authID;
my $response;
my $json;


&authenticateZabbbix();

# Get list of all hosts using authID

$json = {
    jsonrpc=> '2.0',
    method => 'host.get',
    params =>
    {
	output => ['hostid','name'],# get only host id and host name
	sortfield => 'name',        # sort by host name
    },
    id => 2,
    auth => "$authID",
};
$response = $client->call($url, $json);

# Check if response was successful
die "host.get failed\n" unless $response->content->{result};

print "List of hosts\n-----------------------------\n";
foreach my $host (@{$response->content->{result}}) {
print "Host ID: ".$host->{hostid}." Host: ".$host->{name}."\n";
}



sub authenticateZABBIX(){
    my $jsonAuth = {
	jsonrpc => "2.0",
	method => "user.login",
	params => {
	    user => "admin",
	    password => "zabbix"
	},
	id => 1
    };

    $response = $client->call($url, $jsonAuth);
    
    # Check if response was successful
    die "Authentication failed\n" unless $response->content->{'result'};

    $authID = $response->content->{'result'};
    say "Authentication successful. Auth ID: " . $authID ;
}
