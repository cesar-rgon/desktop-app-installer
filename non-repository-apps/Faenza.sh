#!/bin/bash
##########################################################################
# This script installs Faenza icon theme.
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
faenzaFile="faenza-icon-theme_1.3.1_all.deb"
faenzaURL="https://launchpad.net/~tiheum/+archive/equinox/+files/$faenzaFile"
wget -P /var/cache/apt/archives $faenzaURL 2>&1
dpkg -i /var/cache/apt/archives/$faenzaFile
apt-get -y install -f
