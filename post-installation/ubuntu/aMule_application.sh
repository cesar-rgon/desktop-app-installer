#!/bin/bash
##########################################################################
# This script configures aMule application to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
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
AMULE_DOWNLOAD_FOLDER="$homeDownloadFolder/aMule"
AMULE_TEMP_FOLDER="$homeFolder/.Temporal/aMule"
AMULE_ACCEPT_EXTERNAL_CONNECTIONS=0
AMULE_EXTERNAL_CONNECTION_PASSWORD=""
AMULE_EXTERNAL_CONNECTION_PORT="4712"
AMULE_ENABLE_WEB_SERVER=0
AMULE_WEB_SERVER_PASSWORD=""
AMULE_WEB_SERVER_PORT="4711"

# Create the necessary folders
mkdir -p $AMULE_DOWNLOAD_FOLDER $AMULE_TEMP_FOLDER $homeFolder/.aMule/
chown $username:$username $AMULE_DOWNLOAD_FOLDER $AMULE_TEMP_FOLDER $homeFolder/.aMule/

# Create backup of config file
sudo -u $username cp $scriptRootFolder/etc/amule.conf $homeFolder/.aMule/
sudo -u $username cp $homeFolder/.aMule/amule.conf $homeFolder/.aMule/amule.conf.backup

# Set variables in amule config file
sudo -u $username sed -i "s@^IncomingDir=.*@IncomingDir=$AMULE_DOWNLOAD_FOLDER@g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s@^TempDir=.*@TempDir=$AMULE_TEMP_FOLDER@g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^AcceptExternalConnections=.*/AcceptExternalConnections=$AMULE_ACCEPT_EXTERNAL_CONNECTIONS/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^ECPassword=.*/ECPassword=`echo -n $AMULE_EXTERNAL_CONNECTION_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^ECPort=.*/ECPort=$AMULE_EXTERNAL_CONNECTION_PORT/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Enabled=.*/Enabled=$AMULE_ENABLE_WEB_SERVER/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Password=.*/Password=`echo -n $AMULE_WEB_SERVER_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Port=.*/Port=$AMULE_WEB_SERVER_PORT/g" $homeFolder/.aMule/amule.conf

# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"
mkdir -p /usr/share/amule/skins
cp $scriptRootFolder/icons/aMule-faenza-theme.zip /usr/share/amule/skins

