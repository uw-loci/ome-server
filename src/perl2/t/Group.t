# -*- perl -*-

# t/012_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OME::Group' ); }

my $object = OME::Group->new ();
isa_ok ($object, 'OME::Group');


