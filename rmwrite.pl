#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: Removes write permissions on files and directories recursively. 
#
#      OPTIONS: --verbose, --help
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: David Ford (djfordz@gmail.com), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 09/19/2017 08:21:49 AM
#     REVISION: ---
#===============================================================================


use warnings;
use utf8;

use lib './lib';
use Rmwrite         ();
use Getopt::Long    qw( GetOptions );
use Cwd             qw( realpath );

my %opt;
my $verbose_flag = 0;
my $path;
my $val;

sub help {
print <<EOF;
    Usage: $0 <options> path/to/dir [ path/to/dir2 ] [ path/to/dir3 ] ...
    (e.g. $0 /path/to/directory /path/to/directory2 --verbose)

    Options:
    --verbose|-v Output to stdout
    --help|-h    Print this message

EOF
    exit 1;
}

sub execute {
    my ( $path, $flag ) = @_;

    Rmwrite::recurse_rm_write_other($path, $flag);

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

GetOptions(\%opt, "v|verbose!", "h|help!");

help() if $opt{h} or (scalar @ARGV == 0);

map { check($_) } @ARGV;

($verbose_flag = 1) if $opt{v};

map { execute( $_, $verbose_flag ) } @ARGV;

1;
