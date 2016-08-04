#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Atom
# editor application. Official text editor of Github.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../../common/commonVariables.sh "`pwd`/../.."

# Variables
repositoryURL="http://ppa.launchpad.net/webupd8team/atom/ubuntu"
#repository="deb $repositoryURL $distroName main"
#repositorySource="deb-src $repositoryURL $distroName main"
targetFilename="webupd8team-ubuntu-atom-$distroName.list"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	add-apt-repository -y ppa:webupd8team/atom 2>&1
fi 2>/dev/null
