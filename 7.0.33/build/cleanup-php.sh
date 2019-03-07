#!/bin/sh

BUILDDIR="/build"


checkExit()
{
	if [ "$?" != "0" ]
	then
		echo "# Gearbox: Exit reason \"$@\""
		exit $?
	fi
}


if [ "$BUILD_TYPE" != "" ]
then
	echo "# Gearbox: Maintaining build packages for build type \"$BUILD_TYPE\"."
	exit
fi


if [ -d "/build/rootfs/" ]
then
	rsync -HvaxP /build/rootfs/ /
fi


echo "# Gearbox: Setting permissions."
find /usr/local/bin /usr/local/sbin -type f | xargs chmod a+x
# find . -type f -perm +0111 -exec strip --strip-all '{}'


echo "# Gearbox: Removing build packages for runtime."
apk del gearbox.build; checkExit


echo "# Gearbox: Adding packages required by PHP ${GEARBOX_CONTAINER_VERSION}."
RUNTIME_DEPS="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr | tr ',' '\n' | sort -u | awk '/libmysqlclient.so.16/{next} system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"
echo "# ${RUNTIME_DEPS}"
apk add --no-cache --virtual gearbox.runtime ${RUNTIME_DEPS}; checkExit

echo "# Gearbox: Cleaning up."
rm -rf ${BUILDDIR}
unset BUILD_DEPS PERSIST_DEPS RUNTIME_DEPS CPPFLAGS LDFLAGS CFLAGS EXTENSION_DIR

apk add libedit aspell-libs libxpm libzip icu-libs

