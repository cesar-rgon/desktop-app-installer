#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of
# Skype application.
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
repository="deb http://archive.canonical.com/ $distroName partner"
#repositorySource="deb-src http://archive.canonical.com/ $distroName partner"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	echo "deb http://archive.canonical.com/ubuntu $distroName partner" > /etc/apt/sources.list.d/skype.list
	echo "deb-src http://archive.canonical.com/ubuntu $distroName partner" >> /etc/apt/sources.list.d/skype.list
fi 2>/dev/null
