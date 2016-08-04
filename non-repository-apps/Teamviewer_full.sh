#!/bin/bash
##########################################################################
# This script installs Teamviewer full support application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../common/commonVariables.sh "`pwd`/.."

# Commands to download, extract and install a non-repository application.
# Download Teamviewer full. Always 32 bits deb because 64 bits version has broken dependencies
teamviewerFile="teamviewer_linux.deb"
teamviewerURL="http://download.teamviewer.com/download/teamviewer_i386.deb"
wget -O /tmp/$teamviewerFile $teamviewerURL 2>&1
gdebi --n /tmp/$teamviewerFile
apt-get -y install -f

# Extract teamviewer icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/teamviewer.tar.gz"
