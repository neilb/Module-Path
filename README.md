# Module::Path

Get the full path to a locally installed module.

## Usage

The command line program `mpath` can be used to search for modules, for
example, to look for a single module:

    mpath Module::Path

Multiple modules can also be specified:

    mpath Module::Path Moose

If a module can't be found, an error message is printed

    mpath Foo::Bar
    Foo::Bar not found

This error output can be suppressed via the `--quiet` option.

Alternatively, one can use the programmatic interface to `Module::Path`
directly:

    use Module::Path 'module_path';

    my $path = module_path('Test::More');
    if (defined($path)) {
      print "Test::More found at $path\n";
    } else {
      print "Danger Will Robinson!\n";
    }

## Installation

### CPAN

The easiest way to install the module is to simply use `cpanm`:

    cpanm Module::Path

### GitHub

If you're feeling adventurous and want the lastest and greatest code, you
can check out the repository from GitHub and build and install from source.

First clone the repository,

    git clone https://github.com/neilb/Module-Path.git
    cd Module-Path

then install the dependencies,

    cpanm -n -q --skip-satisfied --installdeps .

make sure things are working properly,

    dzil test

and if everything went well, install locally

    dzil install

## Author and Copyright

This software is copyright (c) 2015 by Neil Bowers.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
