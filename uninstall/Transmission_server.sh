#!/bin/bash
##########################################################################
# This script removes Transmission daemon config files and folders.
# @author César Rodríguez González
# @version 1.3, 2016-10-10
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

### REMOVE CONFIG FILES ##################################################
rm -f /etc/systemd/system/transmission-daemon.service
rm -rf $homeFolder/.config/transmission-daemon
rm -rf /var/lib/transmission-daemon
rm -f /etc/init.d/transmission-daemon
rm -f /usr/share/applications/transmission-web.desktop
rm -f /usr/share/applications/transmission-start.desktop
rm -f /usr/share/applications/transmission-stop.desktop
rm -f /etc/init.d/transmission-daemon
delgroup debian-transmission
