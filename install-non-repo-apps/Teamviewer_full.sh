#!/bin/bash
##########################################################################
# This script installs Teamviewer full support application.
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

# Commands to download, extract and install a non-repository application.
# Download Teamviewer full. Always 32 bits deb because 64 bits version has broken dependencies
teamviewerFile="teamviewer_linux.deb"
teamviewerURL="http://download.teamviewer.com/download/teamviewer_i386.deb"
wget -O /tmp/$teamviewerFile $teamviewerURL 2>&1
gdebi --n /tmp/$teamviewerFile
apt -y install -f

# Extract teamviewer icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/teamviewer.tar.gz"
