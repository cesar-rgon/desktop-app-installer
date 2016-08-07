#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
# @author César Rodríguez González
# @version 1.3, 2016-08-07
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
. $scriptRootFolder/common/commonVariables.properties

### VARIABLES ############################################################
DELUGE_DAEMON_USERNAME="$username"
DELUGE_DAEMON_PASSWORD="deluge"
DELUGE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/deluge"
DELUGE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/deluge"
DELUGE_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
DELUGE_DAEMON_TCP_AND_CLIENT_PORT="58846"
DELUGE_DAEMON_WEB_PORT="8112"
DELUGE_DAEMON_FILE="/etc/systemd/system/deluged.service"
DELUGE_WEB_DAEMON_FILE="/etc/systemd/system/deluge-web.service"


### CREATE FOLDERS #######################################################
sudo -u $username mkdir -p $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER $homeFolder/.config/deluge


### SETUP APPLICATION CONFIG FILES #######################################
echo "$DELUGE_DAEMON_USERNAME:$DELUGE_DAEMON_PASSWORD:10" >> $homeFolder/.config/deluge/auth

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

echo "{
  \"file\": 1,
  \"format\": 1
}{
  \"port\": $DELUGE_DAEMON_WEB_PORT
}" > "$homeFolder/.config/deluge/web.conf"


### SETUP SYSTEMD SERVICE ################################################
# Deluge-daemon service. Available only by an application client
sed -i "s/=DESCRIPTION.*/=Deluge Daemon/g" $DELUGE_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:deluged/g" $DELUGE_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=simple/g" $DELUGE_DAEMON_FILE
sed -i "s/=USERNAME.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_DAEMON_FILE
sed -i "s/=GROUP.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/deluged -d -l $(echo "$homeFolder" | sed -r 's/\/+/\\\//g')\/.config\/deluge\/daemon.log -L error/g" $DELUGE_DAEMON_FILE
# Deluge-web service. Available only by a web browser
sed -i "s/=DESCRIPTION.*/=Deluge Web/g" $DELUGE_WEB_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:deluge-web/g" $DELUGE_WEB_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=simple/g" $DELUGE_WEB_DAEMON_FILE
sed -i "s/=USERNAME.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_WEB_DAEMON_FILE
sed -i "s/=GROUP.*/=$DELUGE_DAEMON_USERNAME/g" $DELUGE_WEB_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/deluge-web/g" $DELUGE_WEB_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
# Create menu launcher for deluge-web's client.
echo "[Desktop Entry]
Name=Deluge Web
Exec=xdg-open http://localhost:$DELUGE_DAEMON_WEB_PORT
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Deluge Web" > /usr/share/applications/deluged-web.desktop
# Create menu launcher to start deluge-daemon and deluge-web
echo "[Desktop Entry]
Name=Deluge daemon start
Exec=gksudo systemctl start deluged && gksudo systemctl start deluge-web
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Deluge server" > /usr/share/applications/deluged-start.desktop
# Create menu launcher to stop deluge-daemon and deluge-web
echo "[Desktop Entry]
Name=Deluge daemon stop
Exec=gksudo systemctl stop deluged && gksudo systemctl stop deluge-web
Icon=deluge
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Deluge server" > /usr/share/applications/deluged-stop.desktop


### OTHERS ###############################################################
# Extract application icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/deluge.tar.gz"
# Set ownership of config files and/or folders
chown -R $username:$username $homeFolder/.config/deluge/*
# Set permissions
chmod -R 770 $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER
find $homeFolder/.config/deluge/* -type f -print0 2>/dev/null | xargs -0 chmod 660 2>/dev/null
find $homeFolder/.config/deluge/* -type d -print0 2>/dev/null | xargs -0 chmod 770 2>/dev/null


### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
systemctl stop deluged 2>/dev/null
systemctl stop deluge-web 2>/dev/null
systemctl enable /etc/systemd/system/deluged.service
systemctl enable /etc/systemd/system/deluge-web.service
systemctl daemon-reload
systemctl start deluged
systemctl start deluge-web
