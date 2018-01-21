use strict;
use Test::More;

use List::Flatten::XS 'flatten';

my $pattern = +[
    [1, [2, 3, 4], [5, 6, 7, 8, 9, 1, 2, 3]],
    [[1, 2, 3], [4, 5, [6, 7, [8, 9, [1, 2, 3]]]]],
    [[[1, 2, 3], 4, 5], 6, 7, [8, [9, [1], 2], 3]],
    [1, [2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]]],
    [[[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2], 3],
];

my $expected_list = +[
    +{
        1 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1 => [1, 2, 3, 4, 5, [6, 7, [8, 9, [1, 2, 3]]]],
        2 => [1, 2, 3, 4, 5, 6, 7, [8, 9, [1, 2, 3]]],
        3 => [1, 2, 3, 4, 5, 6, 7, 8, 9, [1, 2, 3]],
        4 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1 => [[1, 2, 3], 4, 5, 6, 7, 8, [9, [1], 2], 3],
        2 => [1, 2, 3, 4, 5, 6, 7, 8, 9, [1], 2, 3],
        3 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1  => [1, 2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]],
        5  => [1, 2, 3, 4, 5, 6, [7, [8, [9, [1, [2, [3]]]]]]],
        9  => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, [2, [3]]],
        11 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    },
    +{
        1  => [[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2, 3],
        5  => [[[[[[[1], 2], 3], 4], 5], 6], 7, 8, 9, 1, 2, 3],
        9  => [[[1], 2], 3, 4, 5, 6, 7, 8, 9, 1, 2, 3],
        11 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
    }
];

for my $i (0 .. $#$pattern) {
    while (my ($level, $expected) = each %{$expected_list->[$i]}) {
        my $got = flatten($pattern->[$i], $level);
        is_deeply($got, $expected, 'Passed array ref, want scalar');
    }
    # wantarray
    while (my ($level, $expected) = each %{$expected_list->[$i]}) {
        my @got = flatten($pattern->[$i], $level);
        is_deeply(\@got, $expected, 'Passed array ref, want scalar');
    }
}

done_testing;

