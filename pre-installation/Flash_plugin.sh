#!/bin/bash
# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Commands to prepare the installation of an application.
if [ "$distro" == "debian" ]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.backup
	# Enable contrib and non-free repositories
	sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
fi
