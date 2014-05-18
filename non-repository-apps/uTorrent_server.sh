#!/bin/bash
##########################################################################
# This script installs and configures uTorrent server application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 18/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# DEFAULT uTORRENT SERVER INFO
# Username: admin
# Password:
# Web port: 8080

# Variables
utorrentFile="utserver.tar.gz"
if [ `uname -i` == "x86_64" ]; then
	utorrentURL="http://download-new.utorrent.com/endpoint/utserver/os/linux-x64-ubuntu-12-04/track/beta/$utorrentFile"
else
	utorrentURL="http://download-new.utorrent.com/endpoint/utserver/os/linux-i386-ubuntu-12-04/track/beta/$utorrentFile"
fi

# Delete previous uTorrent's file downloaded before.
rm -f /var/cache/apt/archives/$utorrentFile
# Download uTorrent
wget -P /var/cache/apt/archives $utorrentURL 2>&1
# Decompress to system folder
tar -xzf /var/cache/apt/archives/$utorrentFile -C /usr/share
installationFolder=`ls /usr/share/utorrent* -d | awk -F "/" '{print $4}'`

# Install neccesary library
apt-get -y install libssl1.0.0 --fix-missing

# Copy utorrent's startup script to the system
cp $scriptRootFolder/etc/utorrent-daemon /etc/init.d
chmod +x /etc/init.d/utorrent-daemon
sed -i "s/USER=.*/USER=$username/g" /etc/init.d/utorrent-daemon
sed -i "s@UTORRENT_PATH=.*@UTORRENT_PATH=/usr/share/$installationFolder@g" /etc/init.d/utorrent-daemon

# Extract uTorrent icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/utorrent.tar.gz"

# Create menu launcher for utorrent-server's web client.
echo "[Desktop Entry]
Name=uTorrent web
Exec=xdg-open http://localhost:8080/gui
Icon=utorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=uTorrent web" > /usr/share/applications/utorrent-cli.desktop

# Create menu launcher to start utorrent-server.
echo "[Desktop Entry]
Name=uTorrent server start
Exec=gksudo /etc/init.d/utorrent-daemon start
Icon=utorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start uTorrent server" > /usr/share/applications/utorrent-start.desktop

# Create menu launcher to stop utorrent-server.
echo "[Desktop Entry]
Name=uTorrent server stop
Exec=gksudo /etc/init.d/utorrent-daemon stop
Icon=utorrent
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop uTorrent server" > /usr/share/applications/utorrent-stop.desktop

# Create utorrent log folder
mkdir -p /var/log/utorrent
chown $username:$username /var/log/utorrent

# Start utorrent server
service utorrent-daemon start

# Create utorrent startup links
update-rc.d -f utorrent-daemon defaults

