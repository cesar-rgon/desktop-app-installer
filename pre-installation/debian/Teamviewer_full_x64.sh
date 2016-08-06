#!/bin/bash
##########################################################################
# This script prepares Teamviewer application to be ready to be installed
# on 64 bits OS linux
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/../.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# We must add 32 bits architecture to be able to install Skype 32 bits in 64 bits OS
dpkg --add-architecture i386
