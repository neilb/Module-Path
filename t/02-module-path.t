#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 6;

use Module::Path 'module_path';
use Cwd qw/ abs_path /;
use File::Temp qw/ tempfile tempdir /;
use File::Spec;

my $expected_path;

# This test does "use strict", so %INC should include the path where
# strict.pm was found, and module_path should find the same
eval { $expected_path = abs_path($INC{'strict.pm'}); };
ok(!$@ && module_path('strict') eq $expected_path,
   "check 'strict' matches \%INC") || do {
    warn "\n",
         "    \%INC          : $INC{'strict.pm'}\n",
         "    expected path : $expected_path\n",
         "    module_path   : ", (module_path('strict') || 'undef'), "\n",
         ($@ ? "    \$\@            : $@\n" : ''),
         "    \$^O           : $^O\n";
};

eval { $expected_path = abs_path($INC{'Test/More.pm'}); };
ok(!$@ && module_path('Test/More.pm') eq $expected_path,
   "confirm that module_path() works with partial path used as key in \%INC") || do {
    warn "\n",
         "    \%INC          : $INC{'Test/More.pm'}\n",
         "    expected path : $expected_path\n",
         "    module_path   : ", (module_path('Test/More.pm') || 'undef'), "\n",
         ($@ ? "    \$\@            : $@\n" : ''),
         "    \$^O           : $^O\n";
};

# module_path() returns undef if module not found in @INC
ok(!defined(module_path('No::Such::Module')),
   "non-existent module should result in undef");

{
    my $temp_dir = tempdir( CLEANUP => 1 );
    my ( $fh, $filename ) = tempfile( DIR => $temp_dir, SUFFIX => '.pm' );
    my $module_name = ( File::Spec->splitpath($filename) )[-1];
    $module_name =~ s/\.pm$//;
    ok(
        module_path( $module_name, { dirs => [$temp_dir] } ) eq $filename,
        "check locally specified files can be found"
    );

    my $other_temp_dir = tempdir( CLEANUP => 1 );
    my ( $other_fh, $other_filename ) =
      tempfile( DIR => $other_temp_dir, SUFFIX => '.pm' );
    my $other_module_name = ( File::Spec->splitpath($other_filename) )[-1];
    $other_module_name =~ s/\.pm//;
    ok(
        module_path( $other_module_name,
            { dirs => [ $temp_dir, $other_temp_dir ] } ) eq
          $other_filename,
        "check locally specified files can be found in multiple paths"
    );

    ok( !defined( module_path( 'My::Module', { dirs => [] } ) ),
        "check empty local dirs list returns undef" );
}
