#!/bin/bash
##########################################################################
# This script installs Steam application.
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
steamFile="steam.deb"
steamURL="http://media.steampowered.com/client/installer/$steamFile"
wget -P /var/cache/apt/archives $steamURL 2>&1
dpkg -i /var/cache/apt/archives/$steamFile
apt-get -y install -f
