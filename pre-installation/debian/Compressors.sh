#!/bin/bash
##########################################################################
# This script prepares the installation of Clementine application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../../common/commonVariables.sh "`pwd`/../.."

# Commands to prepare the installation of an application.
if [ ! -f /etc/apt/sources.list.backup ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# Enable contrib and non-free repositories
sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
