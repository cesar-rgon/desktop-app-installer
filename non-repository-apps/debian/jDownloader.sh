#!/bin/bash
##########################################################################
# This script installs jDowloader application.
#
# Author: César Rodríguez González
# Version: 1.2
# Last modified date (dd/mm/yyyy): 22/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Pre-requisite
apt-get -y install default-jre

# Commands to download, extract and install a non-repository application.
jDownloaderFile="jd_unix_0_9.sh"
jDownloaderURL="http://installer.jdownloader.org/$jDownloaderFile"
wget -P /var/cache/apt/archives $jDownloaderURL 2>&1
bash /var/cache/apt/archives/$jDownloaderFile


