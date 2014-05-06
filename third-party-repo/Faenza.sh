#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Faenza
# icon theme.
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

apt-key add "$scriptRootFolder/third-party-repo/keys/faenza.key"
echo "deb http://ppa.launchpad.net/tiheum/equinox/ubuntu precise main" > /etc/apt/sources.list.d/tiheum-equinox-precise.list
echo "deb-src http://ppa.launchpad.net/tiheum/equinox/ubuntu precise main" >> /etc/apt/sources.list.d/tiheum-equinox-precise.list
