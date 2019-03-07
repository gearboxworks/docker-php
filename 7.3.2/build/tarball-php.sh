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


echo "# Gearbox: Extracting tarball."
TARBALL="$1"
if [ "${TARBALL}" == "" ]
then
	echo "Gearbox: Need a tarball to extract."
	exit 1
fi

if [ ! -f "${TARBALL}" ]
then
	echo "Gearbox: Tarball ${TARBALL} does NOT exist."
	exit 1
fi

cd /
tar xf ${TARBALL}; checkExit
rm -f ${TARBALL}; checkExit

