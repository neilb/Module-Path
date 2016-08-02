package Module::Path;
# ABSTRACT: get the full path to a locally installed module

use 5.006;
use strict;
use warnings;
use File::Basename 'dirname';
use Cwd qw/ abs_path /;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(module_path all_module_paths);

my $SEPARATOR;

BEGIN {
    if ($^O =~ /^(dos|os2)/i) {
        $SEPARATOR = '\\';
    } elsif ($^O =~ /^MacOS/i) {
        $SEPARATOR = ':';
    } else {
        $SEPARATOR = '/';
    }
}

sub module_path
{
    my $module  = shift;
    my $opts    = shift;
    $opts       = {} unless defined $opts;
    my $relpath = _rel_path($module);

    foreach my $dir (@INC) {
        next unless my $abs_dir = _usable_inc($dir);
        my $fullpath = $abs_dir.$SEPARATOR.$relpath;
        return $fullpath if -f $fullpath;
    }

    return undef;
}

sub all_module_paths
{
    my $module  = shift;
    my $opts    = shift;
    $opts       = {} unless defined $opts;
    my $relpath = _rel_path($module);

    my @dirs;
    foreach my $dir (@INC) {
        next unless my $abs_dir = _usable_inc($dir);
        my $fullpath = $abs_dir.$SEPARATOR.$relpath;
        push @dirs, $fullpath if -f $fullpath;
    }

    return @dirs;
}

# _rel_path( $module )
# return $module in relative path format.
sub _rel_path {
    my $module = shift;
    my $relpath;

    ($relpath = $module) =~ s/::/$SEPARATOR/g;
    $relpath .= '.pm' unless $relpath =~ m!\.pm$!;
    return $relpath;
}

# _usable_inc( $dir )
# returns $dir into a usable path if possible.
# if not, returns undef.
sub _usable_inc {
    my $dir = shift;
    return if not defined $dir;

    # see 'perldoc -f require' on why you might find
    # a reference in @INC
    return if ref($dir);

    return unless -d $dir && -x $dir;

    # The directory path might have a symlink somewhere in it,
    # so we get an absolute path (ie resolve any symlinks).
    # The previous attempt at this only dealt with the case
    # where the final directory in the path was a symlink,
    # now we're trying to deal with symlinks anywhere in the path.
    my $abs_dir = $dir;
    eval { $abs_dir = abs_path($abs_dir); };
    return if $@ || !defined($abs_dir);

    return $abs_dir;
}
1;

=head1 NAME

Module::Path - get the full path to a locally installed module

=head1 SYNOPSIS

 use Module::Path 'module_path';

 $path = module_path('Test::More');
 if (defined($path)) {
   print "Test::More found at $path\n";
 } else {
   print "Danger Will Robinson!\n";
 }

=head1 DESCRIPTION

This module provides two functions, C<module_path()> and C<all_module_paths()>,
both of which take a module name and finds respective directories in your
C<@INC> path to where the module is installed locally.

Both return full paths to matching files, resolving any symlinks.

This module is portable and only depends on core modules.

The distribution for C<Module::Path> also includes the C<mpath>
script, which lets you get the path for a module from the command-line:

 % mpath Module::Path

=head1 EXPORTS

=head2 C<module_path>

  my $value = module_path( $module_name );
  my $value = module_path( $module_name, \%OPTS ); # Since 0.20

This exportable function will return paths to the first such module found in
your C<@INC>, or return C<undef> if no matching path is found.

=head2 C<all_module_paths>

  my @list = all_module_paths( $module_name );
  my @list = all_module_paths( $module_name, \%OPTS );

B<Since 0.20>, this exportable function is available on request, which will
return all matching paths instead of simply the first, or returning an empty
list if no matching paths are found.

  use Module::Path qw(all_module_paths);

  for my $path (all_module_paths(qw( ExtUtils::MakeMaker ))) {
    print $path;
  }

=head1 MECHANICS

It works by looking in all the directories in C<@INC>
for an appropriately named file:

=over 4

=item

Foo::Bar becomes C<Foo/Bar.pm>, using the correct directory path
separator for your operating system.

=item

Iterate over C<@INC>, ignoring any references
(see L<"perlfunc"/"require"> if you're surprised to hear
that you might find references in C<@INC>).

=item

For each directory in C<@INC>, append the partial path (C<Foo/Bar.pm>),
again using the correct directory path separator.
If the resulting file exists, return this path.

=item

If a directory in C<@INC> is a symlink, then we resolve the path,
and return a path containing the linked-to directory.

=item

If no file was found, return C<undef>.

=back

I wrote this module because I couldn't find an alternative
which dealt with the points listed above, and didn't pull in
what seemed like too many dependencies to me.

The C<module_path()> function will also cope if the module name includes C<.pm>;
this means you can pass a partial path, such as used as the keys in C<%INC>:

  module_path('Test/More.pm') eq $INC{'Test/More.pm'}

The above is the basis for one of the tests.

=head1 BUGS

Obviously this only works where the module you're after has its own C<.pm>
file. If a file defines multiple packages, this won't work.

This also won't find any modules that are being loaded in some special
way, for example using a code reference in C<@INC>, as described
in L<"perlfunc"/"require">.


=head1 SEE ALSO

There are a number of other modules on CPAN which provide the
same or similar functionality:
L<App::whichpm>,
L<Class::Inspector>,
L<Module::Data>,
L<Module::Filename>,
L<Module::Finder>,
L<Module::Info>,
L<Module::Locate>,
L<Module::Mapper>,
L<Module::Metadata>,
L<Module::Runtime>,
L<Module::Util>,
and L<Path::ScanINC>.

I've written a review of all such modules that I'm aware of:

=over 4

L<http://neilb.org/reviews/module-path.html>

=back

Module::Path was written to be fast, portable, and have a low number of
core-only runtime dependencies. It you only want to look up the path to
a module, it's a good choice.

If you want more information, such as the module's version, what functions
are provided, etc, then start by looking at L<Module::Info>,
L<Module::Metadata>, and L<Class::Inspector>.

The following scripts can also give you the path:
L<perldoc>,
L<whichpm|https://www.metacpan.org/module/whichpm>.


=head1 REPOSITORY

L<https://github.com/neilbowers/Module-Path>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

