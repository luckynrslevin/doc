#!/bin/sh
#############################################################################
# Build script for libconfig on TCL                                         #
#                                                                           #
# Howto create a tinycore extension                                         #
# see: https://forum.tinycorelinux.net/index.php/topic,18682.0.html         #
# and https://wiki.tinycorelinux.net/doku.php?id=wiki:creating_extensions   #
# and http://www.tinycorelinux.net/14.x/armv7/tcz/src/                      #
#                                                                           #                                    #
#############################################################################

#############################################################################
# Configure extension creation parameters                                   #
#############################################################################
GITNAM=https://github.com/hyperrealm/libconfig.git
SRC=https://github.com/hyperrealm/libconfig/archive/refs/tags/v1.7.3.tar.gz
RELEASE=v1.7.3
EXTNAME=libconfig
INITSCTNAM=
WORKDIR=libconfig
TMPDIR=/tmp/$WORKDIR
TODAY=`date -I`
LICENSE=https://raw.githubusercontent.com/hyperrealm/libconfig/refs/heads/master/LICENSE

#############################################################################
# Main                                                                      #
#############################################################################
main () {
  instprereq
  cleanupOld
  buildInst
  createLicenseFile
  prepPackaging
  packageExt
  packageInfo
}

#############################################################################
# Functions                                                                 #
#############################################################################

#############################################################################
# Check/Install prerequisites                                               #
#############################################################################
instprereq () {
  # Install build prerequisites
  tce-load -wi git.tcz automake.tcz autoconf.tcz compiletc.tcz vim.tcz \
    squashfs-tools.tcz libtool.tcz texinfo.tcz
}

#############################################################################
# Cleanup old build artifacts                                               #
#############################################################################
cleanupOld () {
  test -d $WORKDIR && rm -rf $WORKDIR
  test -d $TMPDIR && rm -rf $TMPDIR
}

#############################################################################
# Build and install to TMPDIR                                               #
#############################################################################
buildInst () {
  git clone $GITNAM --branch $RELEASE --single-branch && \
  cd $WORKDIR && \
  autoreconf -fi && \
    ./configure --prefix=/usr/local --sysconfdir=/usr/local/etc && \
  make && \
  mkdir -p $TMPDIR && \
  make install DESTDIR=$TMPDIR
}

#############################################################################
# Create license / copyright note                                           #
#############################################################################
createLicenseFile() {
  mkdir -p $TMPDIR/usr/local/share/doc/$EXTNAME-$RELEASE && \
  wget -P $TMPDIR/usr/local/share/doc/$EXTNAME-$RELEASE $LICENSE
}

#############################################################################
# Final prep own, mod, debug info before packaing                           #
#############################################################################
prepPackaging () {
  # Shared object lib files (end in .so or .so*) are classified as executables
  # Static object lib files (end in .a or .la) are classified as normal files,
  # and so
  # mod 644 for all files, 755 for executables & shared libs,
  # 755 for directories
  find $TMPDIR -type d -print0 | sudo xargs -0 chmod 755
  find $TMPDIR | xargs file | grep "executable" | grep ELF | awk -F  ':' '/1/ {print $1}' | sudo xargs chmod 755
  # strip debug information
  find $TMPDIR | xargs file | grep "executable" | grep ELF | grep "not stripped" \
    | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || find . | \
    xargs file | grep "shared object" | grep ELF | grep "not stripped" | \
    cut -f 1 -d : | xargs strip -g 2> /dev/null
  # set mod for all files
  find $TMPDIR -type f -print0 | sudo xargs -0 chmod 644
  # set mod for shared libs
  find $TMPDIR/usr/local/lib  -type f -name "*.so*" | xargs chmod 755
}

#############################################################################
# Package extension                                                         #
#############################################################################
packageExt () {
  cd /tmp && \
  mksquashfs $WORKDIR $EXTNAME.tcz && \
  md5sum $EXTNAME.tcz > $TMPDIR/$EXTNAME.tcz.md5.txt && \
  mv $EXTNAME.tcz $WORKDIR

  cd $TMPDIR && \
  find usr -not -type d > $EXTNAME.tcz.list && \
  sed 's|usr|/usr|g' -i $EXTNAME.tcz.list
}


#############################################################################
# Package info                                                         #
#############################################################################
packageInfo () {

  cat > $TMPDIR/$EXTNAME.tcz.info << EOF
Title:          $EXTNAME.tcz
Description:    Libconfig is a simple library for processing structured
                configuration files
Version:        $RELEASE
Author:         hyperrealm
Original-site:  https://hyperrealm.github.io/libconfig/
Copying-policy: accompanied
Size:           636 kB
Extension_by:   luckynrslevin
Tags:           lib config
Comments:       Libconfig is a simple library for processing structured
                configuration files, like this one. This file format is
                more compact and more readable than XML. And unlike XML,
                it is type-aware, so it is not necessary to do string
                parsing in application code.
                
                Libconfig is very compact – a fraction of the size of the
                expat XML parser library. This makes it well-suited for
                memory-constrained systems like handheld devices.
                
                The library includes bindings for both the C and C++
                languages. It works on POSIX-compliant UNIX and UNIX-like
                systems (GNU/Linux, Mac OS X, FreeBSD), Android, and
                Windows (2000, XP and later).    
 
Change-log:     
Current:        $TODAY v $RELEASE for TC 14.x
EOF

}

# Call "main" with the arguments given to the script
# (even if the function may not use them).
main "$@"
