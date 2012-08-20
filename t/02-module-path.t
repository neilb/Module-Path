#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 2;

use Module::Path 'module_path';

# This test does "use strict", so %INC should include the path where
# strict.pm was found, and module_path should find the same
ok(module_path('strict') eq $INC{'strict.pm'});

# module_path() returns undef if module not found in @INC
ok(not defined module_path('No::Such::Module'));
