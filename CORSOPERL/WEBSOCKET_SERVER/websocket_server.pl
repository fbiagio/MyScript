use AnyEvent::Socket qw(tcp_server);
use AnyEvent::WebSocket::Server;


use AnyEvent::Loop;
use AnyEvent;
 
my $tcp_server; 
my $server = AnyEvent::WebSocket::Server->new(
    validator => sub {
        my ($req) = @_;  ## Protocol::WebSocket::Request
         
        my $path = $req->resource_name;
        die "Invalid format" if $path !~ m{^/(\d{4})/(\d{2})};
         
        my ($year, $month) = ($1, $2);
        die "Invalid month" if $month <= 0 || $month > 12;
 
        return ($year, $month);
    }
);
 
$tcp_server undef, 8080, sub {
    my ($fh) = @_;
    $server->establish($fh)->cb(sub {
        my ($conn, $year, $month) = eval { shift->recv };
	print "$conn, $year, $month\n";
        if($@) {
            my $error = $@;
            print "$error\n";
            error_response($fh, $error);
            return;
        }
        $conn->send("You are accessing YEAR = $year, MONTH = $month");
        $conn->on(finish => sub { undef $conn });
    });
};

AnyEvent::Loop::run; # run the event loop


