#!/bin/bash
##########################################################################
# This script installs Skype application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 17/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Create backup of main repositories file
if [ ! -f /etc/apt/sources.list.backup ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# Debian Jessie has disabled Midori packages by default. We must enable testing branch to be able to install the application
sed -i 's/jessie main/stretch main/g' /etc/apt/sources.list
# Update repositories
apt-get update 2>&1
# Install packages
apt-get -y install midori 2>&1
# After install Midori application the system must be returned to stable default repository
sed -i 's/stretch main/jessie main/g' /etc/apt/sources.list
# Update repositories
apt-get update 2>&1
