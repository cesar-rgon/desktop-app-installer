#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Chrome application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 26/07/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Variables
repositoryURL="http://dl.google.com/linux/chrome/deb/"
repository="deb [arch=amd64] $repositoryURL stable main"
repositorySource="deb-src [arch=amd64] $repositoryURL stable main"
targetFilename="google-chrome.list"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	# Command to add repository key if needed
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub 2>&1 | apt-key add -
	echo "$repository" >> "/etc/apt/sources.list.d/$targetFilename"
	# Uncomment if needed [optional]
	# echo "$repositorySource" >> "/etc/apt/sources.list.d/$targetFilename"
fi 2>/dev/null
