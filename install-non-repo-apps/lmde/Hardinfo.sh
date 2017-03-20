#!/bin/bash
##########################################################################
# This script installs Skype application.
# @author César Rodríguez González
# @version 1.3, 2016-08-09
# @license MIT
##########################################################################

#########################################################################################
# Check if the script is being running by a root or sudoer user				#
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

if [ "`uname -m`" == "x86_64" ]; then
	hardinfoFile="hardinfo_0.5.1-1.2_amd64.deb"
else
	hardinfoFile="hardinfo_0.5.1-1.2_i386.deb"
fi
# Commands to download, extract and install a non-repository application.
hardinfoURL="http://ftp.debian.org/debian/pool/main/h/hardinfo/$hardinfoFile"
wget -P /var/cache/apt/archives $hardinfoURL 2>&1
dpkg -i /var/cache/apt/archives/$hardinfoFile
apt install -f
