#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
. ../common/commonVariables.sh

# Variables
DELUGE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/deluge"
DELUGE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/deluge"
DELUGE_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
DELUGE_DAEMON_USERNAME="$username"
DELUGE_DAEMON_PASSWORD="deluge"
DELUGE_DAEMON_CLIENT_PORT="58846"
DELUGE_DAEMON_WEB_PORT="8112"

# Set variables in deluge-daemon config files
echo "# Configuration for /etc/init.d/deluge-daemon
# The init.d script will only run if this variable non-empty.
DELUGED_USER=\"$username\"
# Should we run at startup?
RUN_AT_STARTUP=\"YES\"" > /etc/default/deluge-daemon
# Add username and password to Deluge's authentication file
sudo -u $username deluged
echo "$DELUGE_DAEMON_USERNAME:$DELUGE_DAEMON_PASSWORD:10" >> $homeFolder/.config/deluge/auth
chown $username:$username $homeFolder/.config/deluge/auth
# Set deluge folders
sudo -u $username deluge-console "config -s move_completed_path \"$DELUGE_DAEMON_DOWNLOAD_FOLDER\""
sudo -u $username deluge-console "config move_completed_path"
sudo -u $username deluge-console "config -s download_location \"$DELUGE_DAEMON_TEMP_FOLDER\""
sudo -u $username deluge-console "config download_location"
sudo -u $username deluge-console "config -s torrentfiles_location \"$DELUGE_DAEMON_TORRENT_FOLDER\""
sudo -u $username deluge-console "config torrentfiles_location"
sudo -u $username deluge-console "config -s autoadd_location \"$DELUGE_DAEMON_TORRENT_FOLDER\""
sudo -u $username deluge-console "config autoadd_location"
# Allow remote connection
sudo -u $username deluge-console "config -s allow_remote True"
sudo -u $username deluge-console "config allow_remote"
# Set Deluge daemon client and web ports
sudo -u $username deluge-console "config -s daemon_port $DELUGE_DAEMON_CLIENT_PORT"
sudo -u $username deluge-console "config daemon_port"
sudo -u $username sed -i "s/\"port\":.*/\"port\": $DELUGE_DAEMON_WEB_PORT/g" $homeFolder/.config/deluge/web.conf
pkill deluged

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

# Copy deluge-daemon init script
cp $scriptRootFolder/etc/deluge-daemon /etc/init.d/
chmod +x /etc/init.d/deluge-daemon

# Start deluge-daemon
service deluge-daemon start

# Create deluge-daemon startup links
update-rc.d -f deluge-daemon defaults

