#!/bin/bash
# Created on 2020-05-24T21:44:56+1000, using template:php.sh.tmpl and json:gearbox.json

test -f /etc/gearbox/bin/colors.sh && . /etc/gearbox/bin/colors.sh

c_ok "Started."

c_ok "Installing packages."
APKBIN="$(which apk)"
if [ "${APKBIN}" != "" ]
then
	if [ -f /etc/gearbox/build/php.apks ]
	then
		APKS="$(cat /etc/gearbox/build/php.apks)"
		${APKBIN} update && ${APKBIN} add --no-cache --virtual gearbox ${APKS}; checkExit
	fi
fi

APTBIN="$(which apt-get)"
if [ "${APTBIN}" != "" ]
then
	if [ -f /etc/gearbox/build/php.apt ]
	then
		DEBS="$(cat /etc/gearbox/build/php.apt)"
		${APTBIN} update && ${APTBIN} install ${DEBS}; checkExit
	fi
fi


if [ -f /etc/gearbox/build/php.env ]
then
	. /etc/gearbox/build/php.env
fi

if [ ! -d /usr/local/bin ]
then
	mkdir -p /usr/local/bin; checkExit
fi


c_ok "Generate installed file list"
c_ok "####################"
apk info -v -R gearbox | sed 's/gearbox://' | xargs apk info -L | awk '/bin\//{print"/"$1}'
c_ok "####################"

docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) gd

c_ok "Finished."
