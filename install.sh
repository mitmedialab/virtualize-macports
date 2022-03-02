#!/bin/bash

if [[ "${BASH_SOURCE-}" != "$0" ]]; then
    echo "You cannot source this script. Run it as ./$0" >&2
    exit 33
fi

VIRTUALIZE_HOMEBREW_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE}" )" &> /dev/null && pwd )

# see https://guide.macports.org/chunked/installing.macports.html#installing.macports.source
# and https://www.jduck.net/blog/2008/12/12/install-macports-in-local-home-directory/
# still creates a ~/.macports dir (for readline history), maybe this can be moved?

cd $VIRTUALIZE_HOMEBREW_DIR
curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.7.1.tar.bz2
tar -xf MacPorts-2.7.1.tar.bz2
cd $VIRTUALIZE_HOMEBREW_DIR/MacPorts-2.7.1

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
MP_PREFIX="$VIRTUALIZE_HOMEBREW_DIR/macports"
GROUP=`groups | cut -d' ' -f1`

./configure --prefix=$MP_PREFIX --with-applications-dir=$MP_PREFIX/Applications --without-startupitems --with-install-user=${USER} --with-install-group=${GROUP} --with-no-root-privileges --enable-readline
make
make install

cd $VIRTUALIZE_HOMEBREW_DIR
#rm -rf $VIRTUALIZE_HOMEBREW_DIR/MacPorts-2.7.1  # FIXME once this is working uncomment this

echo "### virtualizer added these config changes:" >> $VIRTUALIZE_HOMEBREW_DIR/macports/etc/macports/macports.conf

echo "setting macports to not use hfs compression"
echo "hfscompression no" >> $VIRTUALIZE_HOMEBREW_DIR/macports/etc/macports/macports.conf

echo
echo "do you want this macports install to always build from source?"
echo "it'll be slower, but is probably more compatable with virtualized. probably."
echo
read -p "always build from source [y]? " yn

case $yn in
    [yY]|yes|Yes|YES|"" )
	echo "setting macports to always build from source"
	echo "buildfromsource always" >> $VIRTUALIZE_HOMEBREW_DIR/macports/etc/macports/macports.conf
	;;
    * )
	echo "not setting macports to always build from source"
	;;
esac
echo "### virtualizer added those ^^^ config changes" >> $VIRTUALIZE_HOMEBREW_DIR/macports/etc/macports/macports.conf

export PATH="$VIRTUALIZE_HOMEBREW_DIR/macports/bin:$PATH"
port selfupdate
#port -N install the_silver_searcher  # this just takes too damn long

echo "macports installed"

exit
