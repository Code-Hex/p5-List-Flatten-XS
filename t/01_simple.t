use strict;
use Test::More;

use List::Util;
use List::Flatten::XS 'flatten';

my $expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3];
my $pattern = +[
    [1, [2, 3, 4], [5, 6, 7, 8, 9, 1, 2, 3]],
    [[1, 2, 3], [4, 5, [6, 7, [8, 9, [1, 2, 3]]]]],
    [[[1, 2, 3], 4, 5], 6, 7, [8, [9, [1], 2], 3]],
    [1, [2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]]],
    [[[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2], 3],
];

for my $try (@$pattern) {
    my $got = flatten($try);
    is_deeply($got, $expected, 'Passed array ref, compare with arrayref');
}

done_testing;

