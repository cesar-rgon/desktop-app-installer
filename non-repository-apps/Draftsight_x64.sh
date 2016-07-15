#!/bin/bash
##########################################################################
# This script installs Draftsight application.
#
# Author: Isidro Rodríguez González & César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 15/07/2016
# Licence: MIT
##########################################################################
# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
draftSightFile="draftSight.deb"
wget -O /var/cache/apt/archives/$draftSightFile http://www.draftsight.com/download-linux-ubuntu 2>&1
dpkg -i /var/cache/apt/archives/$draftSightFile
apt-get -y install -f

