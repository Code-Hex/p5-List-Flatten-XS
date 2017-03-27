use Test::More;
use Test::LeakTrace;
use List::Flatten::XS 'flatten';

my $pattern = +[
    [1,2,3],
];

for my $try (@$pattern) {
    no_leaks_ok {
        flatten($try);
    } 'Detected memory leak via flatten()';
}

done_testing;