#!/bin/bash
##########################################################################
# This script prepare qBittorrent daemon installation.
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
AMULE_DAEMON_FILE="/etc/systemd/system/amuled.service"

# Copy systemd service script
yes | cp -f $scriptRootFolder/etc/systemd.service $AMULE_DAEMON_FILE
