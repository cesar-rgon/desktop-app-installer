#!/bin/bash
##########################################################################
# This script configures qBittorrent daemon to be ready to use.
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
. $credentialFolder/qBittorrent_server.properties

# Variables
QBITTORRENT_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/qBittorrent"
QBITTORRENT_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/qBittorrent"
QBITTORRENT_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
QBITTORRENT_DAEMON_WEB_PORT="8081"
QBITTORRENT_DAEMON_TCP_PORT="8999"
QBITTORRENT_DAEMON_FILE="/etc/init.d/qbittorrent-nox-daemon"

### CREATE QBITTORRENT USER ##############################################
useradd qbtuser -m
# Add system user to qBittorrent group
usermod -a -G qbtuser $username


# Create the necessary folders, set ownership and permissions
sudo -u $username mkdir -p $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER $homeFolder/.config/qBittorrent $homeFolder/.local/share/data/qBittorrent
chmod -R 770 $QBITTORRENT_DAEMON_DOWNLOAD_FOLDER $QBITTORRENT_DAEMON_TEMP_FOLDER $QBITTORRENT_DAEMON_TORRENT_FOLDER
find $homeFolder/.config/qBittorrent/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.config/qBittorrent/* -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null
find $homeFolder/.local/share/data/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.local/share/data -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null

# Copy qbittorrent daemon init script
cp $scriptRootFolder/etc/old-init.d/qbittorrent-nox-daemon /etc/init.d/
chmod +x $QBITTORRENT_DAEMON_FILE

# Set variables in qbittorrent-daemon config files
sed -i "s/USER=.*/USER=$username/g" $QBITTORRENT_DAEMON_FILE
sed -i "s/DAEMON_ARGS=.*/DAEMON_ARGS=\"--webui-port=$QBITTORRENT_DAEMON_WEB_PORT\"/g" $QBITTORRENT_DAEMON_FILE

echo "[Preferences]
Connection\PortRangeMin=$QBITTORRENT_DAEMON_TCP_PORT
Downloads\SavePath=$QBITTORRENT_DAEMON_DOWNLOAD_FOLDER
Downloads\TempPathEnabled=true
Downloads\TempPath=$QBITTORRENT_DAEMON_TEMP_FOLDER
Downloads\ScanDirs=$QBITTORRENT_DAEMON_TORRENT_FOLDER
WebUI\Username=$appUsername
WebUI\Password_ha1=@ByteArray(`echo -n $appPassword | md5sum | cut -d ' ' -f 1`)
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
Exec=gksudo $QBITTORRENT_DAEMON_FILE start
Icon=qbittorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start qBittorrent server" > /usr/share/applications/qbittorrent-nox-start.desktop

# Create menu launcher to stop qbittorrent-daemon.
echo "[Desktop Entry]
Name=qBittorrent daemon stop
Exec=gksudo $QBITTORRENT_DAEMON_FILE stop
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
