#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Google
# Chrome application.
# @author César Rodríguez González
# @version 1.3, 2016-08-07
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
. $scriptRootFolder/common/commonVariables.properties

if [ "$language" == "es" ]; then
	message="Google Chrome no está soportado para sistemas Linux 32 bits. La aplicación no puede ser instalada"
else
	message="Google Chrome is deprecated for linux 32 bits. The application can't be installed"
fi

echo "$message" 1>&2
if [ -n $DISPLAY ]; then
	notify-send -i "$installerIconFolder/applications-other.svg" "ERROR" "$message"
fi
