#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use YAML ();


my ($meta, $data) = YAML::LoadFile($ARGV[0]);
my $films = YAML::LoadFile('films.yaml');

unless ($data) {
    $data = $meta;
    $meta = undef;
}

if ($meta) {
    printf("### %s\n\n", $meta->{title});
}

if (%$data) {
    foreach my $place ( sort keys %$data ) {
        printf("- [%s](#%s)\n", $place, join('-', split(/[\s,]+/, $place)));
    }
    print("\n");

    foreach my $place ( sort keys %$data ) {
        my $dp = $data->{$place};

        printf("#### %s\n\n", $place);

        if (!ref $dp || ref $dp eq 'ARRAY') {
            my @l = ref $dp ? @$dp : defined $dp ? $dp : ();

            if (@l) {
                print("См. " . join(", ", map { sprintf("[%s](#%s)", $_, join('-', split(/[\s,]+/, $_))) } sort @l) . ".\n\n");
            }
            else {
                warn("No place link for \"" . $place . "\"\n");
            }
            next;
        }

        if (my @r = sort grep { my $v = $data->{$_}; defined($v) && (!ref($v) && $v eq $place || ref($v) eq 'ARRAY' && grep { $_ eq $place } @$v) } keys %$data) {
            printf("Также %s.\n\n", join(', ', @r));
        }

        for my $t (sort keys %$dp) {
            my $d = $dp->{$t};

            printf("##### %s\n\n", $t);

            for my $y (sort keys %$d) {
                my @l = ref $d->{$y} eq 'ARRAY' ? @{$d->{$y}} : $d->{$y};

                printf("- %s — ", $y);

                for (0 .. $#l) {
                    next unless defined $l[$_];

                    unless (ref $l[$_]{u} eq 'ARRAY') {
                        unshift(@{$l[$_]{p}}, 'ГАРТ') if @{$l[$_]{p}} < 4;
                        printf("[%s, ф. %s, оп. %s, д. %s](%s)", @{$l[$_]{p}}, $l[$_]{u});
                        next;
                    }

                    my @m = ref $l[$_]{u}[0] ? @{$l[$_]{u}} : $l[$_]{u};
                    my $f = '';

                    unshift(@{$l[$_]{p}}, 'ГАРТ') if @{$l[$_]{p}} < 4;
                    printf("%s, ф. %s, оп. %s, д. %s: ", @{$l[$_]{p}});
                    for (0 .. $#m) {
                        if (!$f || $m[$_][0] ne $f) {
                            printf('[#%s[', $films->{$m[$_][0]} // '{' . $m[$_][0] . '}');
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
