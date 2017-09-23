#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: rmwrite_euid.pl
#
#        USAGE: ./rmwrite_euid.pl  
#
#  DESCRIPTION: Removes write permissions on files and directories recursively with effictive user id option.
#
#      OPTIONS: --verbose, --help, --euid
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: David Ford (djfordz@gmail.com), 
# ORGANIZATION: Magemojo LLC
#      VERSION: 1.0
#      CREATED: 09/20/2017 11:56:51 PM
#     REVISION: 1
#===============================================================================

use strict;
use warnings;
use utf8;

use lib './lib';
use Rmwrite         ();
use Getopt::Long    qw( GetOptions );

my %opt;
my $verbose_flag;
my $path;
my $val;
my $whoami;

sub help {
print <<EOF;
    Usage: $0 <options> path/to/dir [ path/to/dir2 ] [ path/to/dir3 ] ...
    (e.g. $0 /path/to/directory /path/to/directory2 --verbose --euid 1000)

    Options:
    --verbose|-v Output to stdout
    --help|-h    Print this message
    --euig|-e    Change Effective User ID (must be run as root)

EOF
    exit 1;
}

sub execute {
    my ( $path, $flag ) = @_;

    Rmwrite::rm_write_other($path, $flag);

    return;
}

sub check {
    my ( $arg ) = @_;

    if ( ! -e $arg || ! -d $arg ) {
        print "Invalid Arguments! $0 --help for usage.\n";
        exit 1; 
    }

    return;
}

GetOptions(\%opt, "v|verbose!", "h|help!", "e|euid:o");

help() if $opt{h} or (scalar @ARGV == 0);

map { check($_) } @ARGV;

$verbose_flag = $opt{v} ? 1 : 0;

$> = $opt{e} or die "Could not change permission of user." if $opt{e};

chomp($whoami = `whoami`);

die "User does not exist" unless $whoami;

map { execute( $_, $verbose_flag ) } @ARGV;

__END__
