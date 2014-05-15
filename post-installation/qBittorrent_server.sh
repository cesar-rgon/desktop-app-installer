#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.0
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

# INFO
# QBITTORRENT_DAEMON_PASSWORD="adminadmin"

# Variables
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

# Create menu launcher for qbittorrent-daemon's web client.
echo "[Desktop Entry]
Name=qBittorrent Web
Exec=xdg-open http://localhost:$QBITTORRENT_DAEMON_WEB_PORT
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=qBittorrent Web" > /usr/share/applications/qbittorrent-nox-cli.desktop

# Create menu launcher to start qbittorrent-daemon.
echo "[Desktop Entry]
Name=qBittorrent daemon start
Exec=gksudo /etc/init.d/qbittorrent-nox-daemon start
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start qBittorrent server" > /usr/share/applications/qbittorrent-nox-start.desktop

# Create menu launcher to stop qbittorrent-daemon.
echo "[Desktop Entry]
Name=qBittorrent daemon stop
Exec=gksudo /etc/init.d/qbittorrent-nox-daemon stop
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop qBittorrent server" > /usr/share/applications/qbittorrent-nox-stop.desktop

# Extract qbittorrent icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/qbittorrent.tar.gz"

# Start qbittorrent daemon
service qbittorrent-nox-daemon start

# Create qbittorrent daemon startup links
update-rc.d -f qbittorrent-nox-daemon defaults

