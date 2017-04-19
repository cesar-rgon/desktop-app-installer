#!/bin/bash
##########################################################################
# This script sends a warning message. It's not possible to install Atom
# application on 32 bits operating systems.
# @author César Rodríguez González
# @version 1.3.3, 2017-04-19
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

if [ "$language" == "es" ]; then
	message="Atom no está soportado para sistemas Linux 32 bits. La aplicación no puede ser instalada"
else
	message="Atom is deprecated for linux 32 bits. The application can't be installed"
fi

echo "$message" 1>&2
if [ -n "$DISPLAY" ]; then
	notify-send -i "$installerIconFolder/stop-error.png" "ERROR" "$message"
    sleep 5
fi
