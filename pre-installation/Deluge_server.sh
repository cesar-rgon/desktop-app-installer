#!/bin/bash
##########################################################################
# This script configures Deluge daemon to be ready to use.
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
DELUGE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/deluge"
TEMP_FOLDER="$homeFolder/.Temporal"
DELUGE_DAEMON_TEMP_FOLDER="$TEMP_FOLDER/deluge"
DELUGE_DAEMON_TORRENT_FOLDER="$homeDownloadFolder/torrents"
DELUGE_DAEMON_USERNAME="$username"
DELUGE_DAEMON_PASSWORD="deluge"
DELUGE_DAEMON_CLIENT_PORT="58846"
DELUGE_DAEMON_WEB_PORT="8112"

# Create the necessary folders
mkdir -p $DELUGE_DAEMON_DOWNLOAD_FOLDER $DELUGE_DAEMON_TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER $homeFolder/.config/deluge
chown -R $username:$username $DELUGE_DAEMON_DOWNLOAD_FOLDER $TEMP_FOLDER $DELUGE_DAEMON_TORRENT_FOLDER $homeFolder/.config/deluge

# Set variables in deluge-daemon config files
echo "# Configuration for /etc/init.d/deluge-daemon
# The init.d script will only run if this variable non-empty.
DELUGED_USER=\"$username\"
# Should we run at startup?
RUN_AT_STARTUP=\"YES\"" > /etc/default/deluge-daemon

# Add username and password to Deluge's authentication file
echo "$DELUGE_DAEMON_USERNAME:$DELUGE_DAEMON_PASSWORD:10" >> $homeFolder/.config/deluge/auth
chown $username:$username $homeFolder/.config/deluge/auth

# Setup Deluge daemon's config file
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
}" > "$homeFolder/.config/deluge/core.conf"

# Set Deluge daemon web port
echo "{
  \"file\": 1, 
  \"format\": 1
}{
  \"port\": $DELUGE_DAEMON_WEB_PORT
}" > "$homeFolder/.config/deluge/web.conf"
chown $username:$username "$homeFolder/.config/deluge/web.conf"

# Copy deluge-daemon init script
cp $scriptRootFolder/etc/deluge-daemon /etc/init.d/
chmod +x /etc/init.d/deluge-daemon

