use strict;
use warnings;
package Module::Path;
# ABSTRACT: get the full path to a locally installed module

require Exporter;

our @ISA       = qw(Exporter);
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

        # see perldoc -f require on why you might find
        # a reference in @INC
        next if ref($dir);

        $fullpath = $dir.$SEPARATOR.$relpath;
        return $fullpath if -f $fullpath;

    }

    return undef;
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

Module::Path provides a single function, C<module_path()>,
which will find where a module is installed locally.

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

If no file was found, return C<undef>.

=back

=head1 BUGS

Obviously this only works where the module you're after has its own C<.pm>
file. If a <.pm> file defines multiple packages, this won't work.

This also won't find any modules that are being loaded in some special
way, for example using a code reference in C<@INC>, as described
in L<"perlfunc"/"require">.

=head1 SEE ALSO

There are a number of other modules on CPAN which provide the
same or similar functionality. But many of them provide a lot of
other things, and/or they have a number of non-core dependencies.
Or they're not as robust. The following is a list of the ones
I'm currently aware of.

L<Module::Filename>, L<Module::Overview>, L<Module::Data>, L<Module::Finder>,
L<Module::Info>, L<Module::InstalledVersion>, L<Module::Locate>.

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

