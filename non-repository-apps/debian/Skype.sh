#!/bin/bash
##########################################################################
# This script installs Skype application.
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

# Commands to download, extract and install a non-repository application.
skypeURL="http://www.skype.com/go/getskype-linux-deb"
wget -O /var/cache/apt/archives/skype.deb $skypeURL 2>&1
gdebi --n /var/cache/apt/archives/skype.deb
apt-get -y install -f
