    use Text::ProgressBar::ETA;

    my $bar = Text::ProgressBar->new(widgets => [Text::ProgressBar::ETA->new()]);
    $bar->start();
    for my $i (1..100) {
        sleep 0.2;
        $bar->update($i+1);
    }
    $bar->finish;
