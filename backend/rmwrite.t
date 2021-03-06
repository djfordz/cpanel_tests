#!/usr/bin/env perl 

#===============================================================================
#
#         FILE: rmwrite.t
#
#  DESCRIPTION: Test the rmwrite.pl script as well as lib/Rmwrite.pm module
#
#        FILES: rmwrite.t, rmwrite.pl, rmwrite.pm
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: David Ford (djfordz@gmail.com), 
# ORGANIZATION: Magemojo LLC
#      VERSION: 1.0
#      CREATED: 09/20/2017 05:58:45 PM
#     REVISION: 1
#===============================================================================

use diagnostics;
use strict;
use warnings;

use lib './lib';
use Rmwrite;
use File::Path qw(rmtree mkpath);
use Test::More tests => 23; # last test to print

my @argv = qw( ./test ./test2 );

# Setup
BEGIN {
    my $dir = './test';
    my $dir2 = './test2';

    mkpath $dir;
    mkpath $dir2;

    chmod 0777, $dir;
    chmod 0777, $dir2;
    
}

# Confirm Use
use_ok( 'Rmwrite' );
use_ok('Fcntl');
use_ok('Scalar::Util');

# Confirm Access
can_ok('Rmwrite', 'rm_write_other');
can_ok('Rmwrite', '_rm_write');
can_ok('Rmwrite', '_perm_check');
can_ok('Rmwrite', '_verbose');



# Test subroutines
is(Rmwrite::rm_write_other($argv[0], 0), undef, "Works with no verbosity.");
is(Rmwrite::rm_write_other($argv[1], 1), undef, "Works with verbosity.");
is(Rmwrite::rm_write_other('./ttt', 1), "Unspecified Error. No such file or directory", "Doesn't work with bad path verbose");
is(Rmwrite::rm_write_other($argv[0], 'x'), -1, "Doesn't work with bad verbosity - String");
is(Rmwrite::rm_write_other($argv[0], 3), -1, "Doesn't work with bad verbosity - Integer");

is(Rmwrite::_rm_write($argv[1], 1), "No change on ./test2 0775\n", "Works with verbosity");
is(Rmwrite::_rm_write($argv[0], 0), undef, "Works with no verbosity");

is(Rmwrite::_verbose(2, $argv[0], 666), "Permission Denied on ./test\n", "Verbose prints");
is(Rmwrite::_verbose(3, $argv[1], 664), "Changed permissions on ./test2 0664\n", "Verbose prints");
is(Rmwrite::_verbose(4, $argv[0], 666), "No change on ./test 1232\n", "Verbose prints");
is(Rmwrite::_verbose(5, $argv[1], 664), "Invalid Path ./test2\n", "Verbose prints");
is(Rmwrite::_verbose('Inf', 'ttt', 644), undef, "Verbose bad path:string");

is(Rmwrite::_perm_check($argv[0]), 16893, "Permission Check Works, Correct Permissions");
is(Rmwrite::_perm_check('/var'), -1, "Permission Check Works, wrong permissions");
is(Rmwrite::_perm_check('./ttt'), -1, "Bad path - string");
is(Rmwrite::_perm_check(5), -1, "Bad path - int");

## test scripts
do "./rmwrite.pl $argv[0]";
do "./rmwrite_euid.pl $argv[1]";

# Cleanup
END {
    my $dir = './test';
    my $dir2 = './test2';

    rmtree([$dir]) if -d $dir;
    rmtree([$dir2]) if -d $dir2;
}

