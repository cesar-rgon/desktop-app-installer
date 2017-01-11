#!/bin/bash
##########################################################################
# This script configures Aria2 daemon to be ready to use.
# @author César Rodríguez González
# @version 1.3.1, 2017-01-11
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties
# Add credentials for authentication
. $credentialFolder/Aria_2_server.properties

### VARIABLES ############################################################
ARIA2_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/Aria2"
ARIA2_MAX_DOWNLOAD_LIMIT=0
ARIA2_MAX_UPLOAD_LIMIT=10K
ARIA2_DAEMON_CLIENT_PORT="6800"
ARIA2_DAEMON_TCP_PORT="6881"
ARIA2_DAEMON_FILE="/etc/systemd/system/aria2-daemon.service"


### COPY SYSTEMD SERVICE SCRIPT ##########################################
yes | cp -f $scriptRootFolder/etc/systemd.service $ARIA2_DAEMON_FILE


### CREATE FOLDERS #######################################################
sudo -u $username mkdir -p $ARIA2_DAEMON_DOWNLOAD_FOLDER $homeFolder/.aria2


### SETUP APPLICATION CONFIG FILES #######################################
echo "continue
daemon=true
dir=$ARIA2_DAEMON_DOWNLOAD_FOLDER
file-allocation=none
log-level=warn
max-connection-per-server=4
max-concurrent-downloads=3
max-overall-download-limit=$ARIA2_MAX_DOWNLOAD_LIMIT
max-overall-upload-limit=$ARIA2_MAX_UPLOAD_LIMIT
min-split-size=5M
enable-http-pipelining=true
enable-rpc=true
rpc-listen-all=true
rpc-secret=$appPassword
rpc-listen-port=$ARIA2_DAEMON_CLIENT_PORT
listen-port=$ARIA2_DAEMON_TCP_PORT" > $homeFolder/.aria2/aria2.config


### SETUP SYSTEMD SERVICE ################################################
sed -i "s/=DESCRIPTION.*/=Aria2 Daemon/g" $ARIA2_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:aria2c/g" $ARIA2_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=forking/g" $ARIA2_DAEMON_FILE
sed -i "s/=USERNAME.*/=$username/g" $ARIA2_DAEMON_FILE
sed -i "s/=GROUP.*/=$username/g" $ARIA2_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/aria2c --conf-path=$(echo "$homeFolder" | sed -r 's/\/+/\\\//g')\/.aria2\/aria2.config/g" $ARIA2_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
# Create menu launcher to start aria2 daemon.
echo "[Desktop Entry]
Name=Aria2 daemon start
Exec=gksudo systemctl start aria2-daemon
Icon=aria2
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start Aria2 server" > /usr/share/applications/aria2-start.desktop
# Create menu launcher to stop aria2 daemon.
echo "[Desktop Entry]
Name=Aria2 daemon stop
Exec=gksudo systemctl stop aria2-daemon
Icon=aria2
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop Transmission server" > /usr/share/applications/aria2-stop.desktop


### OTHERS ###############################################################
# Set ownership of config files and/or folders
chown $username:$username $homeFolder/.aria2/aria2.config
# Extract aria2 icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/aria2.tar.gz"

### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
service aria2-daemon stop 2>/dev/null
systemctl enable /etc/systemd/system/aria2-daemon.service
systemctl daemon-reload
systemctl start aria2-daemon
