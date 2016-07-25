#!/bin/bash
##########################################################################
# This script prepare qBittorrent daemon installation.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 24/07/2016
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
AMULE_DAEMON_FILE="/etc/systemd/system/amuled.service"

# Copy systemd service script
yes | cp -f $scriptRootFolder/etc/systemd.service $AMULE_DAEMON_FILE


