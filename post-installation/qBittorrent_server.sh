#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 24/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh


### VARIABLES ############################################################
QBITTORRENT_DAEMON_USERNAME="$username"
# Transmission Daemon doesn't allow to change default password. You must change inside the application
# QBITTORRENT_DAEMON_PASSWORD="adminadmin"
QBITTORRENT_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/qBittorrent"
QBITTORRENT_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/qBittorrent"
QBITTORRENT_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
QBITTORRENT_DAEMON_WEB_PORT="8081"
QBITTORRENT_DAEMON_FILE="/etc/systemd/system/qbittorrent-nox.service"


### CREATE FOLDERS #######################################################
sudo -u $username mkdir -p $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER $homeFolder/.config/qBittorrent
sudo -u $username mkdir -p $homeFolder/.local/share/data/qBittorrent

### SETUP APPLICATION CONFIG FILES #######################################
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


### SETUP SYSTEMD SERVICE ################################################
sed -i "s/=DESCRIPTION.*/=qBittorrent Nox Daemon/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:qbitorrent-nox/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=forking/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/=USERNAME.*/=$QBITTORRENT_DAEMON_USERNAME/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/=GROUP.*/=$QBITTORRENT_DAEMON_USERNAME/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/qbittorrent-nox -d/g" $QBITTORRENT_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
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


### OTHERS ###############################################################
# Extract application icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/qbittorrent.tar.gz"
# Set ownership of config files and/or folders
chown -R $username:$username $homeFolder/.config/qBittorrent/*
# Set permissions
chmod -R 770 $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER
find $homeFolder/.config/qBittorrent/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.config/qBittorrent/* -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null
find $homeFolder/.local/share/data/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.local/share/data -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null

### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
systemctl stop qbittorrent-nox 2>/dev/null
systemctl enable /etc/systemd/system/qbittorrent-nox.service
systemctl daemon-reload
systemctl start qbittorrent-nox

