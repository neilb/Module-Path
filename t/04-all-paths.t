#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 3;

use Module::Path 'all_module_paths';
use Test::TempDir::Tiny;

my $inc_1 = tempdir("inc");
my $inc_2 = tempdir("inc");

sub spew {
  my ( $path, $content ) = @_;
  open my $fh, '>', $path or die "Can't open $path for writing";
  $fh->print($content);
  close $fh or warn "Error closing $path, file may be corrupt";
}

mkdir("$inc_1/Fake");
mkdir("$inc_2/Fake");
spew("$inc_1/Fake/A.pm", "File A");
spew("$inc_2/Fake/A.pm", "Shadowed A");
spew("$inc_1/Fake/B.pm", "File B");
spew("$inc_2/Fake/C.pm", "Shadow-Only File C");

local @INC = ( $inc_1, $inc_2 );

cmp_ok( scalar all_module_paths("Fake::A"), '==', 2 , '2 Files called Fake::A' );
cmp_ok( scalar all_module_paths("Fake::B"), '==', 1 , '1 Files called Fake::B' );
cmp_ok( scalar all_module_paths("Fake::C"), '==', 1 , '1 Files called Fake::C' );
