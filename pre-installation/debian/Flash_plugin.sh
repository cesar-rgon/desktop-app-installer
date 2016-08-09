#!/bin/bash
##########################################################################
# This script prepares the installation of Flash plugin package.
# @author César Rodríguez González
# @version 1.3, 2016-08-09
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Commands to prepare the installation of an application.
if [ ! -f /etc/apt/sources.list.backup ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# Enable contrib and non-free repositories
sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
