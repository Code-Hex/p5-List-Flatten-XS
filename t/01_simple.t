use strict;
use Test::More;

use List::Util;
use List::Flatten::XS;

my $expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3];
my $pattern = +[
    [1, [2, 3, 4], [5, 6, 7, 8, 9, 1, 2, 3]],
    [[1, 2, 3], [4, 5, [6, 7, [8, 9, [1, 2, 3]]]]],
    [[[1, 2, 3], 4, 5], 6, 7, [8, [9, [1], 2], 3]],
    [1, [2, [3, [4, [5, [6, [7, [8, [9, [1, [2, [3]]]]]]]]]]]],
    [[[[[[[[[[[[1], 2], 3], 4], 5], 6], 7], 8], 9], 1], 2], 3],
];

for my $try (@$pattern) {
    is_deeply($expected, List::Flatten::XS::flatten($try));
}

done_testing;

