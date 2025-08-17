#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use YAML ();


my ($meta, $data) = YAML::LoadFile($ARGV[0]);
my $films = {}; # YAML::LoadFile('films.yaml');

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

                    my $cite = $l[$_]{p};
                    my $link = $l[$_]{u};

                    # Old format.
                    unless (ref $link eq 'ARRAY') {
                        if ( @$cite == 3 ) {
                            unshift(@$cite, $meta && $meta->{archive} || 'ГАРТ');
                        }
                        printf('[%s, ф. %s, оп. %s, д. %s](%s)', @$cite, $link);
                        next;
                    }

                    if ( @$cite == 3 || @$cite == 5 ) {
                        unshift(@$cite, $meta && $meta->{archive} || 'ГАРТ');
                    }
                    if ( @$cite == 4 ) {
                        printf('%s, ф. %s, оп. %s, д. %s: ', @$cite);
                    }
                    elsif ( @$cite == 6 ) {
                        printf('%s, ф. %s, оп. %s, д. %s, лл. %s—%s: ', @$cite);
                    }
                    else {
                        die('Wrong data');
                    }

                    my @links = ref $link->[0] ? @$link : $link;
                    my $f = '';

                    foreach ( 0 .. $#links ) {
                        if ( !$f || $links[$_][0] ne $f ) {
                            printf('[%s[', $films->{$links[$_][0]} // '#' . $links[$_][0]);
                            $f = $links[$_][0];
                        }
                        else {
                            print('[[');
                        }
                        if (defined $links[$_][2]) {
                            printf('%d—%d', $links[$_][1] + 1, $links[$_][2] + 1);
                        }
                        else {
                            printf('%d', $links[$_][1] + 1);
                        }
                        printf(']](https://www.familysearch.org/search/film/%s?i=%d)', $links[$_][0], $links[$_][1]);
                    }
                    continue {
                        print(', ') if $_ < $#links;
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
