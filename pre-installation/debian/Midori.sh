#!/bin/bash
##########################################################################
# This script prepares Midori application to be ready to be installed.
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

if [ ! -f /etc/apt/sources.list.backup ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# Debian Jessie has disabled midori package by default. We must enable testing branch to be able to install the application
sed -i 's/jessie main/stretch main/g' /etc/apt/sources.list
