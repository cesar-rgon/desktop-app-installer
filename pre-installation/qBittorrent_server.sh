#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 20/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Variables
QBITTORRENT_SERVICE_FILE="/etc/systemd/system/qbittorrent-nox.service"

# Copy systemd service script
cp $scriptRootFolder/etc/systemd.service $QBITTORRENT_SERVICE_FILE
