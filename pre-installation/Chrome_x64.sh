#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Chrome application.
# @author César Rodríguez González
# @version 1.3, 2016-08-09
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi


# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Variables
repositoryURL="http://dl.google.com/linux/chrome/deb/"
repository="deb [arch=amd64] $repositoryURL stable main"
repositorySource="deb-src [arch=amd64] $repositoryURL stable main"
repositoryFilename="google-chrome.list"

# Commands to add third-party repository of the application.
rm -f "/etc/apt/sources.list.d/$repositoryFilename"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub 2>&1 | apt-key add -
echo "$repository" > "/etc/apt/sources.list.d/$repositoryFilename"
#echo "$repositorySource" >> "/etc/apt/sources.list.d/$repositoryFilename"
