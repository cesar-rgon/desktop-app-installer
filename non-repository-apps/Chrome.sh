#!/bin/bash
##########################################################################
# This script installs Chrome application.
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
	chromeFile="google-chrome-stable_current_i386.deb"
else
	chromeFile="google-chrome-stable_current_amd64.deb"
fi
chromeURL="https://dl.google.com/linux/direct/$chromeFile"
wget -P /var/cache/apt/archives $chromeURL 2>&1
dpkg -i /var/cache/apt/archives/$chromeFile
apt-get -y install -f
