#!/bin/bash
##########################################################################
# This script prepare qBittorrent daemon installation.
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

# Variables
QBITTORRENT_DAEMON_FILE="/etc/systemd/system/qbittorrent-nox.service"

# Copy systemd service script
yes | cp -f $scriptRootFolder/etc/systemd.service $QBITTORRENT_DAEMON_FILE
