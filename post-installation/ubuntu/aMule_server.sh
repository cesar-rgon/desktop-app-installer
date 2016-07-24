#!/bin/bash
##########################################################################
# This script configures aMule daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 24/07/2016
# Licence: MIT
# Note: This script was compatible for both linux OS: Ubuntu and Debian.
# Debian 8 has removed amule package from stable repository.
# In a future version, if aMule come back to stable repository, this
# script will back to parent directory, it means, available for both
# linux OS.
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh


### VARIABLES ############################################################
AMULE_DAEMON_USERNAME="$username"
AMULE_DAEMON_USER_PASSWORD="amule"
AMULE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/aMule"
AMULE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/aMule"
AMULE_DAEMON_CLIENT_PORT="4712"
AMULE_DAEMON_WEB_PORT="4711"
AMULE_DAEMON_TCP_PORT="4662"
AMULE_DAEMON_UDP_PORT="4672"
AMULE_DAEMON_FILE="/etc/systemd/system/amuled.service"


### CREATE FOLDERS #######################################################
sudo -u $username mkdir -p $AMULE_DAEMON_DOWNLOAD_FOLDER $AMULE_DAEMON_TEMP_FOLDER


### SETUP APPLICATION CONFIG FILES #######################################
# Try to start amule-daemon. The application can not start yet and will automatically create home folder and default config files
sudo -u $username amuled -f 1>/dev/null
# Backup of default main config file
sudo -u $username cp $homeFolder/.aMule/amule.conf $homeFolder/.aMule/amule.conf.backup
# Set relevant amule variables in config file
	# General
sed -i "s/^MaxDownload=.*/MaxDownload=0/g" $homeFolder/.aMule/amule.conf
sed -i "s/^MaxUpload=.*/MaxUpload=10/g" $homeFolder/.aMule/amule.conf
sed -i "s/^Port=.*/Port=$AMULE_DAEMON_TCP_PORT/g" $homeFolder/.aMule/amule.conf
sed -i "s/^UDPPort=.*/UDPPort=$AMULE_DAEMON_UDP_PORT/g" $homeFolder/.aMule/amule.conf
sed -i "s/^MaxSourcesPerFile=.*/MaxSourcesPerFile=300/g" $homeFolder/.aMule/amule.conf
sed -i "s/^MaxConnections=.*/MaxConnections=500/g" $homeFolder/.aMule/amule.conf
sed -i "s/^IncomingDir=.*/IncomingDir=$(echo "$AMULE_DAEMON_DOWNLOAD_FOLDER" | sed -r 's/\/+/\\\//g')/g" $homeFolder/.aMule/amule.conf
sed -i "s/^TempDir=.*/TempDir=$(echo "$AMULE_DAEMON_TEMP_FOLDER" | sed -r 's/\/+/\\\//g')/g" $homeFolder/.aMule/amule.conf
	# External connection
sed -i "s/^AcceptExternalConnections=.*/AcceptExternalConnections=1/g" $homeFolder/.aMule/amule.conf
sed -i "s/^ECPassword=.*/ECPassword=`echo -n $AMULE_DAEMON_USER_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sed -i "s/^ECPort=.*/ECPort=$AMULE_DAEMON_CLIENT_PORT/g" $homeFolder/.aMule/amule.conf
	# Web server
sed -i "s/^Enabled=.*/Enabled=1/g" $homeFolder/.aMule/amule.conf
sed -i "s/^Password=.*/Password=`echo -n $AMULE_DAEMON_USER_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sed -i "s/^Port=.*/Port=$AMULE_DAEMON_WEB_PORT/g" $homeFolder/.aMule/amule.conf


### SETUP SYSTEMD SERVICE ################################################
sed -i "s/=DESCRIPTION.*/=aMule daemon/g" $AMULE_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:amuled/g" $AMULE_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=forking/g" $AMULE_DAEMON_FILE
sed -i "s/=USERNAME.*/=$username/g" $AMULE_DAEMON_FILE
sed -i "s/=GROUP.*/=$username/g" $AMULE_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/amuled -f/g" $AMULE_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
# Create menu launcher for amule-daemon's web client.
echo "[Desktop Entry]
Name=aMule Web
Exec=xdg-open http://localhost:$AMULE_DAEMON_WEB_PORT
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=aMule Web" > /usr/share/applications/amuled-web.desktop
# Create menu launcher to start amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon start
Exec=gksudo systemctl start amuled
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start aMule server" > /usr/share/applications/amuled-start.desktop
# Create menu launcher to stop amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon stop
Exec=gksudo systemctl stop amuled
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop aMule server" > /usr/share/applications/amuled-stop.desktop


### OTHERS ###############################################################
# Stop service and remove upstart scripts installed automatically by aMule daemon. Not used by systemd service manager
service amule-daemon stop 2>/dev/null
update-rc.d -f amule-daemon remove 2>/dev/null
rm /etc/init.d/amule-daemon 2>/dev/null
rm /etc/default/amule-daemon 2>/dev/null
# Set ownership of config files and/or folders
chown -R $username:$username $AMULE_DAEMON_DOWNLOAD_FOLDER $AMULE_DAEMON_TEMP_FOLDER $homeFolder/.aMule
# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"


### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
systemctl enable /etc/systemd/system/amuled.service
systemctl daemon-reload
systemctl start amuled

