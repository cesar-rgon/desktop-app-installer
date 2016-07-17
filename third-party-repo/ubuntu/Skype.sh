#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of
# Skype application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 16/07/2016
# Licence: MIT
##########################################################################
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Variables
distroName="$(lsb_release -sc)"
repository="deb http://archive.canonical.com/ $distroName partner"
#repositorySource="deb-src http://archive.canonical.com/ $distroName partner"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	add-apt-repository -y "$repository" 2>&1
fi 2>/dev/null

