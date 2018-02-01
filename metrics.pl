#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use YAML ();


my $data = YAML::LoadFile($ARGV[0]);

for my $h1 (sort keys %$data) {
    my $d1 = $data->{$h1};

    printf("## %s\n\n", $h1);

    for my $h2 (sort keys %$d1) {
        my $d2 = $d1->{$h2};

        printf("### %s\n\n", $h2);

        for (sort keys %$d2) {
            printf("- [%s](#%s)\n", $_, join('-', split(/[\s,]+/, $_)));
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

            for my $y (sort keys %$d) {
                my @l = ref $d->{$y} eq 'ARRAY' ? @{$d->{$y}} : $d->{$y};

                printf("- %s — ", $y);
                for (0 .. $#l) {
                    unless (ref $l[$_]{u} eq 'ARRAY') {
                        printf("[ф. %s, оп. %s, д. %s](%s)", @{$l[$_]{p}}, $l[$_]{u});
                        next;
                    }

                    my @m = ref $l[$_]{u}[0] ? @{$l[$_]{u}} : $l[$_]{u};
                    my $f = '';

                    printf("ф. %s, оп. %s, д. %s: ", @{$l[$_]{p}});
                    for (0 .. $#m) {
                        if (!$f || $m[$_][0] ne $f) {
                            printf('[#%s[', $m[$_][0]);
                            $f = $m[$_][0];
                        }
                        else {
                            print('[[');
                        }
                        if (defined $m[$_][2]) {
                            printf('%d—%d', $m[$_][1] + 1, $m[$_][2] + 1);
                        }
                        else {
                            printf('%d', $m[$_][1] + 1);
                        }
                        printf(']](https://www.familysearch.org/search/film/%s?i=%d)', $m[$_][0], $m[$_][1]);
                    }
                    continue {
                        print(', ') if $_ < $#m;
                    }
                }
                continue {
                    print('; ') if $_ < $#l;
                }
                print("\n");
            }
            print("\n");
        }
    }
}
