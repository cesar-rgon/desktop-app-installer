#!/bin/bash
##########################################################################
# This script installs Steam application.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 14/05/2014
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
steamURL="http://media.steampowered.com/client/installer/steam.deb"
wget -P /var/cache/apt/archives $steamURL

if [ "$desktop" == "kde" ]; then
	apt-get -y install qapt-deb-installer
	qapt-deb-installer /var/cache/apt/archives/steam.deb
else
	apt-get -y install gdebi
	gdebi --n /var/cache/apt/archives/steam.deb
fi
