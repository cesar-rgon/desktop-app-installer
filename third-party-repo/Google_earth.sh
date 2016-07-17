#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Earth application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 17/07/2016
# Licence: MIT
##########################################################################

# Variables
distroName="$(lsb_release -sc)"
repositoryURL="http://dl.google.com/linux/earth/deb/"
repository="deb $repositoryURL stable main"
repositorySource="deb-src $repositoryURL stable main"
targetFilename="google-earth.list"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	# Command to add repository key if needed
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub 2>&1 | apt-key add -
	echo "$repository" >> "/etc/apt/sources.list.d/$targetFilename"
	# Uncomment if needed [optional]
	# echo "$repositorySource" >> "/etc/apt/sources.list.d/$targetFilename"
fi 2>/dev/null



