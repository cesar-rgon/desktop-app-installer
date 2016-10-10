#!/bin/bash
##########################################################################
# This script removes Deluge daemon config files and folders
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
rm -f /etc/systemd/system/deluged.service
rm -f /etc/systemd/system/deluge-web.service
rm -rf $homeFolder/.config/deluge
rm -f /etc/init.d/deluge-daemon
rm -f /etc/default/deluge-daemon
rm -f /usr/share/applications/deluged-web.desktop
rm -f /usr/share/applications/deluged-start.desktop
rm -f /usr/share/applications/deluged-stop.desktop
rm -f /usr/share/pixmaps/deluge.png
