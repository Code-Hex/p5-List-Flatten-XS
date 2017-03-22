use strict;
use Test::More;

use List::Flatten::XS;
use Data::Dumper;
my @a = List::Flatten::XS::flatten( [[1,2,3],[4,5,[6,7,[8,9,[1,2,3]]]]] );
warn Dumper @a;
is(1, 1);

done_testing;

