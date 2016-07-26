#!/bin/bash
##########################################################################
# This script configures aMule application to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 26/07/2016
# Licence: MIT
# Note: This script was compatible for both linux OS: Ubuntu and Debian.
# Debian 8 has removed amule package from stable repository.
# In a future version, if aMule come back to stable repository, this
# script will back to parent directory, it means, available for both
# linux OS.
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables 
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Variables
AMULE_DOWNLOAD_FOLDER="$homeDownloadFolder/aMule"
AMULE_TEMP_FOLDER="$homeFolder/.Temporal/aMule"

# Create the necessary folders
mkdir -p $AMULE_DOWNLOAD_FOLDER $AMULE_TEMP_FOLDER $homeFolder/.aMule/
chown $username:$username $AMULE_DOWNLOAD_FOLDER $AMULE_TEMP_FOLDER $homeFolder/.aMule/

# Create backup of config file
sudo -u $username cp $scriptRootFolder/etc/amule.conf $homeFolder/.aMule/
sudo -u $username cp $homeFolder/.aMule/amule.conf $homeFolder/.aMule/amule.conf.backup

# Set variables in amule config file
sudo -u $username sed -i "s@^IncomingDir=.*@IncomingDir=$AMULE_DOWNLOAD_FOLDER@g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s@^TempDir=.*@TempDir=$AMULE_TEMP_FOLDER@g" $homeFolder/.aMule/amule.conf

# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"
mkdir -p /usr/share/amule/skins
cp $scriptRootFolder/icons/aMule-faenza-theme.zip /usr/share/amule/skins

