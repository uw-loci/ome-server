# -*- perl -*-

# t/009_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OME::Factory' ); }

my $object = OME::Factory->new ();
isa_ok ($object, 'OME::Factory');


