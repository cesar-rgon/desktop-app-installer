#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of 
# Sublime Text 3 application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 30/07/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi


# Get common variables
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh


# Variables
repositoryURL="http://ppa.launchpad.net/webupd8team/sublime-text-3/ubuntu"
#repository="deb $repositoryURL $distroName main"
#repositorySource="deb-src $repositoryURL $distroName main"
targetFilename="webupd8team-ubuntu-sublime-text-3-$distroName.list"

# Commands to add third-party repository of the application.
# SE ESTA DUPLICANDO DEB-SRC
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	add-apt-repository -y ppa:webupd8team/sublime-text-3
fi 2>/dev/null

