package Rmwrite;
#
#===============================================================================
#
#         FILE: Rmwrite.pm
#
#  DESCRIPTION: Removes write permissions of other.
#
#        FILES: Rmwrite
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: David Ford (djfordz@gmail.com), 
# ORGANIZATION: Magemojo LLC
#      VERSION: 1.0
#      CREATED: 09/20/2017 06:29:05 PM
#     REVISION: 1
#===============================================================================


use warnings;
use strict;
no strict 'subs';

our $VERSION = '1.0';

use Fcntl                   ':mode';
use File::stat              ();
use File::Find              ();

my @content;

sub recurse_rm_write_other {
    my ( $path, $verbose ) = @_;
    my $mode;
    my $ow;
    my $fperms;

    File::Find::find( \&_wanted, $path );

    foreach ( @content ) {
        $mode = _perm_check($_);

        if ( $mode ) {
            $ow = $mode & S_IWOTH; 

            if ( $ow ==  0002 ) {
                $fperms = sprintf( "%04o", S_IMODE($mode) ^ S_IWOTH );
                chmod oct($fperms), $_;
                _verbose(3, $_, $fperms) if $verbose; 
            } else {
                _verbose(4, $_, $mode) if $verbose;
            }
        } else {
            _verbose(2, $_, $mode) if $verbose;
        }
    }

    return;
}

sub _perm_check {
    my $path = shift;
    my @sb;
    my @user;
    my $mode;
    my $uid;
    my $gid;
    my $fuid;
    my $fgid;

    @sb = stat($path);
    @user = getpwuid($>);
    $uid = $user[2];
    $gid = $user[3];
    $mode = $sb[2];
    $fuid = $sb[4];
    $fgid = $sb[5];

    return $mode if $uid == 0 || $uid == $fuid || $gid == $fgid;
    
    return;
}

sub _verbose {
    my ( $val, $path, $mode ) = @_;

    printf("Permission Denied on %s\n", $path) if $val == 2;
    printf("Changed permissions on %s %04o\n", $path, oct($mode)) if $val == 3;
    printf("No change on %s %04o\n", $path, S_IMODE($mode)) if $val == 4;
}

sub _wanted {
    push @content, $File::Find::name;
    return;
}

1;
