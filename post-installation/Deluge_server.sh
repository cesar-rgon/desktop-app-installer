#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 22/07/2016
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
DELUGE_DAEMON_USERNAME="$username"
DELUGE_DAEMON_PASSWORD="deluge"
DELUGE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/deluge"
DELUGE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/deluge"
DELUGE_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
DELUGE_DAEMON_CLIENT_PORT="58846"
DELUGE_DAEMON_WEB_PORT="8112"
DELUGE_DAEMON_FILE="/etc/systemd/system/deluged.service"


### CREATE FOLDERS AND SET PERMISSIONS ###################################
sudo -u $username mkdir -p $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER $homeFolder/.config/deluge
chmod -R 770 $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER


### SETUP APPLICATION CONFIG FILES #######################################
echo "$DELUGE_DAEMON_USERNAME:$DELUGE_DAEMON_PASSWORD:10" >> /var/lib/service/.config/deluge/auth

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
  \"daemon_port\": $DELUGE_DAEMON_CLIENT_PORT,
  \"allow_remote\": true
}" > "/var/lib/service/.config/deluge/core.conf"

echo "{
  \"file\": 1, 
  \"format\": 1
}{
  \"port\": $DELUGE_DAEMON_WEB_PORT
}" > "/var/lib/service/.config/deluge/web.conf"


### SETUP SYSTEMD SERVICE ################################################
sed -i "s/=DESCRIPTION.*/=Deluge Daemon/g" $DELUGE_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:deluged/g" $DELUGE_DAEMON_FILE
sed -i "s/=USERNAME.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_DAEMON_FILE
sed -i "s/=GROUP.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/deluged -d -l $homeFolder\/.config\/deluge\/daemon.log -L warning/g" $DELUGE_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
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
Exec=gksudo systemctl start deluged
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Deluge server" > /usr/share/applications/deluged-start.desktop
# Create menu launcher to stop deluge-daemon.
echo "[Desktop Entry]
Name=Deluge daemon stop
Exec=gksudo systemctl stop deluged
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Deluge server" > /usr/share/applications/deluged-stop.desktop


### OTHERS ###############################################################
# Extract application icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/deluge.tar.gz"


### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
systemctl stop deluged 2>/dev/null
systemctl enable /etc/systemd/system/deluged.service
systemctl daemon-reload
systemctl start deluged

