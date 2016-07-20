#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 20/07/2016
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
QBITTORRENT_SERVICE_FILE="/etc/systemd/system/qbittorrent-nox.service"

# Create the necessary folders
sudo -u $username mkdir -p $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER $homeFolder/.config/qBittorrent

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

# Set variables in qbittorrent-daemon init service
sed -i "s/=DESCRIPTION.*/=qBittorrent Nox Daemon/g" $QBITTORRENT_SERVICE_FILE
sed -i "s/=man:PACKAGE.*/=man:qbitorrent-nox/g" $QBITTORRENT_SERVICE_FILE
sed -i "s/=USERNAME.*/=$QBITTORRENT_DAEMON_USERNAME/g" $QBITTORRENT_SERVICE_FILE
sed -i "s/=GROUP.*/=$QBITTORRENT_DAEMON_USERNAME/g" $QBITTORRENT_SERVICE_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/qbittorrent-nox --webui-port=$QBITTORRENT_DAEMON_WEB_PORT -d/g" $QBITTORRENT_SERVICE_FILE

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
Exec=gksudo systemctl start qbittorrent-nox
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start qBittorrent server" > /usr/share/applications/qbittorrent-nox-start.desktop

# Create menu launcher to stop qbittorrent-daemon.
echo "[Desktop Entry]
Name=qBittorrent daemon stop
Exec=gksudo systemctl stop qbittorrent-nox
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop qBittorrent server" > /usr/share/applications/qbittorrent-nox-stop.desktop

# Extract qbittorrent icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/qbittorrent.tar.gz"

# Create qbittorrent daemon startup links
systemctl enable /etc/systemd/system/qbittorrent-nox.service
systemctl daemon-reload

# Start qbittorrent daemon
systemctl start qbittorrent-nox


