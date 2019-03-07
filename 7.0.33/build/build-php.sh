#!/bin/sh

# ssh-keygen -A
BUILDDIR="/build"


checkExit()
{
	if [ "$?" != "0" ]
	then
		echo "# Gearbox: Exit reason \"$@\""
		exit $?
	fi
}


if [ ! -d ${BUILDDIR} ]
then
	echo "# Gearbox: ${BUILDDIR} doesn't exist."
	exit
fi


if [ -d "/build/rootfs/" ]
then
	rsync -HvaxP /build/rootfs/ /
fi


BUILD_BINS="autoconf binutils bison build-base coreutils fakeroot file g++ gcc gnupg gpgme libarchive-tools make musl pacman pkgconf re2c rsync"
BUILD_LIBS="apache2-dev aspell-dev bzip2-dev curl-dev db-dev dpkg-dev enchant-dev freetds-dev freetype-dev gdbm-dev gettext-dev gmp-dev icu-dev imagemagick-dev imap-dev jpeg-dev krb5-dev libarchive libcurl libintl libressl2.6-libcrypto libc-dev libedit-dev libical-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev libressl-dev libsodium-dev libssh2-dev libwebp-dev libxml2-dev libxpm-dev libxslt-dev libzip-dev musl-dev net-snmp-dev openldap-dev pcre-dev postgresql-dev readline-dev recode-dev sqlite-dev tidyhtml-dev unixodbc-dev zlib-dev"
BUILD_DEPS="${BUILD_BINS} ${BUILD_LIBS}"

PERSIST_DEPS="bash sudo wget curl gnupg openssl shadow pcre ca-certificates tar xz imagemagick"

PHPBUILD="${BUILDDIR}/php-${GEARBOX_CONTAINER_VERSION}"
PHPINSTALL="/usr/local"

# If you want to silence warnings use '-w', but don't... Really don't...
# CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -w"; export CFLAGS
CFLAGS="-fstack-protector-strong -fpic -fpie -O2"; export CFLAGS
CPPFLAGS="$CFLAGS"; export CPPFLAGS
LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"; export LDFLAGS
EXTENSION_DIR=${PHPINSTALL}/lib/php/modules; export EXTENSION_DIR


echo "# Gearbox: Adding packages."
apk update; checkExit
apk add --no-cache --virtual gearbox.persist $PERSIST_DEPS; checkExit
apk add --no-cache --virtual gearbox.build $BUILD_DEPS; checkExit


echo "# Gearbox: Fetching tarballs."
cd /build; checkExit
wget -nv -O "php-${GEARBOX_CONTAINER_VERSION}.tar.gz" -nv "$GEARBOX_CONTAINER_URL"; checkExit
tar zxf php-${GEARBOX_CONTAINER_VERSION}.tar.gz; checkExit


echo "# Gearbox: Patching PHP ${GEARBOX_CONTAINER_VERSION}."
cd ${BUILDDIR}; checkExit
patch -p0 < install-pear.patch; checkExit
# patch -p0 < libressl-2.7.patch; checkExit
patch -p0 < allow-build-recode-and-imap-together.patch; checkExit
ln /usr/include/tidybuffio.h /usr/include/buffio.h


echo "# Gearbox: Configure PHP ${GEARBOX_CONTAINER_VERSION}."
cd ${PHPBUILD}; checkExit
autoconf; checkExit
./configure --config-cache --cache-file=config.cache \
	--enable-fpm --with-fpm-user=${GEARBOX_USER} --with-fpm-group=${GEARBOX_GROUP} \
	--datadir=${PHPINSTALL}/share/php \
	--disable-gd-jis-conv \
	--disable-short-tags \
	--enable-bcmath=shared \
	--enable-calendar=shared \
	--enable-ctype=shared \
	--enable-dba=shared \
	--enable-dom=shared \
	--enable-exif=shared \
	--enable-fileinfo=shared \
	--enable-ftp=shared \
	--enable-intl=shared \
	--enable-json=shared \
	--enable-libxml \
	--enable-mbstring=shared \
	--enable-mysqlnd=shared \
	--enable-opcache=shared \
	--enable-pcntl=shared \
	--enable-pdo=shared \
	--enable-phar=shared \
	--enable-posix=shared \
	--enable-session=shared \
	--enable-shmop=shared \
	--enable-simplexml=shared \
	--enable-soap=shared \
	--enable-sockets=shared \
	--enable-sysvmsg=shared \
	--enable-sysvsem=shared \
	--enable-sysvshm=shared \
	--enable-tokenizer=shared \
	--enable-wddx=shared \
	--enable-xml=shared \
	--enable-xmlreader=shared \
	--enable-xmlwriter=shared \
	--enable-zip=shared \
	--libdir=${PHPINSTALL}/lib/php \
	--localstatedir=/var \
	--prefix=${PHPINSTALL} \
	--sysconfdir=${PHPINSTALL}/etc/php \
	--with-bz2=shared \
	--with-config-file-path=${PHPINSTALL}/etc/php \
	--with-config-file-scan-dir=${PHPINSTALL}/etc/php/conf.d \
	--with-curl=shared \
	--with-db4 \
	--with-dbmaker=shared \
	--with-enchant=shared \
	--with-freetype-dir=/usr \
	--with-gd=shared \
	--with-gdbm \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-iconv=shared \
	--with-icu-dir=/usr \
	--with-imap-ssl \
	--with-imap=shared \
	--with-jpeg-dir=/usr \
	--with-kerberos \
	--with-layout=GNU \
	--with-ldap-sasl \
	--with-ldap=shared \
	--with-libedit \
	--with-libxml-dir=/usr \
	--with-libzip=/usr \
	--with-mysql-sock=/run/mysqld/mysqld.sock \
	--with-mysqli=shared,mysqlnd \
	--with-openssl=shared \
	--with-pcre-regex=/usr \
	--with-pdo-dblib=shared \
	--with-pdo-mysql=shared,mysqlnd \
	--with-pdo-odbc=shared,unixODBC,/usr \
	--with-pdo-pgsql=shared \
	--with-pdo-sqlite=shared,/usr \
	--with-pear=${PHPINSTALL}/share/php \
	--with-pgsql=shared \
	--with-pic \
	--with-png-dir=/usr \
	--with-pspell=shared \
	--with-recode=shared \
	--with-snmp=shared \
	--with-sqlite3=shared,/usr \
	--with-system-ciphers \
	--with-tidy=shared \
	--with-unixODBC=shared,/usr \
	--with-webp-dir=/usr \
	--with-xmlrpc=shared \
	--with-xpm-dir=/usr \
	--with-xsl=shared \
	--with-zlib \
	--with-zlib-dir=/usr \
	--without-readline; checkExit

#	--enable-gd-native-ttf
#	--with-sodium=shared

echo "# Gearbox: Compile PHP ${GEARBOX_CONTAINER_VERSION}."
make; checkExit

echo "# Gearbox: Install PHP ${GEARBOX_CONTAINER_VERSION}."
make install; checkExit
install -d -m755 ${PHPINSTALL}/etc/php/conf.d/; checkExit
# rmdir ${PHPINSTALL}/include/php; checkExit
mkdir -p /var/run/php; checkExit


echo "# Gearbox: Adding Imagick extension, (3.4.3)."
cd ${PHPBUILD}/ext; checkExit
wget -nv http://pecl.php.net/get/imagick-3.4.3.tgz; checkExit
tar zxf imagick-3.4.3.tgz; checkExit
cd imagick-3.4.3; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# Gearbox: Adding Xdebug extension, (2.6.0)."
cd ${PHPBUILD}/ext; checkExit
wget -nv https://xdebug.org/files/xdebug-2.6.0.tgz; checkExit
tar zxf xdebug-2.6.0.tgz; checkExit
cd xdebug-2.6.0; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# Gearbox: Adding mcrypt extension, (1.0.1)."
cd ${PHPBUILD}/ext; checkExit
wget -nv http://pecl.php.net/get/mcrypt-1.0.1.tgz; checkExit
tar zxf mcrypt-1.0.1.tgz; checkExit
cd mcrypt-1.0.1; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# Gearbox: Adding ssh2 extension, (1.1.2)."
cd ${PHPBUILD}/ext; checkExit
wget -nv http://pecl.php.net/get/ssh2-1.1.2.tgz; checkExit
tar zxf ssh2-1.1.2.tgz; checkExit
cd ssh2-1.1.2; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# Gearbox: Adding libsodium extension, (2.0.11)."
cd ${PHPBUILD}/ext; checkExit
wget -nv http://pecl.php.net/get/libsodium-2.0.11.tgz; checkExit
tar zxf libsodium-2.0.11.tgz; checkExit
cd libsodium-2.0.11; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# Gearbox: pecl update-channels."
# Fixup pecl errors.
# EG: "Warning: Invalid argument supplied for foreach() in ${PHPINSTALL}/share/pear/PEAR/Command.php
#     "Warning: Invalid argument supplied for foreach() in Command.php on line 249"
sed -i 's/^exec $PHP -C -n -q/exec $PHP -C -q/' ${PHPINSTALL}/bin/pecl; checkExit
pecl update-channels; checkExit


echo "# Gearbox: Download mhsendmail."
if [ ! -d /usr/local/bin ]
then
	mkdir -p /usr/local/bin
fi
wget -nv -O /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64; checkExit
chmod a+x /usr/local/bin/mhsendmail; checkExit


if [ ! -d "${BUILDDIR}/output" ]
then
	mkdir -p "${BUILDDIR}/output"
fi
tar zcvf "${BUILDDIR}/output/php.tar.gz" /usr/local

