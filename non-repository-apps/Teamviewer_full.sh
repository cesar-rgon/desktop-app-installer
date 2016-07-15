#!/bin/bash
##########################################################################
# This script installs Teamviewer full support application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 15/07/2016
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
# Download Teamviewer full. Always 32 bits deb because 64 bits version has broken dependencies
teamviewerFile="teamviewer_linux.deb"
teamviewerURL="http://download.teamviewer.com/download/teamviewer_i386.deb"
wget -O /tmp/$teamviewerFile $teamviewerURL 2>&1
dpkg -i /tmp/$teamviewerFile
apt-get -y install -f

# Extract teamviewer icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/teamviewer.tar.gz"

