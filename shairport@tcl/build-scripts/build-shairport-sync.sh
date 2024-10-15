#!/bin/sh
#############################################################################
# Build script for ShairPort-Sync                                           #
#                                                                           #
# Howto create a tinycore extension                                         #
# see: https://forum.tinycorelinux.net/index.php/topic,18682.0.html         #
# and https://wiki.tinycorelinux.net/doku.php?id=wiki:creating_extensions   #
# and http://www.tinycorelinux.net/14.x/armv7/tcz/src/                      #
#                                                                           #
# DNS workaround pi hole                                                    #
## sudo sed -i 's/246/1/' /etc/resolv.conf                                  #
## sudo set date -s "YYYY.MM.DD-hh:mm"                                      #
#############################################################################

#############################################################################
# Configure extension creation parameters                                   #
#############################################################################
GITNAM=https://github.com/mikebrady/shairport-sync.git
SRC=https://github.com/mikebrady/shairport-sync/archive/refs/tags/4.3.4.tar.gz
RELEASE=4.3.4
WORKDIR=shairport-sync
EXTNAME=shairport-sync
INITSCTNAM=shairport
TMPDIR=/tmp/$WORKDIR
TODAY=`date -I`
LICENSE=https://raw.githubusercontent.com/mikebrady/shairport-sync/refs/heads/master/LICENSES

#############################################################################
# Main                                                                      #
#############################################################################
main () {
    instprereq
    cleanupOld
    buildInst
    createPackageFile
    createInitFile
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
  tce-load -wi git.tcz automake.tcz autoconf.tcz pkg-config.tcz popt-dev.tcz \
    openssl-dev.tcz alsa.tcz alsa-utils.tcz compiletc.tcz squashfs-tools.tcz \
    vim.tcz libtool.tcz avahi.tcz libasound-dev.tcz avahi-dev.tcz
  # install pkgconfig
  wget http://homer:8000/14.0/armv6/tcz/libconfig.tcz && \
  tce-load -i libconfig.tcz
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
    ./configure --prefix=/usr/local --sysconfdir=/usr/local/etc --with-alsa \
    --with-avahi --with-ssl=openssl && \
  make && \
  mkdir -p $TMPDIR && \
  make install DESTDIR=$TMPDIR
}

#############################################################################
# Create package file                                                       #
#############################################################################
createPackageFile () {
  # create package file in tce.installed
  mkdir -p $TMPDIR/usr/local/tce.installed && \
  sudo chown -R root:staff $TMPDIR/usr/local/tce.installed && \
  sudo chmod -R 775 $TMPDIR/usr/local/tce.installed

  cat  > $TMPDIR/usr/local/tce.installed/$EXTNAME<< EOF
#!/bin/sh

# Create config from sample, if it does not already exist
cd /usr/local/etc/ && [[ ! -e shairport-sync.conf ]] && cp -p shairport-sync.conf.sample shairport-sync.conf

# Start shairport-sync
/usr/local/etc/init.d/shairport start &
EOF
}

#############################################################################
# Create startscript file                                                       #
#############################################################################
createInitFile () {
  mkdir -p $TMPDIR/usr/local/etc/init.d && \
  cat > $TMPDIR/usr/local/etc/init.d/shairport<< EOF
#!/bin/sh
# shairport-sync start/stop script

# must be executed as root?
#[ $(id -u) = 0 ] || { echo "must be root" ; exit 1; }


start() {
    pidof avahi-daemon >/dev/null || /usr/local/etc/init.d/avahi start
    if pidof shairport-sync >/dev/null; then
        echo -e "\nshairport-sync already running.\n"
    else
        echo -e "\nstarting shairport-sync.\n"
        env LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/shairport-sync &
    fi
}

stop() {
    if pidof shairport-sync >/dev/null; then
        /usr/bin/killall shairport-sync
    else
        echo -e "\nshairport-sync is not running.\n"
    fi
}

status() {
    if pidof shairport-sync >/dev/null; then
        echo -e "\nshairport-sync is running.\n"
        exit 0
    else
        echo -e "\nshairport-sync is not running.\n"
        exit 1
    fi
}

case \$1 in
    start) start
        ;;
    stop) stop
        ;;
    status) status
        ;;
    restart) stop; start
        ;;
    *) echo -e "\n$0 [start|stop|restart|status]\n"
        ;;
esac
EOF
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
  # All files root:root, 644 for files, 755 for executables, 755 for directories
  find $TMPDIR -type d -print0 | sudo xargs -0 chmod 755
  find $TMPDIR | xargs file | grep "executable" | grep ELF | awk -F  ':' '/1/ {print $1}' | sudo xargs chmod 755
  # strip debug information
  find $TMPDIR | xargs file | grep "executable" | grep ELF | grep "not stripped" \
    | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || find . | \
    xargs file | grep "shared object" | grep ELF | grep "not stripped" | \
    cut -f 1 -d : | xargs strip -g 2> /dev/null
  
  find $TMPDIR -type f -print0 | sudo xargs -0 chmod 644

  test -d $TMPDIR/usr/local/tce.installed && \
    sudo chown -R root:staff $TMPDIR/usr/local/tce.installed && \
    sudo chmod -R 775 $TMPDIR/usr/local/tce.installed

  test -f $TMPDIR/usr/local/bin/$EXTNAME && \
    chmod 755 $TMPDIR/usr/local/bin/$EXTNAME && \
  test -f $TMPDIR/usr/local/etc/init.d/$INITSCTNAM && \
    chmod 755 $TMPDIR/usr/local/etc/init.d/$INITSCTNAM
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
  sed 's|usr|/usr|g' -i $EXTNAME.tcz.list && \
  cat  > $TMPDIR/$EXTNAME.tcz.dep<< EOF
openssl.tcz
alsa.tcz
alsa-utils.tcz
avahi.tcz
EOF

# do we maybe also need following packages to run shairport-sync:
#libconfig.tcz
#openssl-dev.tcz
#libasound-dev.tcz
#avahi-dev.tcz

}


#############################################################################
# Package info                                                         #
#############################################################################
packageInfo () {

  cat > $TMPDIR/$EXTNAME.tcz.info << EOF
Title:          $EXTNAME.tcz
Description:    AirPlay audio player
Version:        $RELEASE
Author:         Mike Brady
Original-site:  https://github.com/mikebrady/shairport-sync
Copying-policy: accompanied
Size:           136 kB
Extension_by:   diese
Tags:           audio airplay shairport
Comments:       Shairport Sync is an AirPlay audio player for Linux,
                FreeBSD and OpenBSD. It plays audio streamed from Apple devices
                and from AirPlay sources such as OwnTone (formerly forked-daapd).
                
                Shairport Sync can be built as an AirPlay 2 player
                (with some limitations) or as "classic" Shairport Sync – 
                a player for the older, but still supported, AirPlay
                (aka "AirPlay 1") protocol.
                
                Metadata such as artist information and cover art can be
                requested and provided to other applications. Shairport Sync
                can interface with other applications through MQTT, an
                MPRIS-like interface and D-Bus.
                
                Shairport Sync does not support AirPlay video or photo streaming.    
 
Change-log:     
Current:        $TODAY v $RELEASE for TC 14.x
EOF
}

# Call "main" with the arguments given to the script
# (even if the function may not use them).
main "$@"


