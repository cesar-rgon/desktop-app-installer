#!/bin/bash
##########################################################################
# This script installs Skype application.
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
skypeFile="getskype-linux-deb-32"
skypeURL="http://www.skype.com/go/$skypeFile"
wget -P /var/cache/apt/archives $skypeURL 2>&1
dpkg -i /var/cache/apt/archives/$skypeFile
apt-get -y install -f
