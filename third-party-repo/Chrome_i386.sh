#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Chrome application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../common/commonVariables.sh "`pwd`/.."

if [ "$language" == "es" ]; then
	message="Google Chrome no está soportado para sistemas Linux 32 bits. La aplicación no puede ser instalada"
else
	message="Google Chrome is deprecated for linux 32 bits. The application can't be installed"
fi

echo "$message" 1>&2
if [ -n $DISPLAY ]; then
	notify-send -i "$installerIconFolder/applications-other.svg" "ERROR" "$message"
fi
