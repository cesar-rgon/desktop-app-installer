#!/bin/bash
##########################################################################
# This script installs Draftsight application.
#
# Author: Isidro Rodríguez González & César Rodríguez González
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
draftSightFile="draftSight.deb"
wget -O /var/cache/apt/archives/$draftSightFile http://www.draftsight.com/download-linux-ubuntu 2>&1
dpkg -i /var/cache/apt/archives/$draftSightFile
apt-get -y install -f

