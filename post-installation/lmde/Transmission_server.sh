#!/bin/bash
##########################################################################
# This script configures Transmission daemon to be ready to use.
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
. $credentialFolder/Transmission_server.properties

# Variables
TRANSMISSION_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/Transmission"
TRANSMISSION_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/Transmission"
TRANSMISSION_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
TRANSMISSION_DAEMON_CLIENT_AND_WEB_PORT="9091"
TRANSMISSION_DAEMON_TCP_PORT="51413"
TRANSMISSION_DAEMON_FILE="/etc/init.d/transmission-daemon"

# Install Transmission daemon
apt-get -y install transmission-daemon

# Backup of transmission daemon config file
cp /var/lib/transmission-daemon/info/settings.json /var/lib/transmission-daemon/info/settings.json.backup

# Add user to debian-transmission group
usermod -a -G debian-transmission $username

# Create the necessary folders, set ownership and permissions
sudo -u $username mkdir -p $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER $homeFolder/.config/transmission-daemon
chown -R $username:debian-transmission $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER /var/lib/transmission-daemon
chmod -R 770 $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER
find $homeFolder/.config/transmission-daemon/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.config/transmission-daemon/* -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null

# Stop transmission daemon
service transmission-daemon stop

# Setup transmission daemon
# Suppress variables to modify from transmission config file
transmissionVariablesToModify="\"download-dir\"\|\"incomplete-dir\"\|\"rpc-password\"\|\"rpc-username\"\|\"rpc-whitelist\"\|\"umask\""
cat /var/lib/transmission-daemon/info/settings.json | grep -v "$transmissionVariablesToModify" | tr -d '}' > /tmp/transmission.json
# Add comma character to last line
lastLine="`awk '/./{line=$0} END{print line}' /tmp/transmission.json`"
sed -i "s/$lastLine/$lastLine,/g" /tmp/transmission.json
# Add modified variables
echo "\"download-dir\": \"$TRANSMISSION_DAEMON_DOWNLOAD_FOLDER\",
\"incomplete-dir\": \"$TRANSMISSION_DAEMON_TEMP_FOLDER\",
\"incomplete-dir-enabled\": true,
\"peer-port\": $TRANSMISSION_DAEMON_TCP_PORT,
\"rpc-password\": \"$appPassword\",
\"rpc-username\": \"$appUsername\",
\"rpc-whitelist\": \"*\",
\"rpc-port\": $TRANSMISSION_DAEMON_CLIENT_AND_WEB_PORT,
\"umask\": 7,
\"watch-dir\": \"$TRANSMISSION_DAEMON_TORRENT_FOLDER\",
\"watch-dir-enabled\": true
}" >> /tmp/transmission.json
# Move temp file to transmission config file
mv /tmp/transmission.json /var/lib/transmission-daemon/info/settings.json

# Create menu launcher for transmission-daemon's web client.
echo "[Desktop Entry]
Name=Transmission Web
Exec=xdg-open http://localhost:$TRANSMISSION_DAEMON_CLIENT_AND_WEB_PORT
Icon=transmission
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Transmission Web" > /usr/share/applications/transmission-web.desktop

# Create menu launcher to start transmission-daemon.
echo "[Desktop Entry]
Name=Transmission daemon start
Exec=gksudo $TRANSMISSION_DAEMON_FILE start
Icon=transmission
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Transmission server" > /usr/share/applications/transmission-start.desktop

# Create menu launcher to stop transmission-daemon.
echo "[Desktop Entry]
Name=Transmission daemon stop
Exec=gksudo $TRANSMISSION_DAEMON_FILE stop
Icon=transmission
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Transmission server" > /usr/share/applications/transmission-stop.desktop

# Start transmission daemon
service transmission-daemon start

