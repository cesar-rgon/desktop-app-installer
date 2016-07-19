#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 19/07/2016
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
DELUGE_DAEMON_WEB_PORT="8112"

# Create menu launcher for deluge-daemon's web client.
echo "[Desktop Entry]
Name=Deluge Web
Exec=xdg-open http://localhost:$DELUGE_DAEMON_WEB_PORT
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Deluge Web" > /usr/share/applications/deluged-web.desktop

# Create menu launcher to start deluge-daemon.
echo "[Desktop Entry]
Name=Deluge daemon start
Exec=gksudo /etc/init.d/deluge-daemon start
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Deluge server" > /usr/share/applications/deluged-start.desktop

# Create menu launcher to stop deluge-daemon.
echo "[Desktop Entry]
Name=Deluge daemon stop
Exec=gksudo /etc/init.d/deluge-daemon stop
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Deluge server" > /usr/share/applications/deluged-stop.desktop

# Extract deluge icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/deluge.tar.gz"

# Start deluge-daemon
service deluge-daemon start

# Create deluge-daemon startup links
update-rc.d -f deluge-daemon defaults

