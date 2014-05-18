#!/bin/bash
##########################################################################
# This script installs Google Earth application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 18/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
if [ "`uname -i`" == "i686" ]; then
	googleEarthFile="google-earth-stable_current_i386.deb"
else
	googleEarthFile="google-earth-stable_current_amd64.deb"
fi
googleEarthURL="http://dl.google.com/dl/earth/client/current/$googleEarthFile"
wget -P /var/cache/apt/archives $googleEarthURL 2>&1
dpkg -i /var/cache/apt/archives/$googleEarthFile
apt-get -y install -f
