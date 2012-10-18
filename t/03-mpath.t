#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 2;
use FindBin 0.05;
use File::Spec::Functions;
use Devel::FindPerl qw(find_perl_interpreter);

my $PERL  = find_perl_interpreter() || die "can't find perl!\n";
my $MPATH = catfile( $FindBin::Bin, updir(), qw(bin mpath) );
my $path;

#
# The mpath script's hashbang line is:
#
#   #!/usr/bin/env perl
#
# This can result in it being run with a different perl than being used to run
# this test. So the path to strict may be different. So we use $^X to run
# mpath with the same perl binary being used to run this test.
# Instead of explicitly using $^X, we use Devel::FindPerl to get the
# path to perl
#
chomp($path = `"$PERL" "$MPATH" strict 2>&1`);

# This test does "use strict", so %INC should include the path where
# strict.pm was found, and module_path should find the same
ok($? == 0 && defined($path) && $path eq $INC{'strict.pm'},
   "check 'mpath strict' matches \%INC") || do {
    warn "\n",
         "    \%INC        : $INC{'strict.pm'}\n",
         "    module_path : $path\n",
         "    \$^O         : $^O\n";
};

# module_path() returns undef if module not found in @INC
chomp($path = `"$PERL" "$MPATH" No::Such::Module 2>&1`);
ok($? != 0 && defined($path) && $path eq 'No::Such::Module not found',
   "non-existent module should result in failure");
