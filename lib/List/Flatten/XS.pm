package List::Flatten::XS;
use strict;
use warnings;

our $VERSION = '0.01';

use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/flatten/;

1;
__END__

=encoding utf-8

=head1 NAME

List::Flatten::XS - It's new $module

=head1 SYNOPSIS

    use List::Flatten::XS;

=head1 DESCRIPTION

List::Flatten::XS is ...

=head1 LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

K E<lt>x00.x7f@gmail.comE<gt>

=cut

