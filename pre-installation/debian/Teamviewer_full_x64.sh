#!/bin/bash
##########################################################################
# This script prepares Teamviewer application to be ready to be installed
# on 64 bits OS linux
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

# We must add 32 bits architecture to be able to install Skype 32 bits in 64 bits OS
dpkg --add-architecture i386


