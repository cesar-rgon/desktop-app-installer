#!/bin/bash
##########################################################################
# This script configures Transmission daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.1
# Last modified date (dd/mm/yyyy): 15/05/2014
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
TRANSMISSION_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/Transmission"
TEMP_FOLDER="$homeFolder/.Temporal"
TRANSMISSION_DAEMON_TEMP_FOLDER="$TEMP_FOLDER/Transmission"
TRANSMISSION_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
TRANSMISSION_DAEMON_USERNAME="$username"
TRANSMISSION_DAEMON_USER_PASSWORD="transmission"
TRANSMISSION_DAEMON_CLIENT_AND_WEB_PORT="9091"

# Install Transmission daemon
apt-get -y install transmission-daemon

# Backup of transmission daemon config file
cp /var/lib/transmission-daemon/info/settings.json /var/lib/transmission-daemon/info/settings.json.backup

# Add user to debian-transmission group
usermod -a -G debian-transmission $username

# Create the necessary folders
mkdir -p $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER
# Set the owner and permissions of the folders
chown $username:$username $TEMP_FOLDER
chown $username:debian-transmission $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER
chmod -R 770 $TRANSMISSION_DAEMON_DOWNLOAD_FOLDER $TRANSMISSION_DAEMON_TEMP_FOLDER $TRANSMISSION_DAEMON_TORRENT_FOLDER

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
\"rpc-password\": \"$TRANSMISSION_DAEMON_USER_PASSWORD\",
\"rpc-username\": \"$TRANSMISSION_DAEMON_USERNAME\",
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
Exec=gksudo /etc/init.d/transmission-daemon start
Icon=transmission
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Transmission server" > /usr/share/applications/transmission-start.desktop

# Create menu launcher to stop transmission-daemon.
echo "[Desktop Entry]
Name=Transmission daemon stop
Exec=gksudo /etc/init.d/transmission-daemon stop
Icon=transmission
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Transmission server" > /usr/share/applications/transmission-stop.desktop

# Start transmission daemon
service transmission-daemon start

