#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
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
# INFO
# QBITTORRENT_DAEMON_PASSWORD="adminadmin"
QBITTORRENT_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/qBittorrent"
TEMP_FOLDER="$homeFolder/.Temporal"
QBITTORRENT_DAEMON_TEMP_FOLDER="$TEMP_FOLDER/qBittorrent"
QBITTORRENT_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
QBITTORRENT_DAEMON_USERNAME="$username"
QBITTORRENT_DAEMON_WEB_PORT="8081"

# Create the necessary folders
mkdir -p $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER $homeFolder/.config/qBittorrent
chown -R $username:$username $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER $homeFolder/.config/qBittorrent

# Copy qbittorrent daemon init script
cp $scriptRootFolder/etc/qbittorrent-nox-daemon /etc/init.d/
chmod +x /etc/init.d/qbittorrent-nox-daemon

# Set variables in qbittorrent-daemon config files
sed -i "s/USER=.*/USER=$username/g" /etc/init.d/qbittorrent-nox-daemon
sed -i "s/DAEMON_ARGS=.*/DAEMON_ARGS=\"--webui-port=$QBITTORRENT_DAEMON_WEB_PORT\"/g" /etc/init.d/qbittorrent-nox-daemon

# Second copy of qbittorrent daemon init script to properly start/stop application service
cp /etc/init.d/qbittorrent-nox-daemon /usr/bin/qbittorrent-nox-daemon
chmod +x /usr/bin/qbittorrent-nox-daemon

echo "[Preferences]
Downloads\SavePath=$QBITTORRENT_DAEMON_DOWNLOAD_FOLDER
Downloads\TempPathEnabled=true
Downloads\TempPath=$QBITTORRENT_DAEMON_TEMP_FOLDER
Downloads\ScanDirs=$QBITTORRENT_DAEMON_TORRENT_FOLDER
WebUI\Username=$QBITTORRENT_DAEMON_USERNAME
WebUI\Port=$QBITTORRENT_DAEMON_WEB_PORT
[LegalNotice]
Accepted=true" > $homeFolder/.config/qBittorrent/qBittorrent.conf
chown $username:$username $homeFolder/.config/qBittorrent/qBittorrent.conf

