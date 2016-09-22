#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (yyyy/mm/dd): 2016/09/22
# Licence: MIT
##########################################################################

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties
# Add credentials for authentication
. $credentialFolder/Deluge_server.properties

# Variables
DELUGE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/deluge"
DELUGE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/deluge"
DELUGE_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
DELUGE_DAEMON_TCP_AND_CLIENT_PORT="58846"
DELUGE_DAEMON_WEB_PORT="8112"
DELUGE_DAEMON_FILE="/etc/init.d/deluge-daemon"

# Create the necessary folders, set ownership and permissions
sudo -u $username mkdir -p $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER $homeFolder/.config/deluge
chown -R $username:$username $homeFolder/.config/deluge/*
chmod -R 770 $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER
find $homeFolder/.config/deluge/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.config/deluge/* -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null

# Set variables in deluge-daemon config files
echo "# Configuration for $DELUGE_DAEMON_FILE
# The init.d script will only run if this variable non-empty.
DELUGED_USER=\"$username\"
# Should we run at startup?
RUN_AT_STARTUP=\"YES\"" > /etc/default/deluge-daemon

# Add username and password to Deluge's authentication file
echo "$appUsername:$appPassword:10" >> $homeFolder/.config/deluge/auth
chown $username:$username $homeFolder/.config/deluge/auth

# Setup Deluge daemon's config file
echo "{
  \"file\": 1, 
  \"format\": 1
}{
  \"download_location\": \"$DELUGE_DAEMON_TEMP_FOLDER\",
  \"move_completed\": true,
  \"move_completed_path\": \"$DELUGE_DAEMON_DOWNLOAD_FOLDER\",
  \"autoadd_enable\": true, 
  \"autoadd_location\": \"$DELUGE_DAEMON_TORRENT_FOLDER\",
  \"copy_torrent_file\": true,
  \"torrentfiles_location\": \"$DELUGE_DAEMON_TORRENT_FOLDER\",
  \"daemon_port\": $DELUGE_DAEMON_TCP_AND_CLIENT_PORT,
  \"allow_remote\": true
}" > "$homeFolder/.config/deluge/core.conf"

# Set Deluge daemon web port
echo "{
  \"file\": 1, 
  \"format\": 1
}{
  \"port\": $DELUGE_DAEMON_WEB_PORT
}" > "$homeFolder/.config/deluge/web.conf"
chown $username:$username "$homeFolder/.config/deluge/web.conf"

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
Exec=gksudo $DELUGE_DAEMON_FILE start
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Deluge server" > /usr/share/applications/deluged-start.desktop

# Create menu launcher to stop deluge-daemon.
echo "[Desktop Entry]
Name=Deluge daemon stop
Exec=gksudo $DELUGE_DAEMON_FILE stop
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Deluge server" > /usr/share/applications/deluged-stop.desktop

# Extract deluge icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/deluge.tar.gz"

# Copy deluge-daemon init script
cp $scriptRootFolder/etc/old-init.d/deluge-daemon /etc/init.d/
chmod +x $DELUGE_DAEMON_FILE

# Start deluge-daemon
service deluge-daemon start

# Create deluge-daemon startup links
update-rc.d -f deluge-daemon defaults

