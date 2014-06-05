#!/usr/bin/perl
# video wall - opens a -w times -h wall of mplayer videos, randomly
# playing the files specified until interrupt signal is received.

use Getopt::Std;
getopts( 'i:w:h:' );

if( $#ARGV == -1 ){
	die("Usage: $0 [-w grid width] [-h grid height] filenames...\n");
}

my @files = @ARGV;

my $width = $opt_w || 3;
my $height = $opt_h || 3;

my $dims = `xdpyinfo | grep dimensions | awk '{print \$2}' | sed 's/x/ /'`;
my ($xres, $yres) = split / /, $dims;

my @children;
$SIG{'INT'} = 'interrupt';

if( $opt_i ){
	# -i is used to continually play back random videos at a certain
	#    screen position specified by the index. it is usually used
	#    only by the program itself when forking.
	video_handler();

} else {
	# normal user-initiated program flow - forks a new process for each desired
	# video window, using the -i option for each.

	for( $i=1; $i <= $width*$height; $i++ ){
		my $pid = fork();
		if( $pid == 0 ){
			exec("$0 -w$width -h$height -i$i @files");
		} else {
			$children[$i-1] = $pid;
		}
	}

	# continue to run until interrupted
	while( 1 ){
		sleep(1);
	}
}

# interrupt handler - kills all child videos on CTRL+C
sub interrupt {
	foreach $pid( @children ){
		system("kill $pid");
	}
	exit(0);
}
	
sub video_handler {
	my $index = $opt_i-1;
	my $ypos = int($index / $width);
	my $xpos = $index % $width;
	my $windowx = int( ($xres / $width)*$xpos );
	my $windowy = int( ($yres / $height)*$ypos );
	my $windoww = int( $xres / $width );
	my $windowh = int( $yres / $height );

	while( 1 ){
		my $filename = $files[ rand($#files + 1) ];
		if( $filename ){
			open_video_window( $filename, $windowx, $windowy, $windoww, $windowh );
		} else {
			print("Filename error\n");
		}
		sleep(1);
	}
}

sub open_video_window {
	my ($filename, $x, $y, $w, $h) = @_;
	my $display = $ENV{'DISPLAY'};
	`mplayer -zoom -noborder -display $display -vo x11 -geometry $x:$y -xy $w $filename 2>&1`;
}
