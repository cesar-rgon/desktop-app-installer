#!/bin/bash
##########################################################################
# This script configures aMule client to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
# Note: This script was compatible for both linux OS: Ubuntu and Debian.
# Debian 8 has removed amule package from stable repository.
# In a future version, if aMule come back to stable repository, this
# script will back to parent directory, it means, available for both
# linux OS.
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"
mkdir -p /usr/share/amule/skins
cp $scriptRootFolder/icons/aMule-faenza-theme.zip /usr/share/amule/skins

