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

        for (sort keys %$d2) {
            printf("- [%s](#%s)\n", $_, join('-', split(' ', $_)));
        }
        print("\n");

        for my $p (sort keys %$d2) {
            my $d = $d2->{$p};

            printf("#### %s\n\n", $p);

            if (!ref $d || ref $d eq 'ARRAY') {
                my @l = ref $d ? @$d : defined $d ? $d : ();

                if (@l) {
                    print("См. " . join(", ", map { sprintf("[%s](#%s)", $_, join('-', split(' ', $_))) } sort @l) . ".\n\n");
                }
                else {
                    warn("No place link for \"" . $p . "\"\n");
                }
                next;
            }

            if (my @r = sort grep { my $v = $d2->{$_}; defined($v) && (!ref($v) && $v eq $p || ref($v) eq 'ARRAY' && grep { $_ eq $p } @$v) } keys %$d2) {
                printf("Также %s.\n\n", join(', ', @r));
            }

            for (sort keys %$d) {
                printf("- %s: ", $_);
                print(join(', ', map { sprintf("[ф. %s, оп. %s, д. %s](%s)", @{$_->{p}}, $_->{u}) } ref($d->{$_}) eq 'ARRAY' ? @{$d->{$_}} : $d->{$_}), "\n");
            }
            print("\n");
        }
    }
}
