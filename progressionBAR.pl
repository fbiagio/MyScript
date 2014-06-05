    use Text::ProgressBar::Bar;

    my $pbar = Text::ProgressBar->new();
    $pbar->start();
    for my $i (1..100) {
        sleep 0,1;
        $pbar->update($i);
    }
    $pbar->finish;
