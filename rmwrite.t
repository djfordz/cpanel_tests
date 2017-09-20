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

use File::Path              qw(rmtree mkpath);
use Test::More              tests => 1;                      # last test to print

my $dir = './test';
mkpath($dir);

foreach my $i (0 .. 50) {
    open my $fh, ">>", "$dir/test$i.txt" or die "Can't open $dir/test$i.txt\n";
    chmod(666, $fh);
    close $fh;
}

do "./rmwrite.pl $dir";

# Do tests

rmtree([$dir]) if -d $dir;



