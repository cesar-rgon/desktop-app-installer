#!/bin/bash
##########################################################################
# This script installs Skype application.
#
# Author: César Rodríguez González
# Version: 1.2
# Last modified date (dd/mm/yyyy): 23/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

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
