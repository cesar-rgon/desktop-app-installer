#!/bin/bash
##########################################################################
# This script prepare Deluge daemon installation.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Variables
DELUGE_DAEMON_FILE="/etc/systemd/system/deluged.service"
DELUGE_WEB_DAEMON_FILE="/etc/systemd/system/deluge-web.service"

# Copy systemd service script
yes | cp -f $scriptRootFolder/etc/systemd.service $DELUGE_DAEMON_FILE
yes | cp -f $scriptRootFolder/etc/systemd.service $DELUGE_WEB_DAEMON_FILE
