#!/bin/bash
##########################################################################
# This script prepares the installation of Flash plugin package.
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

# Commands to prepare the installation of an application.
if [ ! -f /etc/apt/sources.list.backup ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# Enable contrib and non-free repositories
sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list

