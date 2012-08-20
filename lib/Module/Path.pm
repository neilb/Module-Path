use strict;
use warnings;
package Module::Path;
# ABSTRACT: get the full path to a locally installed module

use parent 'Exporter';
our @EXPORT_OK = qw(module_path);

my $SEPARATOR  = '/';

BEGIN {
    if ($^O =~ /^(MSWin|dos|os2)/i) {
        $SEPARATOR = '\\';
    } elsif ($^O =~ /^MacOS/i) {
        $SEPARATOR = ':';
    }
}

sub module_path
{
    my $module = shift;
    my $relpath;
    my $fullpath;

    ($relpath = $module.'.pm') =~ s/::/$SEPARATOR/g;

    foreach my $dir (@INC) {
        next if ref($dir);
        $fullpath = $dir.$SEPARATOR.$relpath;
        return $fullpath if -f $fullpath;
    }

    return undef;
}

1;
