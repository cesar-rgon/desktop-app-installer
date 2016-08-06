#!/bin/bash
##########################################################################
# This script installs Skype application.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

#########################################################################################
# Check if the script is being running by a root or sudoer user				#
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/../.."; fi
. $scriptRoolFolder/common/commonVariables.sh

if [ "`uname -m`" == "x86_64" ]; then
	hardinfoFile="hardinfo_0.5.1-1.2_amd64.deb"
else
	hardinfoFile="hardinfo_0.5.1-1.2_i386.deb"
fi
# Commands to download, extract and install a non-repository application.
hardinfoURL="http://ftp.debian.org/debian/pool/main/h/hardinfo/$hardinfoFile"
wget -P /var/cache/apt/archives $hardinfoURL 2>&1
dpkg -i /var/cache/apt/archives/$hardinfoFile
apt-get -y install -f
