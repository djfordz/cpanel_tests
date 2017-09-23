#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: testcore.pl
#
#        USAGE: ./testcore.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 09/21/2017 01:28:49 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use strict;
use warnings;
use Module::CoreList;

my @mod = qw(Fcntl Switch Scalar::Util File::Find Getopt::Long File::Path Test::More);
#my $mod = 'XML::Twig';
foreach (@mod) {
    my @ms = Module::CoreList->find_modules(qr/^$_$/);
    if (@ms) {
        print "$_ in core\n";
    }
    else {
        print "$_ not in core\n";
    }
}


__END__
