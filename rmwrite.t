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
use Test::More tests => 21; # last test to print

my @argv = qw( ./test ./test2 );

# Setup
BEGIN {
    my $fh;
    my $dir = './test';
    my $dir2 = './test2';
    mkpath $dir;
    chmod 0777, $dir;
    mkpath $dir2;
    chmod 0777, $dir2;
}

# Confirm Use
use_ok( 'Rmwrite' );
use_ok('Fcntl');
use_ok('Switch');
use_ok('Scalar::Util');

# Confirm Access
can_ok('Rmwrite', 'rm_write_other');
can_ok('Rmwrite', '_verbose');
can_ok('Rmwrite', '_perm_check');

# Start script
do "./rmwrite.pl $argv[0]";

# Test subroutines
is(Rmwrite::rm_write_other($argv[0], 0), undef, "Works with no verbosity.");
is(Rmwrite::rm_write_other($argv[1], 1), "Changed permissions on ./test2 0775\n", "Works with verbosity.");
is(Rmwrite::rm_write_other('./ttt', 1), "Invalid Path ./ttt\n", "Doesn't work with bad path verbose");
is(Rmwrite::rm_write_other($argv[0], 'x'), -1, "Doesn't work with bad verbosity - String");
is(Rmwrite::rm_write_other($argv[0], 3), -1, "Doesn't work with bad verbosity - Integer");

is(Rmwrite::_verbose(2, $argv[0], 666), "Permission Denied on $argv[0]\n", "Verbose prints");
is(Rmwrite::_verbose(3, $argv[1], 664), "Changed permissions on $argv[1] 0664\n", "Verbose prints");
is(Rmwrite::_verbose(4, $argv[0], 666), "No change on $argv[0] 1232\n", "Verbose prints");
is(Rmwrite::_verbose(5, $argv[1], 664), "Invalid Path $argv[1]\n", "Verbose prints");
is(Rmwrite::_verbose('Inf', 'ttt', 644), undef, "Verbose bad path:sting");

is(Rmwrite::_perm_check($argv[0]), 16893, "Permission Check Works, Correct Permissions");
is(Rmwrite::_perm_check('/var'), undef, "Permission Check Works, wrong permissions");
is(Rmwrite::_perm_check('./ttt'), -1, "Bad path - string");
is(Rmwrite::_perm_check(5), -1, "Bad path - int");

# Cleanup
END {
    my $dir = './test';
    my $dir2 = './test2';
    rmtree([$dir]) if -d $dir;
    rmtree([$dir2]) if -d $dir2;
}

