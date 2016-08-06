#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Chrome application.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

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
