#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use YAML ();


my $data = YAML::LoadFile('metrics.yaml');

for my $h1 (sort keys %$data) {
    my $d1 = $data->{$h1};

    printf("## %s\n\n", $h1);

    for my $h2 (sort keys %$d1) {
        my $d2 = $d1->{$h2};

        printf("### %s\n\n", $h2);

        for my $p (sort keys %$d2) {
            my $d = $d2->{$p};

            printf("#### %s\n\n", $p);

            if (!ref $d) {
                if (defined $d) {
                    printf("См. [%s](#%s).\n\n", $d, $d);
                }
                else {
                    warn("No place link");
                }
                next;
            }

            if (my @r = sort grep { my $v = $d2->{$_}; defined($v) && !ref($v) && $v eq $p } keys %$d2) {
                printf("Также %s.\n\n", join(', ', @r));
            }

            for (sort { $a <=> $b} keys %$d) {
                printf("- %d: ", $_);
                print(join(', ', map { sprintf("[ф. %s, оп. %s, д. %s](%s)", @{$_->{p}}, $_->{u}) } ref($d->{$_}) eq 'ARRAY' ? @{$d->{$_}} : $d->{$_}), "\n");
            }
            print("\n");
        }
    }
}
