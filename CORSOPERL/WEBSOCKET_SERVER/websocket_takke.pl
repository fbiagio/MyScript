    use Net::WebSocket::Server;
    use Data::Dumper;


    Net::WebSocket::Server->new(
        listen => 16000,
        on_connect => sub {
            my ($serv, $conn) = @_;
	    print "$serv, $conn\n";
	    print Dumper($conn);
            $conn->on(
                utf8 => sub {
                    my ($conn, $msg) = @_;
                    $_->send_utf8(rand 100) for $conn->server->connections;
                },
            );
        },
    )->start;



