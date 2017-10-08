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

use Fcntl          ':mode';
use Switch;
use Scalar::Util    ();
use File::Find      ();

# Removes write permissions for other.
sub rm_write_other {
    my ( $path, $verbose ) = @_;
    my $mode;
    my $fperms;
    my $other_write;
    my $file;
    my $dh;
    my $pwd;

    return -1 unless Scalar::Util::looks_like_number($verbose);
    return -1 unless ($verbose == 1 || $verbose == 0) && (-d $path || -e $path); 

    opendir($dh, $path) or die "Can't opendir $path: $!";

    while( readdir($dh) ) {
        $pwd = $path . '/' . $_;
        $mode = _perm_check($pwd);

        return print "No Mode\n" unless $mode;

        $other_write = $mode & S_IWOTH;

        switch ( $mode ) {
            case -1             { print _verbose(5, $pwd, $mode) if $verbose }
            case /^[^\-1]?\d+/  { $fperms = sprintf( "%04o", S_IMODE($mode) ^ S_IWOTH ) if $other_write == 0002;
                                  chmod oct($fperms), $pwd if $other_write == 0002;
                                  print _verbose(3, $pwd, $fperms) if $verbose && $other_write == 0002; 
                                  print _verbose(4, $pwd, $mode) if $verbose && $other_write != 0002; }
            else                { print _verbose(2, $pwd, $mode) if $verbose }
        }

        rm_write_other($pwd, $verbose) if ( -d $pwd && $_ ne '..' && $_ ne '.' );
    }

    closedir($dh);

    return;
}

# Checks to ensure process can change file permissions
sub _perm_check {
    my $path = shift;
    my @sb;
    my @user;
    my $mode;
    my $uid;
    my $gid;
    my $fuid;
    my $fgid;

    return -1 unless  -d $path || -e $path;
    
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

# Adds output to stdout
sub _verbose {
    my ( $val, $path, $mode ) = @_;

    return sprintf("Permission Denied on %s\n", $path) if $val == 2;
    return sprintf("Changed permissions on %s %04o\n", $path, oct($mode)) if $val == 3;
    return sprintf("No change on %s %04o\n", $path, S_IMODE($mode)) if $val == 4;
    return sprintf("Invalid Path %s\n", $path) if $val == 5;
    return;
}

1;
